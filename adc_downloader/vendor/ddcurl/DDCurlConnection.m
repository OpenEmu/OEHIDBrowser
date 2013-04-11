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

#import "DDCurlConnection.h"
#import "DDMutableCurlRequest.h"
#import "DDCurlResponse.h"
#import "DDCurlMultipartForm.h"
#import "DDCurlEasy.h"
#import "DDCurlSlist.h"
#import "curl/curl.h"

#include <openssl/ssl.h>
#include <Security/SecTrust.h>
#include <Security/SecCertificate.h>

NSString * DDCurlDomain = @"DDCurlDomain";

#pragma mark -
#pragma mark Static functions

static BOOL splitField(NSString * string, NSString * separator,
                       NSString ** left, NSString ** right);

static size_t staticWriteData(char * buffer, size_t size, size_t nmemb,
                              void * userData);

static size_t staticWriteHeader(char * buffer, size_t size, size_t nmemb,
                                void * userData);

static int staticProgress(void * clientp,
                          double dltotal,
                          double dlnow,
                          double ultotal,
                          double ulnow);

static int staticDebug(CURL *handle, curl_infotype type,
                       char *data, size_t size, void *userptr);

static CURLcode staticSslContext(CURL *curl, void *ssl_ctx, void *userptr);

#pragma mark -

@interface DDCurlConnection (Private)

- (void) threadMain: (DDMutableCurlRequest *) request;
- (void) didFinish: (NSError *) error;

- (void) setResponseInfo;

#pragma mark -
#pragma mark DDCurlEasy Callbacks

- (size_t) writeData: (char *) buffer size: (size_t) size
               nmemb: (size_t) nmemb;

- (size_t) writeHeader: (char *) buffer size: (size_t) size
                 nmemb: (size_t) nmemb;

- (int) progressDownload: (double) download
           downloadTotal: (double) downloadTotal
                  upload: (double) upload
             uploadTotal: (double) uploadTotal;

- (int) debug: (CURL *) handle
         type: (curl_infotype) type
         data: (char *) data
         size: (size_t) size;

- (CURLcode) sslContext: (CURL *) handle
                context: (void *) void_ssl_context;

#pragma mark -
#pragma mark Delegation

- (void) dd_curlConnection: (DDCurlConnection *) connection
            didReceiveData: (NSData *) data;
- (void) callDidReceiveDataDelegate: (NSData *) data;

- (void) dd_curlConnection: (DDCurlConnection *) connection
        didReceiveResponse: (DDCurlResponse *) response;
- (void) callDidReceiveResponse: (DDCurlResponse *) response;

- (void) dd_curlConnection: (DDCurlConnection *) connection
          progressDownload: (double) download
             downloadTotal: (double) downloadTotal
                    upload: (double) upload
               uploadTotal: (double) uploadTotal;
- (void) callProgressDownload: (NSArray *) arguments;

- (void) dd_curlConnectionDidFinishLoading: (DDCurlConnection *) connection;


@end

#pragma mark -

@implementation DDCurlConnection

+ (DDCurlConnection *) alloc;
{
    return [super alloc];
}

- (id) initWithRequest: (DDMutableCurlRequest *) request
              delegate: (id) delegate;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mDelegate = delegate;
    mCurl = [[DDCurlEasy alloc] init];
    mResponse = [[DDCurlResponse alloc] init];
    mShouldCancel = NO;
    [NSThread detachNewThreadSelector: @selector(threadMain:)
                             toTarget: self
                           withObject: request];
    
    return self;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [mCurl release];
    [mResponse release];
    [mHeaders release];
    
    mCurl = nil;
    mResponse = nil;
    mHeaders = nil;
    [super dealloc];
}

- (void) cancel;
{
    mShouldCancel = YES;
}

@end

#pragma mark -
#pragma mark Static functions

BOOL splitField(NSString * string, NSString * separator,
                NSString ** left, NSString ** right)
{
    NSRange range = [string rangeOfString: separator];
    if (range.location == NSNotFound)
        return NO;
    
    *left = [string substringToIndex: range.location];
    *right = [string substringFromIndex: range.location+1];
    return YES;
}

static size_t staticWriteData(char * buffer, size_t size, size_t nmemb,
                              void * userData)
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    DDCurlConnection * connection = (DDCurlConnection *) userData;
    size_t result = [connection writeData: buffer size: size nmemb: nmemb];
    [pool release];
    return result;
}

static size_t staticWriteHeader(char * buffer, size_t size, size_t nmemb,
                                void * userData)
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    DDCurlConnection * connection = (DDCurlConnection *) userData;
    size_t result = [connection writeHeader: buffer size: size nmemb: nmemb];
    [pool release];
    return result;
}

static int staticProgress(void * clientp,
                          double dltotal,
                          double dlnow,
                          double ultotal,
                          double ulnow)
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    DDCurlConnection * connection = (DDCurlConnection *) clientp;
    int result = [connection progressDownload: dlnow
                                downloadTotal: dltotal
                                       upload: ulnow
                                  uploadTotal: ultotal];
    [pool release];
    return result;
}

