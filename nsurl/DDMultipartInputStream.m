//
//  DDMultipartInputStream.m
//  nsurl
//
//  Created by Dave Dribin on 5/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDMultipartInputStream.h"
#import "DDTemporaryFile.h"
#import "DDExtensions.h"
#import "JRLog.h"

@interface DDMultipartInputStream (Private)

@end

@implementation DDMultipartInputStream

- (id) init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mBoundary = @"1174583781";
    mParts = [[NSMutableArray alloc] init];
    mPartStreams = [[NSMutableArray alloc] init];
    
    return self;
}

/*
    [self close];
 */

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [self close];
    [mBoundary release];
    [mParts release];
    [mPartStreams release];
    [mTemporaryFile release];
    
    mBoundary = nil;
    mParts = nil;
    mPartStreams = nil;
    mTemporaryFile = nil;
    [super dealloc];
}

- (NSString *) boundary;
{
    return mBoundary;
}

- (void) addPartWithName: (NSString *) name data: (NSData *) data;
{
    DDMultipartDataPart * part = [DDMultipartDataPart partWithName: name
                                                       dataContent: data];
    [mParts addObject: part];
}

- (void) addPartWithName: (NSString *) name string: (NSString *) string;
{
    NSData * data = [string dataUsingEncoding: NSUTF8StringEncoding];
    [self addPartWithName: name data: data];
}

- (void) addPartWithName: (NSString *) name intValue: (int) intValue;
{
    NSString * intString = [NSString stringWithFormat: @"%d", intValue];
    [self addPartWithName: name string: intString];
}

- (void) addPartWithName: (NSString *) name fileAtPath: (NSString *) path;
{
    DDMultipartDataPart * part = [DDMultipartDataPart partWithName: name
                                                       fileContent: path];
    [mParts addObject: part];
}

- (void) buildBody;
{
    NSString * firstDelimiter = [NSString stringWithFormat: @"--%@\r\n", mBoundary];
    NSString * middleDelimiter = [NSString stringWithFormat: @"\r\n--%@\r\n", mBoundary];
    NSString * delimiter = firstDelimiter;
    
    NSEnumerator * e = [mParts objectEnumerator];
    DDMultipartDataPart * part;
    while (part = [e nextObject])
    {
        NSMutableData * headerData = [NSMutableData data];
        [headerData dd_appendUTF8Format: delimiter];
        [headerData dd_appendUTF8String: [part headersAsString]];
        NSInputStream * headerStream = [NSInputStream inputStreamWithData: headerData];
        [mPartStreams addObject: headerStream];
        mLength += [headerData length];
        
        [mPartStreams addObject: [part contentAsStream]];
        mLength += [part contentLength];
        
        delimiter = middleDelimiter;
    }
    
    NSString * finalDelimiter = [NSString stringWithFormat: @"\r\n--%@--\r\n", mBoundary];
    NSData * finalDelimiterData = [finalDelimiter dataUsingEncoding: NSUTF8StringEncoding];
    NSInputStream * finalDelimiterStream = [NSInputStream inputStreamWithData: finalDelimiterData];
    [mPartStreams addObject: finalDelimiterStream];
    mLength += [finalDelimiterData length];
}

- (unsigned long long) length;
{
    return mLength;
}

- (NSInputStream *) inputStreamWithTemporaryFile;
{
    mTemporaryFile = [[DDTemporaryFile alloc] initWithName: @"multipart"];
    
    [self open];
    [self dd_readIntoFile: [mTemporaryFile fullPath]];
    [self close];
    
    return [NSInputStream inputStreamWithFileAtPath: [mTemporaryFile fullPath]];
}

#pragma mark -
#pragma mark NSInputStream Overrides

- (void) open
{
    [mPartStreams makeObjectsPerformSelector: @selector(open)];
    mCurrentStream = nil;
    mStreamIndex = 0;
    if ([mPartStreams count] > 0)
        mCurrentStream = [mPartStreams objectAtIndex: mStreamIndex];
}

