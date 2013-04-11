//
//  NSInputStream+DDExtensionsTest.m
//  nsurl
//
//  Created by Dave Dribin on 5/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSInputStream+DDExtensionsTest.h"
#import "NSInputStream+DDExtensions.h"

@implementation NSInputStream_DDExtensionsTest

- (NSString *) resource: (NSString *) name ofType: (NSString*) type;
{
    NSBundle * myBundle = [NSBundle bundleForClass: [self class]];
    return [myBundle pathForResource: name ofType: type];
}

- (void) testReadUntilEndOfStream
{
    NSString * path = [self resource: @"file_100k" ofType: nil];
    NSData * expected = [NSData dataWithContentsOfFile: path];
    
    NSInputStream * inputStream = [NSInputStream inputStreamWithFileAtPath: path];
    [inputStream open];
    NSData * actual = [inputStream dd_readUntilEndOfStream];
    [inputStream close];
    
    STAssertEqualObjects(actual, expected, nil);
}

- (void) testReadIntoFile
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSString * tempFile =
        [NSTemporaryDirectory() stringByAppendingPathComponent: @"foo"];
    [fileManager removeFileAtPath: tempFile handler: nil];
    STAssertNotNil(tempFile, nil);
    
    @try
    {
        NSString * path = [self resource: @"file_100k" ofType: nil];
        NSData * expected = [NSData dataWithContentsOfFile: path];
        
        NSInputStream * inputStream = [NSInputStream inputStreamWithFileAtPath: path];
        [inputStream open];
        [inputStream dd_readIntoFile: tempFile];
        [inputStream close];
        NSData * actual = [NSData dataWithContentsOfFile: tempFile];
        
        STAssertEqualObjects(actual, expected, nil);
        
    }
    @finally
    {
        [fileManager removeFileAtPath: tempFile handler: nil];
    }
}

- (void) testReadWhenNotOpen
{
    NSString * path = [self resource: @"file_100k" ofType: nil];
    
    NSInputStream * inputStream = [NSInputStream inputStreamWithFileAtPath: path];
    NSData * actual = [inputStream dd_readUntilEndOfStream];
    
    STAssertNil(actual, nil);
}

@end
