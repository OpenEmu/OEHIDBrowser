//
//  NSData+DDExtensions.m
//  nsurl
//
//  Created by Dave Dribin on 5/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSData+DDExtensions.h"


@implementation NSMutableData (DDExtensions)

- (void) dd_appendUTF8String: (NSString *) string;
{
    [self appendData: [string dataUsingEncoding: NSUTF8StringEncoding]];
}

- (void) dd_appendUTF8Format: (NSString *) format, ...;
{
    va_list argList;
    va_start(argList, format);
    NSString * string = [[[NSString alloc] initWithFormat: format
                                                arguments: argList]
        autorelease];
    va_end(argList);
    [self dd_appendUTF8String: string];
}

@end
