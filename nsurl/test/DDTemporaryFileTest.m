//
//  DDTemporaryFileTest.m
//  nsurl
//
//  Created by Dave Dribin on 5/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDTemporaryFileTest.h"
#import "DDTemporaryFile.h"

@implementation DDTemporaryFileTest

- (void) testTemporaryFile
{
    DDTemporaryFile * file = [[DDTemporaryFile alloc] initWithName: @"file.txt"];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSString * fullPath = [file fullPath];
    STAssertNotNil(fullPath, nil);
    
    [@"hello" writeToFile: fullPath atomically: NO];
    
    BOOL isDirectory = YES;
    STAssertTrue([fileManager fileExistsAtPath: fullPath isDirectory: &isDirectory],
                 nil);
    STAssertFalse(isDirectory, nil);
    
    [file release];
    STAssertFalse([fileManager fileExistsAtPath: fullPath isDirectory: nil],
                 nil);
}

@end
