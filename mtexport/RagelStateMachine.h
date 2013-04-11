//
//  RagelStateMachine.h
//  mtexport
//
//  Created by Dave Dribin on 8/28/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RagelStateMachine : NSObject
{
@protected
    int cs, top;
}

- (int) executeWithData: (NSData *) data;

- (int) parseWithFileHandle: (NSFileHandle *) fileHandle;

- (int) parseWithFileHandle: (NSFileHandle *) fileHandle
                    emitEof: (BOOL) emitEof;

@end


@interface RagelStateMachine (Protected)

- (void) ragelInit;
- (int) executeWithBytes: (const void *) bytes length: (unsigned) length;
- (int) finish;

@end

#define RAGEL_EXEC_START \
- (int) executeWithBytes: (const void *) bytes length: (unsigned) length; \
{ \
    const char * p = bytes; \
    const char * pe = p + length; \


/*

%% write data noprefix;
 
- (void) ragelInit;
{
    %% write init;
}

- (int) executeWithBytes: (const void *) bytes length: (unsigned) length;
{
    const char * p = bytes;
    const char * pe = p + length;
    
    %% write exec;
    if ( cs == error )
        return -1;
    if ( cs >= first_final )
        return 1;
    return 0;
}

- (int) finish;
{
    %% write eof;
    if ( cs == error )
        return -1;
    if ( cs >= first_final )
        return 1;
    return 0;
}

 */