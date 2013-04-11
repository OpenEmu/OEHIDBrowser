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


/**
 * Represents a response sent from the server.
 */
@interface DDCurlResponse : NSObject
{
    @private
    long long mExpectedContentLength;
    int mStatusCode;
    NSString * mMIMEType;
    NSString * mEffectiveUrl;
    NSMutableDictionary * mHeaders;
}

/**
 * Creates an autoreleased response.
 *
 * @return An autoreleased response
 */
+ (DDCurlResponse *) response;

- (NSString *) effectiveUrl;
- (void) setEffectiveUrl: (NSString *) theEffectiveUrl;

/**
 * Returns the expected content length, or -1 if the server has not
 * provided a content length.
 *
 * @return The expected content length
 */
- (long long) expectedContentLength;

/**
 * Sets the expected content length.
 *
 * @param expectedContentLength The expected content length
 */
- (void) setExpectedContentLength: (long long) expectedContentLength;

/**
 * Returns the MIME type of the content for this response.
 *
 * @return the MIME type of the content for this response
 */
- (NSString *) MIMEType;

/**
 * Sets the MIME type of the content for this response.
 *
 * @param MIMEType A MIME type
 */
- (void) setMIMEType: (NSString *) MIMEType;

/**
 * Returns the status code of this response or -1 if the protocol does
 * not utilize status codes.
 *
 * @return The status code
 */
- (int) statusCode;

/**
 * Sets the status code of this response.
 *
 * @param statusCode A status code
 */
- (void) setStatusCode: (int) statusCode;

/**
 * Sets a header value.
 *
 * @param header The header value
 * @param name The name of the header
 */
- (void) setHeader: (NSString *) header withName: (NSString *) name;

/**
 * Returns the value for a header.
 *
 * @return The value for a header
 */
- (NSString *) headerWithName: (NSString *) name;


@end
