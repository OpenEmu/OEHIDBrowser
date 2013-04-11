//
//  DDTemporaryFile.m
//  nsurl
//
//  Created by Dave Dribin on 4/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDTemporaryFile.h"
#import "DDTemporaryDirectory.h"

@implementation DDTemporaryFile

+ (DDTemporaryFile *) temporaryFileWithName: (NSString *) name;
{
    return [[[self alloc] initWithName: name] autorelease];
}

- (id) initWithName: (NSString *) name;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mTemporaryDirectory = [[DDTemporaryDirectory alloc] init];
    mFullPath = [[[mTemporaryDirectory fullPath]
        stringByAppendingPathComponent: name] retain];
    
    return self;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [mTemporaryDirectory release];
    [mFullPath release];
    
    mTemporaryDirectory = nil;
    mFullPath = nil;
    [super dealloc];
}

- (NSString *) fullPath;
{
    return mFullPath;
}

@end
