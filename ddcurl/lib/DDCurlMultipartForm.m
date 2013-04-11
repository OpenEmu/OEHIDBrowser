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

#import "DDCurlMultipartForm.h"
#import "DDExtensions.h"


@implementation DDCurlMultipartForm

+ (DDCurlMultipartForm *) form;
{
    return [[[self alloc] init] autorelease];
}

- (id) init
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mFirst = NULL;
    mLast = NULL;
    
    return self;
}

- (void) dealloc
{
    curl_formfree(mFirst);
    [super dealloc];
}

- (void) addString: (NSString *) string withName: (NSString *) name;
{
    curl_formadd(&mFirst, &mLast,
                 CURLFORM_COPYNAME, [name UTF8String],
                 CURLFORM_COPYCONTENTS, [string UTF8String],
                 CURLFORM_END);
}

- (void) addInt: (int) number withName: (NSString *) name;
{
    NSString * string = [NSString stringWithFormat: @"%d", number];
    [self addString: string withName: name];
}

- (void) addFile: (NSString *) path withName: (NSString *) name;
{
    [self addFile: path withName: name
      contentType: [path dd_pathMimeType]];
}

- (void) addFile: (NSString *) path withName: (NSString *) name
     contentType: (NSString *) contentType;
{
    curl_formadd(&mFirst, &mLast,
                 CURLFORM_COPYNAME, [name UTF8String],
                 CURLFORM_FILE, [[path stringByExpandingTildeInPath] UTF8String],
                 CURLFORM_CONTENTTYPE, [contentType UTF8String],
                 CURLFORM_END);
}

- (struct curl_httppost *) curl_httppost;
{
    return mFirst;
}

@end
