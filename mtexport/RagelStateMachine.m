//
//  RagelStateMachine.m
//  mtexport
//
//  Created by Dave Dribin on 8/28/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "RagelStateMachine.h"

@interface NSFileHandle (ReadInto)

- (int) readIntoBuffer: (void *) buffer
                length: (unsigned) length;
- (int) readIntoData: (NSMutableData *) data;

@end

@implementation NSFileHandle (ReadInto)

- (int) readIntoBuffer: (void *) buffer
                length: (unsigned) length;
{
    int fd = [self fileDescriptor];
    int result = read(fd, buffer, length);
    return result;
}


- (int) readIntoData: (NSMutableData *) data;
{
    return [self readIntoBuffer: [data mutableBytes]
                         length: [data length]];
}

@end

@implementation RagelStateMachine

- (id) init
{
    self = [super init];
    if (self == nil)
        return nil;
    
    [self ragelInit];
    
    return self;
}


- (int) executeWithData: (NSData *) data;
{
    return [self executeWithBytes: [data bytes]
                           length: [data length]];
}

- (int) parseWithFileHandle: (NSFileHandle *) fileHandle
{
    return [self parseWithFileHandle: fileHandle
                             emitEof: YES];
}

- (int) parseWithFileHandle: (NSFileHandle *) fileHandle
                    emitEof: (BOOL) emitEof;
{
    unsigned length = 500;
    NSMutableData * buffer = [NSMutableData dataWithLength: length];
    
    bool done = NO;
    while (!done)
    {
        int result = [fileHandle readIntoData: buffer];
        if (result >= 0)
        {
            const void * bytes = [buffer bytes];
            unsigned length = result;
            char null = '\0';
            if (result == 0)
            {
                if (emitEof)
                {
                    bytes = &null;
                    length = 1;
                }
                done = YES;
            }
            
            int rc = [self executeWithBytes: bytes
                                     length: length];
            if (rc < 0)
            {
                break;
            }
        }
        else
            done = YES;
    }
    
    return [self finish];
}

@end

@implementation RagelStateMachine (Protected)

- (void) ragelInit;
{
    [NSException raise: @"Unimplemented Ragel method"
                format: @"ragelInit"];
}

- (int) executeWithBytes: (const void *) bytes length: (unsigned) length;
{
    [NSException raise: @"Unimplemented Ragel method"
                format: @"executeWithBytes:length:"];
    return -1;
}

- (int) finish;
{
    [NSException raise: @"Unimplemented Ragel method"
                format: @"finish"];
    return -1;
}

@end
