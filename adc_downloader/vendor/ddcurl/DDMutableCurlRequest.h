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

@class DDCurlMultipartForm;

/**
 * Represents a request to be executed.
 */
@interface DDMutableCurlRequest : NSObject
{
    NSURL * mUrl;
    DDCurlMultipartForm * mMultipartForm;
    NSString * mUsername;
    NSString * mPassword;
    NSString * mHTTPMethod;
    NSMutableDictionary * mHeaders;
    BOOL mAllowRedirects;
    BOOL mEnableCookies;
    long long mResumeOffset;
}

#pragma mark -
#pragma mark Class Constructors

/**
 * Create an autoreleased request.
 *
 * @return An autoreleased request
 */
+ (DDMutableCurlRequest *) request;

/**
 * Create an autoreleased request with a URL.
 *
 * @param url A URL
 * @return An autoreleased request
 */
+ (DDMutableCurlRequest *) requestWithURL: (NSURL *) url;

/**
 * Create an autoreleased request with a URL string.
 *
 * @param urlString A URL string
 * @return An autoreleased request
 */
+ (DDMutableCurlRequest *) requestWithURLString: (NSString *) urlString;

#pragma mark -
#pragma mark Constructors

/**
 * Create a new request.
 *
 * @return A new request
 */
- (id) init;

/**
 * Create a new request with a URL.
 *
 * @param url A URL
 * @return A new request
 */
- (id) initWithURL: (NSURL *) url;

/**
 * Create a new request with a URL string.
 *
 * @param urlString a URL string
 * @return A new request
 */
- (id) initWithURLString: (NSString *) urlString;

#pragma mark -
#pragma mark Properties

/**
 * Returns the URL.
 *
 * @return The URL
 */
- (NSURL *) URL;

/**
 * Sets the URL.
 *
 * @param URL A URL
 */
- (void) setURL: (NSURL *) URL;

/**
 * Sets the URL with a string.
 * 
 * @param urlString A URL string.
 */
- (void) setURLString: (NSString *) urlString;

/**
 * Returns the URL as a string.
 *
 * @return A URL string
 */
- (NSString *) urlString;

/**
 * Returns the username.
 *
 * @return The username
 */
- (NSString *) username;

/**
 * Sets the username.
 *
 * @param username The username
 */
- (void) setUsername: (NSString *) username;

/**
 * Returns the password.
 *
 * @return The password
 */
- (NSString *) password;

/**
 * Sets the password.
 *
 * @param password The password
 */
- (void) setPassword: (NSString *) password;

/**
 * Returns YES if redirects are allowed.
 *
 * @return YES if redirects are allowed.
 */
- (BOOL) allowRedirects;

/**
 * Sets if redirects are allowed.
 *
 * @param allowRedirects YES if redirects are allowed.
 */
- (void) setAllowRedirects: (BOOL) allowRedirects;

- (BOOL) enableCookies;
- (void) setEnableCookies: (BOOL) enableCookies;

- (long long) resumeOffset;
- (void) setResumeOffset: (long long) theResumeOffset;

/**
 * Returns the multipart form, or nil if there is no form.
 *
 * @return The multipart form
 */
- (DDCurlMultipartForm *) multipartForm;

/**
 * Sets the multipart form and change the method to POST.
 *
 * @param multipartForm The multipartform
 */
- (void) setMultipartForm: (DDCurlMultipartForm *) multipartForm;

/**
 * Returns the custom HTTP method, or nil if the default method should
 * be used.
 *
 * @return The custom HTTP method.
 */
- (NSString *) HTTPMethod;

/**
 * Sets the custom HTTP method.  By default the method is GET unless a
 * multipart form is set, which uses POST.
 *
 * @param HTTPMethod A custom HTTP method
 */
- (void) setHTTPMethod: (NSString *) HTTPMethod;

/**
 * Sets a HTTP header field.
 *
 * @param value The value of the header field
 * @param field The name of the header field
 */
- (void) setValue: (NSString *) value forHTTPHeaderField: (NSString *) field;

/**
 * Returns all headers set.
 *
 * @return All headers set.
 */
- (NSDictionary *) allHeaders;

@end
