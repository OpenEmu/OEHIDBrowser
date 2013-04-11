//
//  DDMultipartStreamTest.m
//  nsurl
//
//  Created by Dave Dribin on 5/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDMultipartInputStreamTest.h"
#import "DDMultipartInputStream.h"
#import "DDExtensions.h"

@implementation DDMultipartInputStreamTest

- (void) setUp
{
    mStream = [[DDMultipartInputStream alloc] init];
}

- (void) tearDown
{
    [mStream release];
    mStream = nil;
}

- (NSData *) readUntilEndOfStream;
{
    NSData * data = [mStream dd_readUntilEndOfStream];
    [mStream close];
    
    return data;
}

- (void) testBoundary;
{
    STAssertNotNil(mStream, nil);
}

- (void) testMultipartStreamWithOneStringPart
{
    [mStream addPartWithName: @"foo" string: @"bar"];

    NSMutableString * expected = [NSMutableString string];
    [expected appendFormat: @"--%@\r\n", [mStream boundary]];
    [expected appendString: @"Content-Disposition: form-data; name=\"foo\"\r\n"];
    [expected appendString: @"\r\n"];
    [expected appendString: @"bar"];
    [expected appendFormat: @"\r\n--%@--\r\n", [mStream boundary]];
    [mStream buildBody];
    
    // Check length before opening stream
    STAssertEquals([mStream length], (unsigned long long) [expected length], nil);
    
    [mStream open];
    STAssertTrue([mStream hasBytesAvailable], nil);
    NSData * actualData = [self readUntilEndOfStream];
    NSString * actualString = [[NSString alloc] initWithData: actualData
                                                    encoding: NSUTF8StringEncoding];
    [actualString autorelease];
    STAssertEqualObjects(actualString, expected, nil);
}

- (void) testMultipartStreamWithTwoParts
{
    [mStream addPartWithName: @"foo" string: @"bar"];
    [mStream addPartWithName: @"baz" intValue: 5];
    [mStream buildBody];
    
    NSMutableString * expected = [NSMutableString string];
    [expected appendFormat: @"--%@\r\n", [mStream boundary]];
    [expected appendString: @"Content-Disposition: form-data; name=\"foo\"\r\n"];
    [expected appendString: @"\r\n"];
    [expected appendString: @"bar"];
    [expected appendFormat: @"\r\n--%@\r\n", [mStream boundary]];
    [expected appendString: @"Content-Disposition: form-data; name=\"baz\"\r\n"];
    [expected appendString: @"\r\n"];
    [expected appendString: @"5"];
    [expected appendFormat: @"\r\n--%@--\r\n", [mStream boundary]];
    
    // Check length before opening stream
    STAssertEquals([mStream length], (unsigned long long) [expected length], nil);
    
    [mStream open];
    NSData * actualData = [self readUntilEndOfStream];
    NSString * actualString = [[NSString alloc] initWithData: actualData
                                                    encoding: NSUTF8StringEncoding];
    [actualString autorelease];
    STAssertEqualObjects(actualString, expected, nil);
}

- (void) testMultipartStreamWithTextFilePart
{
    NSString * filePath = [[NSBundle bundleForClass: [self class]]
        pathForResource: @"file" ofType: @"txt"];
    [mStream addPartWithName: @"foo" string: @"bar"];
    [mStream addPartWithName: @"file" fileAtPath: filePath];
    [mStream buildBody];
    
    NSMutableString * expected = [NSMutableString string];
    [expected appendFormat: @"--%@\r\n", [mStream boundary]];
    [expected appendString: @"Content-Disposition: form-data; name=\"foo\"\r\n"];
    [expected appendString: @"\r\n"];
    [expected appendString: @"bar"];
    [expected appendFormat: @"\r\n--%@\r\n", [mStream boundary]];
    [expected appendString: @"Content-Disposition: form-data; name=\"file\"; filename=\"file.txt\"\r\n"];
    [expected appendString: @"Content-Transfer-Encoding: binary\r\n"];
    [expected appendString: @"Content-Type: text/plain\r\n"];
    [expected appendString: @"\r\n"];
    [expected appendString: @"Line one\n"];
    [expected appendString: @"Line two\n"];
    [expected appendFormat: @"\r\n--%@--\r\n", [mStream boundary]];
    
    // Check length before opening stream
    STAssertEquals([mStream length], (unsigned long long) [expected length], nil);
    
    [mStream open];
    NSData * actualData = [self readUntilEndOfStream];
    NSString * actualString = [[NSString alloc] initWithData: actualData
                                                    encoding: NSUTF8StringEncoding];
    [actualString autorelease];
    STAssertEqualObjects(actualString, expected, nil);
}

