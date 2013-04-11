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

#include <CoreServices/CoreServices.h>

#import "AdcDownloadController.h"
#import "DDCurl.h"
#import "ByteSizeFormatter.h"
#import "JRLog.h"

#if LIBCURLVERNUM < 0x070f05
# define ADC_DOWNLOAD_HAVE_THROTTLE NO
#else
# define ADC_DOWNLOAD_HAVE_THROTTLE YES
#endif

@interface AdcDownloadController (Private)

- (DDCurlResponse *) response;
- (void) setResponse: (DDCurlResponse *) theResponse;
- (NSString *) queryArgumentInUrl: (NSURL *) url forKey: (NSString *) key;

- (void) savePanelDidEnd: (NSSavePanel *) sheet
              returnCode: (int) returnCode
                 context: (void *) contextInfo;

- (void) downloadFinished;

- (void) alertDidEnd: (NSAlert *) alert
          returnCode: (int) returnCode
             context: (void *) contextInfo;

-(void) didPresentErrorWithRecovery: (BOOL) didRecover 
                            context: (void *) contextInfo;

@end

#pragma mark -

@implementation AdcDownloadController

+ (void) initialize;
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary * defaultValues = [NSMutableDictionary dictionary];
    
    [defaultValues setObject: [NSNumber numberWithInt: 100]
                                               forKey: @"Rate"];
    
    [defaultValues setObject: @"WARN" forKey: @"JRLogLevel"];

    [defaults registerDefaults: defaultValues];
}

- (id) init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mStatusText = @"";
    mSelectedRate = 0;
    mLimitString = @"100";
    mSelectedSpeed = 1;
    mResumeDownload = NO;
    mCanThrottle = ADC_DOWNLOAD_HAVE_THROTTLE;
    
    return self;
}

- (void) awakeFromNib;
{
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [mUrl release];
    [mLimitString release];
    [mStatusText release];
    [mConnection release];
    [mResponse release];
    [mError release];
    [mOutputFile release];
    
    mUrl = nil;
    mLimitString = nil;
    mStatusText = nil;
    mConnection = nil;
    mResponse = nil;
    mError = nil;
    mOutputFile = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Properties

//=========================================================== 
//  url 
//=========================================================== 
- (NSString *) url
{
    return mUrl; 
}

- (void) setUrl: (NSString *) theUrl
{
    if (mUrl != theUrl)
    {
        [mUrl release];
        mUrl = [theUrl retain];
    }
}

//=========================================================== 
//  selectedRate 
//=========================================================== 
- (int) selectedRate
{
    return mSelectedRate;
}

- (void) setSelectedRate: (int) theSelectedRate
{
    mSelectedRate = theSelectedRate;
}

//=========================================================== 
//  limitString 
//=========================================================== 
- (NSString *) limitString
{
    return mLimitString; 
}

- (void) setLimitString: (NSString *) theLimitString
{
    if (mLimitString != theLimitString)
    {
        [mLimitString release];
        mLimitString = [theLimitString retain];
    }
}

//=========================================================== 
//  selectedSpeed 
//=========================================================== 
- (int) selectedSpeed
{
    return mSelectedSpeed;
}

- (void) setSelectedSpeed: (int) theSelectedSpeed
{
    mSelectedSpeed = theSelectedSpeed;
}

//=========================================================== 
//  statusText 
//=========================================================== 
- (NSString *) statusText
{
    return mStatusText; 
}

- (void) setStatusText: (NSString *) theStatusText
{
    if (mStatusText != theStatusText)
    {
        [mStatusText release];
        mStatusText = [theStatusText retain];
    }
}
//=========================================================== 
//  error 
//=========================================================== 
- (NSError *) error
{
    return mError; 
}

- (void) setError: (NSError *) theError
{
    if (mError != theError)
    {
        [mError release];
        mError = [theError retain];
    }
}

//=========================================================== 
//  downloading 
//=========================================================== 
- (BOOL) downloading
{
    return mDownloading;
}

- (void) setDownloading: (BOOL) flag
{
    mDownloading = flag;
}

//=========================================================== 
//  resumeDownload 
//=========================================================== 
- (BOOL) resumeDownload
{
    return mResumeDownload;
}

- (void) setResumeDownload: (BOOL) flag
{
    mResumeDownload = flag;
}

- (BOOL) canThrottle;
{
    return mCanThrottle;
}

#pragma mark -
#pragma mark Actions

- (IBAction) download: (id) sender;
{
    JRLogDebug(@"Download URL: %@", mUrl);
    NSURL * url = [NSURL URLWithString: mUrl];
    NSString * path = [self queryArgumentInUrl: url forKey: @"path"];
    NSString * file = [path lastPathComponent];
    JRLogDebug(@"File: %@", file);
    JRLogDebug(@"Rate: %d, limit: %@, speed: %d", mSelectedRate, mLimitString,
          mSelectedSpeed);

    [self setResumeDownload: YES];
    
    NSSavePanel * panel = [NSSavePanel savePanel];
    [panel setAccessoryView: mAccessoryView];
    [panel beginSheetForDirectory: nil
                             file: file
                   modalForWindow: [self window]
                    modalDelegate: self
                   didEndSelector: @selector(savePanelDidEnd:returnCode:context:)
                      contextInfo: nil];
}

- (IBAction) cancel: (id) sender;
{
    [mConnection cancel];
    [mConnection release];
    mConnection = nil;
    [self downloadFinished];
}

#pragma mark -
#pragma mark NSApplication Delegate

- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) application
{
    return YES;
}

