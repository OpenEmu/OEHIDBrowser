//
//  NSUrlCliApp.m
//  nsurl
//
//  Created by Dave Dribin on 5/9/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSUrlCliApp.h"
#import "NSUrlExtensions.h"
#import "ddutil.h"
#import "DDExtensions.h"
#import "DDMultipartInputStream.h"
#import "JRLog.h"

const char * COMMAND = 0;

@interface NSUrlCliApp (Private)

- (NSURLResponse *) response;
- (void) setResponse: (NSURLResponse *) theResponse;

@end

@implementation NSUrlCliApp

+ (void) initialize
{
    initializeDefaultCredentials();
}

- (id) init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mUrlRequest = [[NSMutableURLRequest alloc] init];
    [mUrlRequest setCachePolicy: NSURLRequestReloadIgnoringCacheData];
    [mUrlRequest setTimeoutInterval: 60.0];
    [mUrlRequest setHTTPShouldHandleCookies: NO];
    
    mAllowRedirects = NO;
    
    return self;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [mUrlRequest release];
    [mFileHandle release];
    [mResponse release];
    [mMultipartInputStream release];
    [mHttpMethod release];
    [mUsername release];
    [mPassword release];
    
    mUrlRequest = nil;
    mFileHandle = nil;
    mResponse = nil;
    mMultipartInputStream = nil;
    mHttpMethod = nil;
    mUsername = nil;
    mPassword = nil;
    [super dealloc];
}

//=========================================================== 
//  url 
//=========================================================== 
- (NSString *) url
{
    return [[mUrlRequest URL] absoluteString];
}

- (void) setUrl: (NSString *) theUrl
{
    [mUrlRequest setURL: [NSURL URLWithString: theUrl]];
}

//=========================================================== 
//  username 
//=========================================================== 
- (NSString *) username
{
    return mUsername; 
}

- (void) setUsername: (NSString *) theUsername
{
    if (mUsername != theUsername)
    {
        [mUsername release];
        mUsername = [theUsername retain];
    }
}

//=========================================================== 
//  password 
//=========================================================== 
- (NSString *) password
{
    return mPassword; 
}

- (void) setPassword: (NSString *) thePassword
{
    if (mPassword != thePassword)
    {
        [mPassword release];
        mPassword = [thePassword retain];
    }
}

- (void) setHeaderValue: (NSString *) headerValue;
{
    NSArray * components = [headerValue dd_splitBySeparator: @":"];
    if (components == nil)
        return;

    NSString * header = [components objectAtIndex: 0];
    NSString * value = [[components objectAtIndex: 1]
        stringByTrimmingCharactersInSet:
        [NSCharacterSet whitespaceCharacterSet]];

    [mUrlRequest setValue: value forHTTPHeaderField: header];
}

- (void) addHeaderValue: (NSString *) headerValue;
{
    NSArray * components = [headerValue dd_splitBySeparator: @":"];
    if (components == nil)
        return;
    
    NSString * header = [components objectAtIndex: 0];
    NSString * value = [[components objectAtIndex: 1]
        stringByTrimmingCharactersInSet:
        [NSCharacterSet whitespaceCharacterSet]];
    
    [mUrlRequest addValue: value forHTTPHeaderField: header];
}

//=========================================================== 
//  allowRedirects 
//=========================================================== 
- (BOOL) allowRedirects
{
    return mAllowRedirects;
}

- (void) setAllowRedirects: (BOOL) flag
{
    mAllowRedirects = flag;
}

- (void) addFormField: (NSString *) formField;
{
    NSArray * components = [formField dd_splitBySeparator: @"="];
    NSAssert(components != nil, @"Not a valid field form");
    
    NSString * name = [components objectAtIndex: 0];
    NSString * value = [components objectAtIndex: 1];
    
    if (mMultipartInputStream == nil)
    {
        mMultipartInputStream = [[DDMultipartInputStream alloc] init];
        NSString * value = [NSString stringWithFormat:
            @"multipart/form-data; boundary=%@", [mMultipartInputStream boundary]];
        [mUrlRequest setValue: value
           forHTTPHeaderField: @"Content-Type"];
        [mUrlRequest setHTTPMethod: @"POST"];
    }
    
    if ([value hasPrefix: @"@"])
    {
        value = [value substringFromIndex: 1];
        value = [value stringByExpandingTildeInPath];
        [mMultipartInputStream addPartWithName: name
                                    fileAtPath: value];
    }
    else
    {
        [mMultipartInputStream addPartWithName: name
                                        string: value];
    }
}

//=========================================================== 
//  httpMethod 
//=========================================================== 
- (NSString *) httpMethod
{
    return mHttpMethod; 
}

- (void) setHttpMethod: (NSString *) theHttpMethod
{
    if (mHttpMethod != theHttpMethod)
    {
        [mHttpMethod release];
        mHttpMethod = [theHttpMethod retain];
    }
}

- (NSMutableData *) readUntilEndOfStream: (NSInputStream *) stream;
{
    uint8_t buffer[64 * 1024];
    NSMutableData * data = [NSMutableData data];
    
    [stream open];
    int bytesRead;
    while ((bytesRead = [stream read: buffer maxLength: sizeof(buffer)]) != 0)
    {
        [data appendBytes: buffer length: bytesRead];
    }
    [stream close];
    
    return data;
}