- (void) testMultipartStreamWithBinaryFilePart
{
    NSString * filePath = [[NSBundle bundleForClass: [self class]]
        pathForResource: @"mspacman" ofType: @"png"];
    [mStream addPartWithName: @"foo" string: @"bar"];
    [mStream addPartWithName: @"file" fileAtPath: filePath];
    [mStream buildBody];
    
    NSMutableData * expected = [NSMutableData data];
    [expected dd_appendUTF8Format: @"--%@\r\n", [mStream boundary]];
    [expected dd_appendUTF8String: @"Content-Disposition: form-data; name=\"foo\"\r\n"];
    [expected dd_appendUTF8String: @"\r\n"];
    [expected dd_appendUTF8String: @"bar"];
    [expected dd_appendUTF8Format: @"\r\n--%@\r\n", [mStream boundary]];
    [expected dd_appendUTF8String: @"Content-Disposition: form-data; name=\"file\"; filename=\"mspacman.png\"\r\n"];
    [expected dd_appendUTF8String: @"Content-Transfer-Encoding: binary\r\n"];
    [expected dd_appendUTF8String: @"Content-Type: image/png\r\n"];
    [expected dd_appendUTF8String: @"\r\n"];
    [expected appendData: [NSData dataWithContentsOfFile: filePath]];
    [expected dd_appendUTF8Format: @"\r\n--%@--\r\n", [mStream boundary]];
    
    // Check length before opening stream
    STAssertEquals([mStream length], (unsigned long long) [expected length], nil);

    [mStream open];
    NSData * actualData = [self readUntilEndOfStream];
    STAssertEqualObjects(actualData, expected, nil);
}

- (void) testInputStreamWithTemporaryFile
{
    NSString * filePath = [[NSBundle bundleForClass: [self class]]
        pathForResource: @"file" ofType: @"txt"];
    [mStream addPartWithName: @"foo" string: @"bar"];
    [mStream addPartWithName: @"file" fileAtPath: filePath];
    [mStream buildBody];
    
    NSMutableString * expected = [NSMutableString string];
    [expected appendFormat: @"--%@\r\n", [mStream boundary]];
    [expected appendString: @"Content-Disposition: form-data; name=\"foo\"\r\n"];
    [expected appendString: @"\r\n"];
    [expected appendString: @"bar"];
    [expected appendFormat: @"\r\n--%@\r\n", [mStream boundary]];
    [expected appendString: @"Content-Disposition: form-data; name=\"file\"; filename=\"file.txt\"\r\n"];
    [expected appendString: @"Content-Transfer-Encoding: binary\r\n"];
    [expected appendString: @"Content-Type: text/plain\r\n"];
    [expected appendString: @"\r\n"];
    [expected appendString: @"Line one\n"];
    [expected appendString: @"Line two\n"];
    [expected appendFormat: @"\r\n--%@--\r\n", [mStream boundary]];
    
    NSInputStream * inputStream = [mStream inputStreamWithTemporaryFile];
    STAssertNotNil(inputStream, nil);
    
    STAssertEquals([mStream length], (unsigned long long) [expected length], nil);
    
    [inputStream open];
    NSData * actualData = [inputStream dd_readUntilEndOfStream];
    STAssertNotNil(actualData, nil);
    [inputStream close];
    
    NSString * actualString = [[NSString alloc] initWithData: actualData
                                                    encoding: NSUTF8StringEncoding];
    [actualString autorelease];
    STAssertEqualObjects(actualString, expected, nil);
}

- (void) testDataPart;
{
    NSData * body = [@"bar" dataUsingEncoding: NSUTF8StringEncoding];
    DDMultipartDataPart * part = [[DDMultipartDataPart alloc] initWithName: @"foo"
                                                               dataContent: body];
    [part autorelease];
    
    STAssertEqualObjects([part headersAsString],
                         @"Content-Disposition: form-data; name=\"foo\"\r\n\r\n", nil);
}

@end