static int staticDebug(CURL *handle, curl_infotype type,
                       char *data, size_t size, void *userptr)
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    DDCurlConnection * connection = (DDCurlConnection *) userptr;
    int result = [connection debug: handle
                              type: type
                              data: data
                              size: size];
    [pool release];
    return result;
}

static CURLcode staticSslContext(CURL *curl, void *ssl_ctx, void *userptr)
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    DDCurlConnection * connection = (DDCurlConnection *) userptr;
    CURLcode result = [connection sslContext: curl context: ssl_ctx];
    [pool release];
    return result;
}

#pragma mark -

@implementation DDCurlConnection (Private)

- (void) threadMain: (DDMutableCurlRequest *) request
{
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    @try
    {
        [mCurl setWriteData: self];
        [mCurl setWriteFunction: staticWriteData];

        [mCurl setWriteHeaderData: self];
        [mCurl setWriteHeaderFunction: staticWriteHeader];

        [mCurl setProgressData: self];
        [mCurl setProgressFunction: staticProgress];
        [mCurl setProgress: YES];

        [mCurl setDebugData: self];
        [mCurl setDebugFunction: staticDebug];
        [mCurl setVerbose: YES];
        
        [mCurl setUseSignals: NO];
        
        [mCurl setSslCtxData: self];
        [mCurl setSslCtxFunction: staticSslContext];
        // It's important to disable the CAs that came with libcurl, as some
        // certs that come with libcurl conflict with the OS X certs.  We
        // want to add our certs to an emtpy X509 store.
        [mCurl setCaInfo: nil];
       
        [mCurl setFollowLocation: [request allowRedirects]];
        if ([request enableCookies])
            [mCurl setCookieFile: @""];
        [mCurl setResumeFromLarge: [request resumeOffset]];
        
        DDCurlMultipartForm * form = [request multipartForm];
        if (form != nil)
            [mCurl setHttpPost: form];
        
        DDCurlSlist * headers = [DDCurlSlist slist];
        NSDictionary * allHeaders = [request allHeaders];
        NSString * name;
        NSEnumerator * e = [allHeaders keyEnumerator];
        while (name = [e nextObject])
        {
            NSString * value = [allHeaders objectForKey: name];
            NSString * header = [NSString stringWithFormat: @"%@: %@",
                name, value];
            [headers appendString: header];
        }
        [mCurl setHttpHeaders: headers];
        
        NSString * httpMethod = [request HTTPMethod];
        if (httpMethod != nil)
        {
            [mCurl setCustomRequest: httpMethod];
        }
        
        [mCurl setUser: [request username] password: [request password]];
        [mCurl setUrl: [request urlString]];
        
        /*
         * Make sure to call this final method on the main thread in order to
         * "kick" the run loop into action.
         */
        mIsFirstData = YES;
        mShouldCancel = NO;
        CURLcode performResult = [mCurl perform];
        if (performResult == CURLE_OK)
        {
            if (mIsFirstData)
                [self setResponseInfo];
            [self performSelectorOnMainThread: @selector(didFinish:)
                                   withObject: nil
                                waitUntilDone: YES];
        }
        else
        {
            NSString * errorString = [mCurl errorString];
            NSString * reason;
            if ([errorString isEqualToString: @""])
                reason = [DDCurlEasy errorString: performResult];
            else
                reason = errorString;
            
            NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                reason, NSLocalizedDescriptionKey,
                nil];
            
            NSError * error = [NSError errorWithDomain: DDCurlDomain
                                                  code: performResult
                                              userInfo: userInfo];
            [self performSelectorOnMainThread: @selector(didFinish:)
                                   withObject: error
                                waitUntilDone: YES];
        }
        
#if 0
        if ([mResponse statusCode] == 401)
        {
            [mCurl setUser: @"foo" password: @"bar"];
            mIsFirstData = YES;
            [mCurl perform];
        }
#endif
        
    }
    @finally
    {
        [pool release];
    }
}

- (void) didFinish: (NSError *) error;
{
    if (mShouldCancel)
        return;
    
    if (error == nil)
        [self dd_curlConnectionDidFinishLoading: self];
    else
        [self dd_curlConnection: self didFailWithError: error];
}

- (void) setResponseInfo;
{
    NSString * contentLengthString = [mResponse headerWithName: @"Content-Length"];
    if (contentLengthString != nil)
    {
        long long contentLength = -1;
        NSScanner * scanner = [NSScanner scannerWithString: contentLengthString];
        if ([scanner scanLongLong: &contentLength])
        {
            [mResponse setExpectedContentLength: contentLength];
        }
    }
    
    [mResponse setEffectiveUrl: [mCurl effectiveUrl]];
    [mResponse setStatusCode: [mCurl responseCode]];
    [mResponse setMIMEType: [mCurl contentType]];
    [self dd_curlConnection: self didReceiveResponse: mResponse];
}

#pragma mark -
#pragma mark DDCurlEasy Callbacks

- (size_t) writeData: (char *) buffer size: (size_t) size
               nmemb: (size_t) nmemb
{
    if (mShouldCancel)
        return -1;
    
    size_t length = size * nmemb;
    if (mIsFirstData)
    {
        [self setResponseInfo];
        mIsFirstData = NO;
    }
    
    NSData * data = [NSData dataWithBytes: buffer length: length];
    [self dd_curlConnection: self
             didReceiveData: data];
    return length;
}

