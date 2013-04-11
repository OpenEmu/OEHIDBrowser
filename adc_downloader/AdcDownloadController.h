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

@class DDCurlConnection;
@class DDCurlResponse;

@interface AdcDownloadController : NSWindowController
{
    IBOutlet NSProgressIndicator * mProgressBar;
    IBOutlet NSView * mAccessoryView;
    
    NSString * mUrl;
    int mSelectedRate;
    NSString * mLimitString;
    int mSelectedSpeed;
    NSString * mStatusText;
    DDCurlConnection * mConnection;
    DDCurlResponse * mResponse;
    NSError * mError;
    BOOL mDownloading;
    BOOL mResumeDownload;
    unsigned long long mResumeOffset;
    BOOL mCanThrottle;
    NSFileHandle * mOutputFile;
    BOOL mExpectingRedirect;
}

#pragma mark -
#pragma mark Properties

- (NSString *) url;
- (void) setUrl: (NSString *) theUrl;

- (int) selectedRate;
- (void) setSelectedRate: (int) theSelectedRate;

- (NSString *) limitString;
- (void) setLimitString: (NSString *) theLimitString;

- (int) selectedSpeed;
- (void) setSelectedSpeed: (int) theSelectedSpeed;

- (NSString *) statusText;
- (void) setStatusText: (NSString *) theStatusText;

- (NSError *) error;
- (void) setError: (NSError *) theError;

- (BOOL) downloading;
- (void) setDownloading: (BOOL) flag;

- (BOOL) resumeDownload;
- (void) setResumeDownload: (BOOL) flag;

- (BOOL) canThrottle;

#pragma mark -
#pragma mark Actions

- (IBAction) download: (id) sender;
- (IBAction) cancel: (id) sender;

#pragma mark -
#pragma mark DDCurl Delegate

- (void) dd_curlConnection: (DDCurlConnection *) connection
        didReceiveResponse: (DDCurlResponse *) response;

- (void) dd_curlConnection: (DDCurlConnection *) connection
            didReceiveData: (NSData *) data;

- (void) dd_curlConnection: (DDCurlConnection *) connection
          progressDownload: (double) download
             downloadTotal: (double) downloadTotal
                    upload: (double) upload
               uploadTotal: (double) uploadTotal;

- (void) dd_curlConnectionDidFinishLoading: (DDCurlConnection *) connection;

- (void) dd_curlConnection: (DDCurlConnection *) connection
          didFailWithError: (NSError *) error;

@end
