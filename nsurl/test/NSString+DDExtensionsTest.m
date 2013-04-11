//
//  NSString+DDExtensionsTest.m
//  nsurl
//
//  Created by Dave Dribin on 5/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSString+DDExtensionsTest.h"
#import "DDExtensions.h"

@implementation NSString_DDExtensionsTest

- (void) testMimeTypeForExtensionFunction;
{
    STAssertEqualObjects(DDMimeTypeForExtension(@"png"), @"image/png", nil);
    STAssertEqualObjects(DDMimeTypeForExtension(@"zip"), @"application/zip", nil);
    STAssertEqualObjects(DDMimeTypeForExtension(@"txt"), @"text/plain", nil);
    STAssertEqualObjects(DDMimeTypeForExtension(@".unknown"), @"application/octet-stream", nil);
    STAssertEqualObjects(DDMimeTypeForExtension(@""), @"application/octet-stream", nil);
}

- (void) testPathMimeTypeCategory;
{
    STAssertEqualObjects([@"foo.png" dd_pathMimeType], @"image/png", nil);
    STAssertEqualObjects([@"foo.zip" dd_pathMimeType], @"application/zip", nil);
    STAssertEqualObjects([@"foo.txt" dd_pathMimeType], @"text/plain", nil);
    STAssertEqualObjects([@"foo.unknown" dd_pathMimeType], @"application/octet-stream", nil);
    STAssertEqualObjects([@"foo" dd_pathMimeType], @"application/octet-stream", nil);
}

- (void) testSplitBySeparator;
{
    NSArray * components = [@"foo: bar" dd_splitBySeparator: @":"];
    STAssertEquals([components count], 2U, nil);
    STAssertEqualObjects([components objectAtIndex: 0],
                         @"foo", nil);
    STAssertEqualObjects([components objectAtIndex: 1],
                         @" bar", nil);
    
    STAssertNil([@"foo bar" dd_splitBySeparator: @":"], nil);
}

@end
