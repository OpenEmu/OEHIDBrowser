//
//  NSInputStream+DDExtensions.m
//  nsurl
//
//  Created by Dave Dribin on 5/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSInputStream+DDExtensions.h"


@implementation NSInputStream (DDExtensions)

- (NSData *) dd_readUntilEndOfStream;
{
    uint8_t buffer[64 * 1024];
    NSMutableData * data = [NSMutableData data];
    
    int bytesRead;
    while ((bytesRead = [self read: buffer maxLength: sizeof(buffer)]) > 0)
    {
        [data appendBytes: buffer length: bytesRead];
    }
    
    if (bytesRead < 0)
        return nil;
    
    return data;
}

- (void) dd_readIntoFile: (NSString *) path;
{
    uint8_t buffer[64 * 1024];
    [[NSFileManager defaultManager] createFileAtPath: path
                                            contents: [NSData data]
                                          attributes: nil];
    NSFileHandle * fileHandle = [NSFileHandle fileHandleForWritingAtPath: path];
    NSAssert(fileHandle != nil, @"File handle not nil");
    
    int bytesRead;
    while ((bytesRead = [self read: buffer maxLength: sizeof(buffer)]) > 0)
    {
        NSData * data = [NSData dataWithBytesNoCopy: buffer
                                             length: bytesRead
                                       freeWhenDone: NO];
        [fileHandle writeData: data];
        [[data retain] release];
    }
    
    return;
}

@end
