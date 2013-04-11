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

@class DDMutableCurlRequest;
@class DDCurlResponse;
@class DDCurlEasy;
@class DDCurlSlist;

/**
 * Loads URLs using libcurl via DDCurlEasy.  The delegate methods
 * allow an object to receive informational callbacks. To support
 * asynchronous behavior, a new thread is spawned for each connection.
 *
 * Note: The delegate methods are called on the main thread.
 *
 * @sa DDMutableCurlRequest, DDCurlResponse
 */
@interface DDCurlConnection : NSObject
{
    @private
    DDCurlEasy * mCurl;
    DDCurlResponse * mResponse;
    DDCurlSlist * mHeaders;
    BOOL mIsFirstData;
    BOOL mShouldCancel;

    id mDelegate;
}

+ (DDCurlConnection *) alloc;

/**
 * Create a new connection and start loading on a separate thread.
 *
 * @param request Request paramters for this connection
 * @param delegate Delegate for this connection
 *
 * @sa @link NSObject(DDCurlConnectionDelegate) @endlink
 */
- (id) initWithRequest: (DDMutableCurlRequest *) request
              delegate: (id) delegate;

/**
 * Cancels this request.  No more delegates will be sent after calling
 * this method.
 */
- (void) cancel;

@end

/**
 * Delegate methods for DDCurlConnection.
 */
@interface NSObject (DDCurlConnectionDelegate)

/**
 * Called when data has been received on a connection.
 *
 * @param connection The connection
 * @param data Data received
 */
- (void) dd_curlConnection: (DDCurlConnection *) connection
            didReceiveData: (NSData *) data;

/**
 * Called when a response from the server has been received.
 *
 * @param connection The connection
 * @param response Response from the server
 */
- (void) dd_curlConnection: (DDCurlConnection *) connection
        didReceiveResponse: (DDCurlResponse *) response;

/**
 * Called about once a second for progress updates.
 *
 * @param connection The connection
 * @param download Number of bytes downloaded so far
 * @param downloadTotal Total number of bytes to download, or 0 for unknown
 * @param upload Number of bytes uploaded so far
 * @param uploadTotal Total number of bytes to upload, or 0 for unknown
 */
- (void) dd_curlConnection: (DDCurlConnection *) connection
          progressDownload: (double) download
             downloadTotal: (double) downloadTotal
                    upload: (double) upload
               uploadTotal: (double) uploadTotal;

/**
 * Called when a connection successfully finished loading.
 *
 * @param connection The connection
 */
- (void) dd_curlConnectionDidFinishLoading: (DDCurlConnection *) connection;

/**
 * Called when a connection failed to load.
 *
 * @param connection The connection
 * @param error The error that caused the failure
 */
- (void) dd_curlConnection: (DDCurlConnection *) connection
          didFailWithError: (NSError *) error;

@end

/**
 * The DDCurl domain for NSError.
 */
extern NSString * DDCurlDomain;