- (void) close
{
    [mPartStreams makeObjectsPerformSelector: @selector(close)];
}

- (BOOL) hasBytesAvailable;
{
    return (mCurrentStream != nil);
}

- (int) read: (uint8_t *) buffer maxLength: (unsigned int) len;
{
    if (mCurrentStream == nil)
        return 0;
    
    int result = [mCurrentStream read: buffer maxLength: len];
    if ((result == 0) &&  (mStreamIndex < [mPartStreams count] - 1))
    {
        mStreamIndex++;
        mCurrentStream = [mPartStreams objectAtIndex: mStreamIndex];
        result = [self read: buffer maxLength: len];
    }
    
    if (result == 0)
        mCurrentStream == nil;
        
    return result;
}

- (BOOL)getBuffer:(uint8_t **)buffer length:(unsigned int *)len
{
    return NO;
}

- (void) sechduleInRunLoop: (NSRunLoop *) runLoop forMode: (NSString *) mode;
{
    JRLogDebug(@"%@", NSStringFromSelector(_cmd));
}

- (void) stream: (NSStream *) theStream handleEvent: (NSStreamEvent) streamEvent;
{
    JRLogDebug(@"%@", NSStringFromSelector(_cmd));
}

#if DD_INPUT_STREAM_HACK

#pragma mark -
#pragma mark NSURLConnection Hacks

- (void) _scheduleInCFRunLoop: (NSRunLoop *) inRunLoop forMode: (id) inMode
{
    // Safe to ignore this?
}

- (void) _setCFClientFlags: (CFOptionFlags)inFlags
                  callback: (CFReadStreamClientCallBack) inCallback
                   context: (CFStreamClientContext) inContext
{
    // Safe to ignore this?
}

#endif

@end

@implementation DDMultipartInputStream (Private)

@end

@implementation DDMultipartDataPart

+ partWithName: (NSString *) name dataContent: (NSData *) data;
{
    return [[[self alloc] initWithName: name dataContent: data] autorelease];
}

+ partWithName: (NSString *) name fileContent: (NSString *) path;
{
    return [[[self alloc] initWithName: name fileContent: path] autorelease];
}

- (id) initWithName: (NSString *) name dataContent: (NSData *) data;
{
    NSString * headers = [NSString stringWithFormat:
        @"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",
        name];
    return [self initWithHeaders: headers dataContent: data];
}

- (id) initWithName: (NSString *) name fileContent: (NSString *) path;
{
    NSMutableString * headers = [NSMutableString string];
    [headers appendFormat: @"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",
            name, [path lastPathComponent]];
    [headers appendString: @"Content-Transfer-Encoding: binary\r\n"];
    [headers appendFormat: @"Content-Type: %@\r\n", [path dd_pathMimeType]];
    [headers appendString: @"\r\n"];
    
    NSDictionary * fileAttributes = [[NSFileManager defaultManager]
        fileAttributesAtPath: path traverseLink: YES];
    NSNumber * fileSize = [fileAttributes valueForKey: NSFileSize];
    
    return [self initWithHeaders: headers
                   streamContent: [NSInputStream inputStreamWithFileAtPath: path]
                          length: [fileSize unsignedLongLongValue]];
}

- (id) initWithHeaders: (NSString *) headers dataContent: (NSData *) data;
{
    return [self initWithHeaders: headers
                   streamContent: [NSInputStream inputStreamWithData: data]
                          length: [data length]];
}

- (id) initWithHeaders: (NSString *) headers
         streamContent: (NSInputStream *) stream
                length: (unsigned long long) length;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mHeaders = [headers retain];
    mContentStream = [stream retain];
    mContentLength  = length;
    
    return self;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [mHeaders release];
    [mContentStream release];
    
    mHeaders = nil;
    mContentStream = nil;
    [super dealloc];
}

- (NSString *) headersAsString;
{
    return mHeaders;
}

- (NSInputStream *) contentAsStream;
{
    return mContentStream;
}

- (unsigned long long) contentLength;
{
    return mContentLength;
}

@end
