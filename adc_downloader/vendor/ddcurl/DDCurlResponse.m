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

#import "DDCurlResponse.h"


@implementation DDCurlResponse

+ (DDCurlResponse *) response;
{
    return [[[self alloc] init] autorelease];
}

- (id) init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mHeaders = [[NSMutableDictionary alloc] init];
    mExpectedContentLength = -1;
    mStatusCode = 0;
    mMIMEType = nil;
    mEffectiveUrl = nil;
    
    return self;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [mMIMEType release];
    [mEffectiveUrl release];
    [mHeaders release];
    
    mMIMEType = nil;
    mEffectiveUrl = nil;
    mHeaders = nil;
    [super dealloc];
}

//=========================================================== 
//  effectiveUrl 
//=========================================================== 
- (NSString *) effectiveUrl
{
    return mEffectiveUrl; 
}

- (void) setEffectiveUrl: (NSString *) theEffectiveUrl
{
    if (mEffectiveUrl != theEffectiveUrl)
    {
        [mEffectiveUrl release];
        mEffectiveUrl = [theEffectiveUrl retain];
    }
}

//=========================================================== 
//  expectedContentLength 
//=========================================================== 
- (long long) expectedContentLength
{
    return mExpectedContentLength;
}

- (void) setExpectedContentLength: (long long) theExpectedContentLength
{
    mExpectedContentLength = theExpectedContentLength;
}

//=========================================================== 
//  MIMEType 
//=========================================================== 
- (NSString *) MIMEType
{
    return mMIMEType; 
}

- (void) setMIMEType: (NSString *) theMIMEType
{
    if (mMIMEType != theMIMEType)
    {
        [mMIMEType release];
        mMIMEType = [theMIMEType retain];
    }
}

//=========================================================== 
//  statusCode 
//=========================================================== 
- (int) statusCode
{
    return mStatusCode;
}

- (void) setStatusCode: (int) theStatusCode
{
    mStatusCode = theStatusCode;
}

- (void) setHeader: (NSString *) value withName: (NSString *) name;
{
    [mHeaders setObject: value forKey: [name lowercaseString]];
}

- (NSString *) headerWithName: (NSString *) name;
{
    return [mHeaders objectForKey: [name lowercaseString]];
}

@end
