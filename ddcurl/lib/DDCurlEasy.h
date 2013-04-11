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

@class DDCurlSlist;
@class DDCurlMultipartForm;

/**
 * An Objective-C wrapper around the <a
 * href="http://curl.haxx.se/libcurl/c/libcurl-easy.html">CURL easy
 * interface</a>.  This class provides a couple benefits over the
 * native C API.  First, all return code errors are translated to
 * exceptions.  This simplifies error handling, as the return code
 * does not need to be checked after every call.  Second, this class
 * takes care of memory management for data that needs to be kept
 * around until Curl is finished with it.
 */
@interface DDCurlEasy : NSObject
{
    @private
    CURL * mCurl;
    NSMutableDictionary * mProperties;
    char mErrorBuffer[CURL_ERROR_SIZE];
}

/**
 * Returns an error string for a CURL error code.
 *
 * @return An error string
 */
+ (NSString *) errorString: (CURLcode) errorCode;

/**
 * Returns the CURL easy handle, for direct manipulation.
 *
 * @return CURL CURL Eash handle
 */
- (CURL *) CURL;

#pragma mark -
#pragma mark Options

/**
 * Sets URL to deal with (CURLOPT_URL).
 *
 * @param url The actual URL to deal with.
 */
- (void) setUrl: (NSString *) url;

/**
 * Sets CURLOPT_NOPROGRESS.
 *
 * @param progress YES to enable the progress callback
 */
- (void) setProgress: (BOOL) progress;

/**
 * Sets CURLOPT_FOLLOWLOCATION.
 *
 * @param followLocation YES to follow redirect headers.
 */
- (void) setFollowLocation: (BOOL) followLocation;

/**
 * Sets CURLOPT_USERPWD.
 *
 * @param user Username
 * @param password Password
 */
- (void) setUser: (NSString *) user password: (NSString *) password;

/**
 * Sets CURLOPT_CUSTOMREQUEST.
 *
 * @param customRequest Custom request string
 */
- (void) setCustomRequest: (NSString *) customRequest;

/**
 * Sets CURLOPT_HTTPHEADER.
 *
 * @param httpHeaders Header linked list wrapper object
 */
- (void) setHttpHeaders: (DDCurlSlist *) httpHeaders;

/**
 * Sets CURLOPT_HTTPHEADER.
 *
 * @param httpHeaders Header linked list
 */
- (void) setCurlHttpHeaders: (struct curl_slist *) httpHeaders;

/**
 * Sets CURLOPT_HTTPPOST.
 *
 * @param httpPost HTTP post linked list wrapper object
 */
- (void) setHttpPost: (DDCurlMultipartForm *) httpPost;

/**
 * Sets CURLOPT_HTTPPOST.
 *
 * @param httpPost HTTP post linkned list
 */
- (void) setCurlHttpPost: (struct curl_httppost *) httpPost;

/**
 * Sets CURLOPT_CAINFO.
 *
 * @param caInfo File name of certificate authority info
 */
- (void) setCaInfo: (NSString *) caInfo;

/**
 * Sets CURLOPT_NOSIGNAL.
 *
 * @param useSignals NO means curl will not install any signal handlers.
 */
- (void) setUseSignals: (BOOL) useSignals;

/**
 * Sets CURLOPT_VERBOSE.
 *
 * @param verbose YES means turn on verbose information.
 */
- (void) setVerbose: (BOOL) verbose;

/**
 * Sets CURLOPT_COOKIEFILE.
 *
 * @param cookieFile File name of cookies
 */
- (void) setCookieFile: (NSString *) cookieFile;

/**
 * Sets CURLOPT_RESUME_FROM_LARGE.
 *
 * @param resumeFrom Resume from offest
 */
- (void) setResumeFromLarge: (curl_off_t) resumeFrom;

#if LIBCURL_VERSION_NUM > 0x070f05

/**
 * Sets CURLOPT_MAX_SEND_SPEED_LARGE.
 *
 * @param maxSendSpeed Maximum send speed
 */
- (void) setMaxSendSpeedLarge: (curl_off_t) maxSendSpeed;

/**
 * Sets CURLOPT_MAX_RECV_SPEED_LARGE.
 *
 * @param maxSendSpeed Maximum receive speed.
 */
- (void) setMaxReceiveSpeedLarge: (curl_off_t) maxReceiveSpeed;

#endif

#pragma mark -

/**
 * Perform the transfer.  This method does not throw exceptions, so the
 * return code should be checked for errors.
 *
 * @return CURL error code
 */
- (CURLcode) perform;

/**
 * Returns the error buffer as a null terminated C string.
 *
 * @return Error buffer
 */
- (const char *) errorBuffer;

/**
 * Returns the error string.
 *
 * @return Error string
 */
- (NSString *) errorString;

#pragma mark -
#pragma mark Informational

/**
 * Gets CURLINFO_RESPONSE_CODE.
 */
- (long) responseCode;

/**
 * Gets CURLINFO_CONTENT_TYPE
 */
- (NSString *) contentType;

/**
 * Gets CURLINFO_EFFECTIVE_URL
 */
- (NSString *) effectiveUrl;

#pragma mark -
#pragma mark Callback functions

- (void) setWriteData: (void *) writeData;

- (void) setWriteFunction: (curl_write_callback) writeFunction;

- (void) setWriteHeaderData: (void *) writeHeaderData;

- (void) setWriteHeaderFunction: (curl_write_callback) writeHeaderFunction;

- (void) setProgressData: (void *) progressData;

- (void) setProgressFunction: (curl_progress_callback) progressFunction;

- (void) setDebugData: (void *) debugData;

- (void) setDebugFunction: (curl_debug_callback) debugFunction;

- (void) setSslCtxData: (void *) sslCtxData;

- (void) setSslCtxFunction: (curl_ssl_ctx_callback) sslCtxFunction;

@end
