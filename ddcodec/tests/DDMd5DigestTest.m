//
//  DDMd5DigestTest.m
//  DDCodec
//
//  Created by Dave Dribin on 6/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDMd5DigestTest.h"
#import "DDMd5Digest.h"

@implementation DDMd5DigestTest

- (void) testUTF8String;
{
    NSData * hash = [DDMd5Digest md5WithUTF8String: @"hello"];
    STAssertNotNil(hash, nil);
    const unsigned char expectedBytes[] = {
        0x5d, 0x41, 0x40, 0x2a, 0xbc, 0x4b, 0x2a, 0x76,
        0xb9, 0x71, 0x9d, 0x91, 0x10, 0x17, 0xc5, 0x92
    };
    NSData * expectedHash = [NSData dataWithBytes: expectedBytes
                                           length: sizeof(expectedBytes)];
    STAssertEqualObjects(hash, expectedHash, nil);
}

- (void) testStringWithUTF8String;
{
    NSString * hash = [DDMd5Digest md5HexWithUTF8String: @"hello"];
    STAssertNotNil(hash, nil);
    NSString * expectedHash = @"5d41402abc4b2a76b9719d911017c592";
    STAssertEqualObjects(hash, expectedHash, nil);
}

- (void) testStringWithFile;
{
    NSBundle * myBundle = [NSBundle bundleForClass: [self class]];
    NSString * path = [myBundle pathForResource: @"foo" ofType: @"txt"];
    NSString * hash = [DDMd5Digest md5HexWithFileAtPath: path];
    STAssertNotNil(hash, nil);
    NSString * expectedHash = @"e7bea2d8ef3c0f7d3141293055592826";
    STAssertEqualObjects(hash, expectedHash, nil);
}

- (void) testWithNonExistentFile;
{
    NSBundle * myBundle = [NSBundle bundleForClass: [self class]];
    NSString * path = [[myBundle resourcePath]
        stringByAppendingPathComponent: @"nonexistant.txt"];
    NSData * hash = [DDMd5Digest md5WithFileAtPath: path];
    STAssertNil(hash, nil);
}

@end
