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

#import "DDMutableCurlRequest.h"


@implementation DDMutableCurlRequest

#pragma mark -
#pragma mark Class Constructors

+ (DDMutableCurlRequest *) request;
{
    return [[[self alloc] init] autorelease];
}

+ (DDMutableCurlRequest *) requestWithURL: (NSURL *) url;
{
    return [[[self alloc] initWithURL: url] autorelease];
}

+ (DDMutableCurlRequest *) requestWithURLString: (NSString *) urlString;
{
    return [[[self alloc] initWithURLString: urlString] autorelease];
}

#pragma mark -
#pragma mark Constructors

- (id) init;
{
    return [self initWithURL: nil];
}

- (id) initWithURL: (NSURL *) url;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mUrl = [url retain];
    mMultipartForm = nil;
    mAllowRedirects = NO;
    mEnableCookies = YES;
    mResumeOffset = 0LL;
    mHeaders = [[NSMutableDictionary alloc] init];
    
    return self;
}

- (id) initWithURLString: (NSString *) urlString;
{
    return [self initWithURL: [NSURL URLWithString: urlString]];
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [mUrl release];
    [mMultipartForm release];
    [mUsername release];
    [mPassword release];
    
    mUrl = nil;
    mMultipartForm = nil;
    mUsername = nil;
    mPassword = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Properties

//=========================================================== 
//  URL 
//=========================================================== 
- (NSURL *) URL
{
    return mUrl; 
}

- (void) setURL: (NSURL *) theURL
{
    if (mUrl != theURL)
    {
        [mUrl release];
        mUrl = [theURL retain];
    }
}

- (NSString *) urlString;
{
    return [mUrl absoluteString];
}

- (void) setURLString: (NSString *) urlString;
{
    [self setURL: [NSURL URLWithString: urlString]];
}

//=========================================================== 
//  username 
//=========================================================== 
- (NSString *) username
{
    return mUsername; 
}

- (void) setUsername: (NSString *) theUsername
{
    if (mUsername != theUsername)
    {
        [mUsername release];
        mUsername = [theUsername retain];
    }
}

//=========================================================== 
//  password 
//=========================================================== 
- (NSString *) password
{
    return mPassword; 
}

- (void) setPassword: (NSString *) thePassword
{
    if (mPassword != thePassword)
    {
        [mPassword release];
        mPassword = [thePassword retain];
    }
}

//=========================================================== 
// - allowRedirects
//=========================================================== 
- (BOOL) allowRedirects
{
    return mAllowRedirects;
}

//=========================================================== 
// - setAllowRedirects:
//=========================================================== 
- (void) setAllowRedirects: (BOOL) flag
{
    mAllowRedirects = flag;
}

//=========================================================== 
//  enableCookies 
//=========================================================== 
- (BOOL) enableCookies
{
    return mEnableCookies;
}

- (void) setEnableCookies: (BOOL) flag
{
    mEnableCookies = flag;
}

//=========================================================== 
//  resumeOffset 
//=========================================================== 
- (long long) resumeOffset
{
    return mResumeOffset;
}

- (void) setResumeOffset: (long long) theResumeOffset
{
    mResumeOffset = theResumeOffset;
}

//=========================================================== 
//  multipartForm 
//=========================================================== 
- (DDCurlMultipartForm *) multipartForm
{
    return mMultipartForm; 
}

- (void) setMultipartForm: (DDCurlMultipartForm *) theMultipartForm
{
    if (mMultipartForm != theMultipartForm)
    {
        [mMultipartForm release];
        mMultipartForm = [theMultipartForm retain];
    }
}

//=========================================================== 
//  HTTPMethod 
//=========================================================== 
- (NSString *) HTTPMethod
{
    return mHTTPMethod; 
}

- (void) setHTTPMethod: (NSString *) theHTTPMethod
{
    if (mHTTPMethod != theHTTPMethod)
    {
        [mHTTPMethod release];
        mHTTPMethod = [theHTTPMethod retain];
    }
}

- (void) setValue: (NSString *) value forHTTPHeaderField: (NSString *) field;
{
    [mHeaders setObject: value forKey: [field lowercaseString]];
}

- (NSDictionary *) allHeaders;
{
    return mHeaders;
}

@end
