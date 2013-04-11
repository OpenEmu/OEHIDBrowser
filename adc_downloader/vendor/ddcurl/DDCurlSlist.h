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

#import <Cocoa/Cocoa.h>

struct curl_slist;

/**
 * An Objective-C wrapper arond struct curl_slist.
 */
@interface DDCurlSlist : NSObject
{
    @private
    struct curl_slist * mSlist;
    NSMutableArray * mUtf8Data;
}

/**
 * Createn an autorelease DDCurlSlist
 */
+ (DDCurlSlist *) slist;

/**
 * Add a UTF-8 string to the list.
 *
 * @param string UTF-8 string to add
 */
- (void) appendUtf8String: (const char *) string;

/**
 * Add a string to the list.
 *
 * @param string String to add
 */
- (void) appendString: (NSString *) string;

/**
 * Free all elements of the list
 */
- (void) freeAll;

/**
 * Returns the underlying struct curl_slist.
 *
 * @return The underlying struct curl_slist.
 */
- (struct curl_slist *) curl_slist;

@end
