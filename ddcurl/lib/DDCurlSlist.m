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

#import "DDCurlSlist.h"
#import "curl/curl.h"


@implementation DDCurlSlist

+ (DDCurlSlist *) slist;
{
    return [[[self alloc] init] autorelease];
}

- (id) init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mSlist = 0;
    mUtf8Data = [[NSMutableArray alloc] init];
    
    return self;
}

- (void) dealloc;
{
    [self freeAll];
    [super dealloc];
}

- (void) appendUtf8String: (const char *) string;
{
    struct curl_slist * temp = curl_slist_append(mSlist, string);
    if (temp == 0)
    {
        NSLog(@"Could not slist_append: %s", string);
        return;
    }
    
    mSlist = temp;
}

- (void) appendString: (NSString *) string;
{
    NSMutableData * utf8Data = [NSMutableData dataWithData:
        [string dataUsingEncoding: NSUTF8StringEncoding]];
    char null = '\0';
    [utf8Data appendBytes: &null length: 1];
    [mUtf8Data addObject: utf8Data];
    [self appendUtf8String: [utf8Data bytes]];
}

- (void) freeAll;
{
    [mUtf8Data removeAllObjects];
    if (mSlist != 0)
    {
        curl_slist_free_all(mSlist);
        mSlist = 0;
    }
}

- (struct curl_slist *) curl_slist;
{
    return mSlist;
}

@end
