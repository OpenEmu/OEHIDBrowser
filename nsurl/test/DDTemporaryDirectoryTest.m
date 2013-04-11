//
//  DDTemporaryDirectoryTest.m
//  nsurl
//
//  Created by Dave Dribin on 5/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDTemporaryDirectoryTest.h"
#import "DDTemporaryDirectory.h"
#import "JRLog.h"

@implementation DDTemporaryDirectoryTest

+ (void) initialize;
{
    [NSObject setDefaultJRLogLevel: JRLogLevel_Error];
}

- (void) testTemporaryDirectory;
{
    DDTemporaryDirectory * directory = [[DDTemporaryDirectory alloc] init];
    STAssertNotNil(directory, nil);
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    NSString * fullPath = [directory fullPath];
    STAssertNotNil([directory fullPath], nil);
    
    BOOL isDirectory = NO;
    STAssertTrue([fileManager fileExistsAtPath: fullPath isDirectory: &isDirectory],
                  nil);
    STAssertTrue(isDirectory, nil);
    
    NSString * tempFile = [fullPath stringByAppendingPathComponent: @"foo"];
    STAssertTrue([fileManager createFileAtPath: tempFile
                                      contents: [NSData data]
                                    attributes: nil],
                 nil);
    
    STAssertTrue([fileManager fileExistsAtPath: tempFile isDirectory: &isDirectory],
                 nil);
    STAssertFalse(isDirectory, nil);

    [directory release];
    STAssertFalse([fileManager fileExistsAtPath: tempFile isDirectory: nil],
                  nil);
    STAssertFalse([fileManager fileExistsAtPath: fullPath isDirectory: nil],
                  nil);
}

@end
