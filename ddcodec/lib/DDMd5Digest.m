//
//  DDMd5Digest.m
//  DDCodec
//
//  Created by Dave Dribin on 6/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDMd5Digest.h"


@implementation DDMd5Digest

#pragma mark -
#pragma mark MD5 Data Convenience Methods

+ (NSData *) md5WithData: (NSData *) data;
{
    DDMd5Digest * digest = [self md5Digest];
    [digest updateWithData: data];
    return [digest final];
}

+ (NSData *) md5WithUTF8String: (NSString *) string;
{
    return [self md5WithData: [string dataUsingEncoding: NSUTF8StringEncoding]];
}

+ (NSData *) md5WithInputStream: (NSInputStream *) stream;
{
    DDMd5Digest * digest = [self md5Digest];
    unsigned char buffer[64 * 1024];
    while (YES)
    {
        int bytesRead = [stream read: buffer maxLength: sizeof(buffer)];
        if (bytesRead <= 0)
            break;
        [digest updateWithBytes: buffer length: bytesRead];
    }
    
    return [digest final];
}

+ (NSData *) md5WithFileAtPath: (NSString *)  path;
{
    NSFileManager * manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath: path])
        return nil;

    NSInputStream * fileStream = [NSInputStream inputStreamWithFileAtPath: path];
    if (fileStream == nil)
        return nil;
    
    [fileStream open];
    NSData * hash = [self md5WithInputStream: fileStream];
    [fileStream close];
    return hash;
}

#pragma mark -
#pragma mark MD5 String Convenience Methods

+ (NSString *) hexStringWithData: (NSData *) data;
{
    unsigned length = [data length];
    const unsigned char * bytes = [data bytes];
    NSMutableString * hash = [NSMutableString stringWithCapacity: length*2];
    unsigned i;
    for (i = 0; i < length; i++)
    {
        [hash appendFormat: @"%02x", bytes[i]];
    }
    
    return [[hash copy] autorelease];
}

+ (NSString *) md5HexWithData: (NSData *) data;
{
    return [self hexStringWithData: [self md5WithData: data]];
}

+ (NSString *) md5HexWithUTF8String: (NSString *) string;
{
    return [self hexStringWithData: [self md5WithUTF8String: string]];
}

+ (NSString *) md5HexWithInputStream: (NSInputStream *) stream;
{
    return [self hexStringWithData: [self md5WithInputStream: stream]];
}

+ (NSString *) md5HexWithFileAtPath: (NSString *)  path;
{
    return [self hexStringWithData: [self md5WithFileAtPath: path]];
}

#pragma mark -

+ (DDMd5Digest *) md5Digest;
{
    return [[[self alloc] init] autorelease];
}

- (id) init
{
    if ([super init] == nil)
        return nil;
    
    EVP_MD_CTX_init(&mContext);
    EVP_DigestInit_ex(&mContext, EVP_md5(), NULL);
    
    return self;
}

- (void) dealloc
{
    EVP_MD_CTX_cleanup(&mContext);
    [super dealloc];
}

- (void) updateWithBytes: (const void *) bytes length: (unsigned) length;
{
    EVP_DigestUpdate(&mContext, bytes, length);
}

- (void) updateWithData: (NSData *) data;
{
    [self updateWithBytes: [data bytes] length: [data length]];
}

- (size_t) digestSize;
{
    return EVP_MD_CTX_size(&mContext);
}

- (unsigned) blockSize;
{
    return EVP_MD_CTX_block_size(&mContext);
}

- (NSData *) final;
{
    size_t size = [self digestSize];
    unsigned char * hash = alloca(size);
    EVP_DigestFinal_ex(&mContext, hash, NULL);
    
    return [NSData dataWithBytes: hash length: size];
}

@end