- (void) applicationWillTerminate: (NSNotification *) notification;
{
    [self cancel: nil];
}

#pragma mark -
#pragma mark DDCurl Delegate

- (void) dd_curlConnection: (DDCurlConnection *) connection
        didReceiveResponse: (DDCurlResponse *) response;
{
    JRLogDebug(@"Status code: %d", [response statusCode]);
    JRLogDebug(@"Location: %@", [response headerWithName: @"Location"]);
    JRLogDebug(@"Expected content length: %lld",
               [response expectedContentLength]);
    NSURL * url = [NSURL URLWithString: [response effectiveUrl]];
    NSString * path = [url path];
    NSString * file = [path lastPathComponent];
    JRLogDebug(@"Path: %@, file: %@", path, file);
    if (mExpectingRedirect)
    {
        if ([response statusCode] != 302)
        {
            JRLogDebug(@"Session no longer valid");
            [mConnection cancel];
            [self downloadFinished];
            NSAlert * alert = [[[NSAlert alloc] init] autorelease];
            [alert setMessageText: @"Session no longer valid"];
            [alert setInformativeText:
                @"Your ADC session has expired.  Please re-login and try again."];
            [alert addButtonWithTitle: @"OK"];
            [alert beginSheetModalForWindow: [self window]
                              modalDelegate: self
                             didEndSelector: @selector(alertDidEnd:returnCode:context:)
                                contextInfo: nil];
        }
        else
        {
            [mConnection cancel];
            [mConnection release];
            mConnection = nil;

            DDMutableCurlRequest * request =
                [DDMutableCurlRequest requestWithURLString: mUrl];
            [request setAllowRedirects: YES];
            [request setEnableCookies: YES];
            [request setResumeOffset: mResumeOffset];
            mConnection =
                [[DDCurlConnection alloc] initWithRequest: request
                                                 delegate: self];
            mExpectingRedirect = NO;
        }
    }
    [self setResponse: response];
}

- (void) dd_curlConnection: (DDCurlConnection *) connection
            didReceiveData: (NSData *) data;
{
    UpdateSystemActivity(OverallAct);
    if (connection == mConnection)
        [mOutputFile writeData: data];
}

- (void) dd_curlConnection: (DDCurlConnection *) connection
          progressDownload: (double) download
             downloadTotal: (double) downloadTotal
                    upload: (double) upload
               uploadTotal: (double) uploadTotal;
{
    if (downloadTotal != 0)
    {
        unsigned long long resume = 0;
        if (mResumeOffset <= downloadTotal)
            resume = mResumeOffset;
        unsigned long long downloadLong = download + resume;
        unsigned long long downloadTotalLong = downloadTotal + resume;
        double percentDown = (download + resume)/(downloadTotal + resume)*100;
        NSString * downloadString = [ByteSizeFormatter format: downloadLong];
//                                                    withUnits: ByteSizeKilobytes];
        NSString * downloadTotalString = [ByteSizeFormatter format: downloadTotalLong];
        
        [mProgressBar setIndeterminate: NO];
        [mProgressBar setMaxValue: 100.0];
        [mProgressBar setDoubleValue: percentDown];
        [self setStatusText:
            [NSString stringWithFormat: @"%@ of %@ (%.1f%%)",
                downloadString, downloadTotalString, percentDown]];
    }
    else if (download != 0)
    {
        [mProgressBar setIndeterminate: NO];
        [self setStatusText:
            [NSString stringWithFormat: @"Download %.0f bytes", download]];
    }
}