- (BOOL) run;
{
    if (mMultipartInputStream != nil)
    {
        [mMultipartInputStream buildBody];
        // Set content length to avoid chunked encoding
        unsigned long long contentLength = [mMultipartInputStream length];
        [mUrlRequest setValue: [NSString stringWithFormat: @"%llu", contentLength]
           forHTTPHeaderField: @"Content-Length"];

#if DD_INPUT_STREAM_HACK
        JRLogDebug(@"Using input stream hack");
        [mUrlRequest setHTTPBodyStream: mMultipartInputStream];
#else
        JRLogDebug(@"Using temporary input stream");
        [mUrlRequest setHTTPBodyStream: [mMultipartInputStream inputStreamWithTemporaryFile]];
#endif
    }
            
    NSURLConnection * connection =
        [[NSURLConnection alloc] initWithRequest: mUrlRequest
                                        delegate: self];
    if (connection == nil)
    {
        ddfprintf(stderr, @"%s: Could not create connection", COMMAND);
        return NO;
    }
    
    mFileHandle = [[NSFileHandle fileHandleWithStandardOutput] retain];
    if (isatty([mFileHandle fileDescriptor]))
        mShowProgress = NO;
    else
        mShowProgress = YES;

    
    mShouldKeepRunning = YES;
    mRanWithSuccess  = YES;
    NSRunLoop * currentRunLoop = [NSRunLoop currentRunLoop];
    while (mShouldKeepRunning &&
           [currentRunLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]])
    {
        // Empty
    }
    
    return mRanWithSuccess;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
    
    if ([[error domain] isEqualToString: NSURLErrorDomain] &&
        [error code] == NSURLErrorUserCancelledAuthentication)
    {
        ddfprintf(stderr, @"%s: Authorization required or invalid authorization\n", COMMAND);
    }
    else
    {
        ddfprintf(stderr, @"%s: Connection failed: %@ %@ %@\n",
                  COMMAND,
                  [error localizedDescription],
                  [error localizedFailureReason],
                  [[error userInfo] objectForKey: NSErrorFailingURLStringKey]);
    }
    mShouldKeepRunning = NO;
    mRanWithSuccess = NO;
}

- (void) connectionDidFinishLoading: (NSURLConnection *) connection
{
    [connection release];
    mShouldKeepRunning = NO;
}

- (void)connection: (NSURLConnection *) connection didReceiveData: (NSData *) data
{
    long long expectedLength = [mResponse expectedContentLength];
    
    mBytesReceived = mBytesReceived + [data length];
    
    if (expectedLength != NSURLResponseUnknownLength)
    {
        // if the expected content length is
        // available, display percent complete
        if (mShowProgress)
        {
            float percentComplete=(mBytesReceived/(float)expectedLength)*100.0;
            fprintf(stderr, "Percent complete - %.1f\r", percentComplete);
            if (mBytesReceived == expectedLength)
                fprintf(stderr, "\n");
        }
    }
    else
    {
        // if the expected content length is
        // unknown just log the progress
        if (mShowProgress)
            fprintf(stderr, "Bytes received - %d\n", mBytesReceived);
    }

    [mFileHandle writeData: data];
}

- (void) connection: (NSURLConnection *) connection
 didReceiveResponse: (NSURLResponse *)response
{
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) response;
    int statusCode = [httpResponse statusCode];
    if ((statusCode == 200) || (statusCode == 201))
    {
        // reset the progress, this might be called multiple times
        mBytesReceived = 0;
        
        // retain the response to use later
        [self setResponse: response];
    }
    else
    {
        NSDictionary * headers = [httpResponse allHeaderFields];
        ddfprintf(stderr, @"%s: Received unsuccessful response: %@\n",
                  COMMAND, [headers valueForKey: @"Status"]);
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    // ddfprintf(stderr, @"%@\n", NSStringFromSelector(_cmd));
    NSURLCredential * credential = [challenge proposedCredential];
    // ddfprintf(stderr, @"Proposed credential: %@, failure count: %d\n", credential, [challenge previousFailureCount]);
    
    if ([challenge previousFailureCount] == 0)
    {
        credential = [NSURLCredential credentialWithUser: mUsername password: mPassword   persistence: NSURLCredentialPersistenceForSession];
        [[challenge sender] useCredential: credential forAuthenticationChallenge:challenge];
    }
    else
    {
        [[challenge sender] cancelAuthenticationChallenge: challenge];
    }
}

- (void)connection:(NSURLConnection *)connection didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;
{
    // ddfprintf(stderr, @"%@\n", NSStringFromSelector(_cmd));
}

- (NSURLRequest *) connection: (NSURLConnection *) connection
              willSendRequest: (NSURLRequest *) request
             redirectResponse: (NSURLResponse *) redirectResponse
{
    if (redirectResponse == nil)
        return request;
        
    NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) redirectResponse;
    if (mAllowRedirects)
    {
        ddfprintf(stderr, @"Redirecting (%d) to: %@\n",
                  [httpResponse statusCode], [request URL]);
        return request;
    }
    else
    {
        ddfprintf(stderr, @"Canceling redirect (%d) to: %@\n",
                  [httpResponse statusCode], [request URL]);
        [connection cancel];
        mShouldKeepRunning = NO;
        mRanWithSuccess = NO;
        return nil;
    }
}

@end


@implementation NSUrlCliApp (Private)

//=========================================================== 
//  response 
//=========================================================== 
- (NSURLResponse *) response
{
    return mResponse; 
}

- (void) setResponse: (NSURLResponse *) theResponse
{
    if (mResponse != theResponse)
    {
        [mResponse release];
        mResponse = [theResponse retain];
    }
}

@end
