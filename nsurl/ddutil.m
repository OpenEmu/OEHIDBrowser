/*
 *  ddutil.c
 *  nsurl
 *
 *  Created by Dave Dribin on 5/12/07.
 *  Copyright 2007 __MyCompanyName__. All rights reserved.
 *
 */

#include "ddutil.h"


void ddfprintf(FILE * stream, NSString * format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    NSString * string = [[NSString alloc] initWithFormat: format
                                               arguments: arguments];
    va_end(arguments);
    
    fprintf(stream, "%s", [string UTF8String]);
    [string release];
}

void ddprintf(NSString * format, ...)
{
    va_list arguments;
    va_start(arguments, format);
    NSString * string = [[NSString alloc] initWithFormat: format
                                               arguments: arguments];
    va_end(arguments);
    
    printf("%s", [string UTF8String]);
    [string release];
}
