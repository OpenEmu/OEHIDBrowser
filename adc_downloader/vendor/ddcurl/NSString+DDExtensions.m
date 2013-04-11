/*
 * Copyright (c) 2007 Dave Dribin
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use, copy,
 * modify, merge, publish, distribute, sublicense, and/or sell copies
 * of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
 * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#import "NSString+DDExtensions.h"


NSString * DDMimeTypeForExtension(NSString * extension)
{
    CFStringRef uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                            (CFStringRef) extension, NULL);
    
    CFStringRef cfMime = UTTypeCopyPreferredTagWithClass(uti, kUTTagClassMIMEType);
    CFRelease(uti);
    
    if (cfMime == NULL)
        return @"application/octet-stream";
    
    NSString * mime = [NSString stringWithString: (NSString *) cfMime];
    CFRelease(cfMime);
    
    return mime;
}

@implementation NSString (DDExtensions)

- (NSString *) dd_pathMimeType;
{
    return DDMimeTypeForExtension([self pathExtension]);
}

- (BOOL) dd_splitOnFirstSeparator: (NSString *) separator
                             left: (NSString **) left
                            right: (NSString **) right;
{
    NSRange range = [self rangeOfString: separator];
    if (range.location == NSNotFound)
        return NO;
    
    *left = [self substringToIndex: range.location];
    *right = [self substringFromIndex: range.location+1];
    return YES;
}

@end
