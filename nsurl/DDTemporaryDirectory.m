//
//  DDTemporaryDirectory.m
//  nsurl
//
//  Created by Dave Dribin on 5/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDTemporaryDirectory.h"
#include <unistd.h>
#import "JRLog.h"


@implementation DDTemporaryDirectory

+ (DDTemporaryDirectory *) temporaryDirectory;
{
    return [[[self alloc] init] autorelease];
}

- (id) init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    NSString * tempDir = NSTemporaryDirectory();
    if (tempDir == nil)
        tempDir = @"/tmp";
    
    NSString * template = [tempDir stringByAppendingPathComponent: @"temp.XXXXXX"];
    JRLogDebug(@"Template: %@", template);
    const char * fsTemplate = [template fileSystemRepresentation];
    NSMutableData * bufferData = [NSMutableData dataWithBytes: fsTemplate
                                                       length: strlen(fsTemplate)+1];
    char * buffer = [bufferData mutableBytes];
    JRLogDebug(@"FS Template: %s", buffer);
    char * result = mkdtemp(buffer);
    NSString * temporaryDirectory = [[NSFileManager defaultManager]
            stringWithFileSystemRepresentation: buffer
                                        length: strlen(buffer)];
    if (result == NULL)
    {
        JRLogWarn(@"Could not create temporary dir: %@, %s", temporaryDirectory,
                  strerror(errno));
        [self release];
        return nil;
    }
    
    mFullPath = [temporaryDirectory retain];
    
    return self;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [[NSFileManager defaultManager] removeFileAtPath: mFullPath
                                             handler: nil];
    [mFullPath release];
    
    mFullPath = nil;
    [super dealloc];
}

- (NSString *) fullPath;
{
    return mFullPath;
}

@end