- (void) dd_curlConnectionDidFinishLoading: (DDCurlConnection *) connection;
{
    JRLogDebug(@"didFinishLoading");
    [self downloadFinished];
    mDownloading = NO;
    [mConnection release];
    mConnection = nil;
}

- (void) dd_curlConnection: (DDCurlConnection *) connection
          didFailWithError: (NSError *) error;
{
    JRLogDebug(@"didFailWithError: %@", error);
    [NSApp presentError: error
         modalForWindow: [self window]
               delegate: self
     didPresentSelector: @selector(didPresentErrorWithRecovery:context:)
            contextInfo: nil];
}


@end

#pragma mark -

@implementation AdcDownloadController (Private)

//=========================================================== 
//  response 
//=========================================================== 
- (DDCurlResponse *) response
{
    return mResponse; 
}

- (void) setResponse: (DDCurlResponse *) theResponse
{
    if (mResponse != theResponse)
    {
        [mResponse release];
        mResponse = [theResponse retain];
    }
}

- (NSString *) queryArgumentInUrl: (NSURL *) url forKey: (NSString *) key;
{
    NSString * query = [url query];
    NSArray * arguments = [query componentsSeparatedByString: @"&"];
    NSString * value = nil;
    for (unsigned i = 0; i < [arguments count]; i++)
    {
        NSString * argument = [arguments objectAtIndex: i];
        NSArray * keyValue = [argument componentsSeparatedByString: @"="];
        if ([[keyValue objectAtIndex: 0] isEqualToString: key])
        {
            value = [keyValue objectAtIndex: 1];
            value = [value stringByReplacingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
            break;
        }
    }
    return value;
}

- (void) savePanelDidEnd: (NSSavePanel *) sheet
              returnCode: (int) returnCode
                 context: (void *) contextInfo;
{
    if (returnCode != NSOKButton)
        return;
    
    NSString * file = [sheet filename];
    
    NSFileManager * manager = [NSFileManager defaultManager];
    
    NSDictionary * attributes =
        [manager fileAttributesAtPath: file traverseLink: YES];
    JRLogDebug(@"Attributes: %@", attributes);
    
    mResumeOffset = 0;
    if (attributes != nil)
    {
        if (mResumeDownload)
        {
            mResumeOffset = [attributes fileSize];
            mOutputFile = [[NSFileHandle fileHandleForUpdatingAtPath: file] retain];
            [mOutputFile seekToEndOfFile];
        }
        else
        {
            mOutputFile = [[NSFileHandle fileHandleForWritingAtPath: file] retain];
        }
    }
    else
    {
        [manager createFileAtPath: file
                         contents: [NSData data]
                       attributes: nil];
        mOutputFile = [[NSFileHandle fileHandleForWritingAtPath: file] retain];
    }
    
    DDMutableCurlRequest * request =
        [DDMutableCurlRequest requestWithURLString: mUrl];
    [request setAllowRedirects: NO];
    [request setEnableCookies: YES];
    mConnection =
        [[DDCurlConnection alloc] initWithRequest: request
                                         delegate: self];
    mExpectingRedirect = YES;
    [self setDownloading: YES];
}

- (void) downloadFinished;
{
    [mOutputFile closeFile];
    [mOutputFile release];
    mOutputFile = nil;
    [mProgressBar setIndeterminate: NO];
    [mProgressBar setDoubleValue: 0.0];
    [self setStatusText: @""];
    [self setDownloading: NO];
}

- (void) alertDidEnd: (NSAlert *) alert
          returnCode: (int) returnCode
             context: (void *) contextInfo;
{
    
}

-(void) didPresentErrorWithRecovery: (BOOL) didRecover 
                            context: (void *) contextInfo;
{
    [self downloadFinished];
    mDownloading = NO;
    [mConnection release];
    mConnection = nil;
}

@end