- (size_t) writeHeader: (char *) buffer size: (size_t) size
                 nmemb: (size_t) nmemb
{
    if (mShouldCancel)
        return -1;

    size_t length = size * nmemb;
    
    NSString * header = [NSString stringWithCString: buffer length: length];
    
    NSString * name;
    NSString * value;
    if (splitField(header, @":", &name, &value))
    {
        value = [value stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceCharacterSet]];
        [mResponse setHeader: value withName: name];
    }
    
    return length;
}

- (int) progressDownload: (double) download
           downloadTotal: (double) downloadTotal
                  upload: (double) upload
             uploadTotal: (double) uploadTotal;
{
    if (mShouldCancel)
        return -1;

    [self dd_curlConnection: self
           progressDownload: download
              downloadTotal: downloadTotal
                     upload: upload
                uploadTotal: uploadTotal];
    return 0;
}

- (int) debug: (CURL *) handle
         type: (curl_infotype) type
         data: (char *) data
         size: (size_t) size;
{
    if (mShouldCancel)
        return -1;
    return 0;
}

- (CURLcode) sslContext: (CURL *) handle context: (void *) void_ssl_context;
{
    SSL_CTX * ssl_context = (SSL_CTX *) void_ssl_context;
    
    const CSSM_DATA * anchors = NULL;
    uint32 anchorCount = 0;
    if (SecTrustGetCSSMAnchorCertificates(&anchors, &anchorCount) != 0)
        return CURLE_SSL_CACERT;
    
    X509_STORE * store = SSL_CTX_get_cert_store(ssl_context);
    int n;
    for(n = 0; n < anchorCount; n++)
    {
        // CSSM_DATA is in DER format.  d2i_X509 converts DER to an
        // internal format.
        unsigned char * bytes = anchors[n].Data;
        X509 * cert = d2i_X509(NULL, &bytes, anchors[n].Length);
        if (cert != NULL)
        {
            X509_STORE_add_cert(store, cert);
        }
        X509_free(cert);
    }
    
    return CURLE_OK;
}

#pragma mark -
#pragma mark Delegation

- (void) dd_curlConnection: (DDCurlConnection *) connection
            didReceiveData: (NSData *) data;
{
    
    if (![mDelegate respondsToSelector: _cmd])
        return;
    
    [self performSelectorOnMainThread: @selector(callDidReceiveDataDelegate:)
                           withObject: data
                        waitUntilDone: YES];
}

- (void) callDidReceiveDataDelegate: (NSData *) data;
{
    [mDelegate dd_curlConnection: self
                  didReceiveData: data];
}

- (void) dd_curlConnection: (DDCurlConnection *) connection
        didReceiveResponse: (DDCurlResponse *) response;
{
    if (![mDelegate respondsToSelector: _cmd])
        return;
    
    [self performSelectorOnMainThread: @selector(callDidReceiveResponse:)
                           withObject: response
                        waitUntilDone: YES];
}

- (void) callDidReceiveResponse: (DDCurlResponse *) response;
{
    [mDelegate dd_curlConnection: self didReceiveResponse: response];
}

- (void) dd_curlConnection: (DDCurlConnection *) connection
          progressDownload: (double) download
             downloadTotal: (double) downloadTotal
                    upload: (double) upload
               uploadTotal: (double) uploadTotal;
{
    if (![mDelegate respondsToSelector: _cmd])
        return;
    
    NSArray * arguments = [NSArray arrayWithObjects:
        [NSNumber numberWithDouble: download],
        [NSNumber numberWithDouble: downloadTotal],
        [NSNumber numberWithDouble: upload],
        [NSNumber numberWithDouble: uploadTotal],
        nil];
    [self performSelectorOnMainThread: @selector(callProgressDownload:)
                           withObject: arguments
                        waitUntilDone: YES];
}

- (void) callProgressDownload: (NSArray *) arguments;
{
    double download = [[arguments objectAtIndex: 0] doubleValue];
    double downloadTotal = [[arguments objectAtIndex: 1] doubleValue];
    double upload = [[arguments objectAtIndex: 2] doubleValue];
    double uploadTotal = [[arguments objectAtIndex: 3] doubleValue];
    [mDelegate dd_curlConnection: self
                progressDownload: download
                   downloadTotal: downloadTotal
                          upload: upload
                     uploadTotal: uploadTotal];
}

- (void) dd_curlConnectionDidFinishLoading: (DDCurlConnection *) connection;
{
    if (![mDelegate respondsToSelector: _cmd])
        return;
    
    // We're already back on the main thread
    [mDelegate dd_curlConnectionDidFinishLoading: connection];
}

- (void) dd_curlConnection: (DDCurlConnection *) connection
          didFailWithError: (NSError *) error;
{
    if (![mDelegate respondsToSelector: _cmd])
        return;
    
    // We're already back on the main thread
    [mDelegate dd_curlConnection: connection didFailWithError: error];
}

@end
