//
//  DDMd5Digest.h
//  DDCodec
//
//  Created by Dave Dribin on 6/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <openssl/evp.h>

@interface DDMd5Digest : NSObject
{
    EVP_MD_CTX mContext;
}

#pragma mark -
#pragma mark MD5 Data Convenience Methods

+ (NSData *) md5WithData: (NSData *) data;

+ (NSData *) md5WithUTF8String: (NSString *) string;

+ (NSData *) md5WithInputStream: (NSInputStream *) stream;

+ (NSData *) md5WithFileAtPath: (NSString *)  path;

#pragma mark -
#pragma mark MD5 String Convenience Methods

+ (NSString *) hexStringWithData: (NSData *) data;

+ (NSString *) md5HexWithData: (NSData *) data;

+ (NSString *) md5HexWithUTF8String: (NSString *) string;

+ (NSString *) md5HexWithInputStream: (NSInputStream *) stream;

+ (NSString *) md5HexWithFileAtPath: (NSString *)  path;

#pragma mark -

+ (DDMd5Digest *) md5Digest;

- (void) updateWithBytes: (const void *) bytes length: (unsigned) length;

- (void) updateWithData: (NSData *) data;

- (size_t) digestSize;

- (unsigned) blockSize;

- (NSData *) final;


@end
