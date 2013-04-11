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
#import "curl/curl.h"

/**
 * An Objective-C wrapper around struct curl_httppost for multipart forms.
 */
@interface DDCurlMultipartForm : NSObject
{
    struct curl_httppost * mFirst;
    struct curl_httppost * mLast;
}

/**
 * Create an autoreleased form.
 */
+ (DDCurlMultipartForm *) form;

/**
 * Add a string field.
 *
 * @param string String field
 * @param name Name of field
 */
- (void) addString: (NSString *) string withName: (NSString *) name;

/**
 * Add an integer number field.
 *
 * @param number Number field
 * @param name Name of field
 */
- (void) addInt: (int) number withName: (NSString *) name;

/**
 * Add a file field with the content type is chosen from the file's
 * extension.
 *
 * @param path Path to file
 * @param name Name of field
 */
- (void) addFile: (NSString *) path withName: (NSString *) name;

/**
 * Add a file field with the specified content type.
 *
 * @param path Path to file
 * @param name Name of field
 * @param contentType Content type of this file
 */
- (void) addFile: (NSString *) path withName: (NSString *) name
     contentType: (NSString *) contentType;

/**
 * Returns the underlying struct curl_httppost structure.
 *
 * @return The underlying struct curl_httppost structure.
 */
- (struct curl_httppost *) curl_httppost;

@end
