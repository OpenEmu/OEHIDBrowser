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

#import "DDCurlEasy.h"
#import "DDCurlSlist.h"
#import "DDCurlMultipartForm.h"

@interface DDCurlEasy (Private)

- (void) assert: (CURLcode) errorCode
        message: (NSString *) message, ...;

- (void) setProperty: (id) property forOption: (int) option;

- (void) setString: (NSString *) string forOption: (int) option
           message: (NSString *) message;

@end

@implementation DDCurlEasy

+ (NSString *) errorString: (CURLcode) errorCode;
{
    return [NSString stringWithUTF8String: curl_easy_strerror(errorCode)];
}

#pragma mark -
#pragma mark Constructors

- (id) init
{
    self = [super init];
    if (self == nil)
        return nil;
    
    mCurl = curl_easy_init();
    if (curl_easy_setopt(mCurl, CURLOPT_ERRORBUFFER, mErrorBuffer) != CURLE_OK)
    {
        curl_easy_cleanup(mCurl);
        return nil;
    }
    
    mProperties = [[NSMutableDictionary alloc] init];

    return self;
}

//=========================================================== 
// dealloc
//=========================================================== 
- (void) dealloc
{
    [mProperties release];
    curl_easy_cleanup(mCurl);
    
    mProperties = nil;
    [super dealloc];
}

- (CURL *) CURL;
{
    return mCurl;
}

#pragma mark -
#pragma mark Options

- (void) setUrl: (NSString *) url;
{
    [self setString: url forOption: CURLOPT_URL
            message: @"set url"];
}

- (void) setProgress: (BOOL) progress;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_NOPROGRESS, !progress)
         message: @"set progress"];
}

- (void) setFollowLocation: (BOOL) followLocation;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_FOLLOWLOCATION, followLocation)
         message: @"set follow location"];
}

- (void) setUser: (NSString *) user password: (NSString *) password;
{
    NSString * userPassword = [NSString stringWithFormat: @"%@:%@", user, password];
    [self setString: userPassword forOption: CURLOPT_USERPWD
            message: @"set user/password"];
}

- (void) setCustomRequest: (NSString *) customRequest;
{
    [self setString: customRequest forOption: CURLOPT_CUSTOMREQUEST
            message: @"set custom request"];
}

- (void) setHttpHeaders: (DDCurlSlist *) httpHeaders;
{
    [self setCurlHttpHeaders: [httpHeaders curl_slist]];
    [self setProperty: httpHeaders forOption: CURLOPT_HTTPHEADER];
}

- (void) setCurlHttpHeaders: (struct curl_slist *) httpHeaders;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_HTTPHEADER, httpHeaders)
         message: @"set HTTP headers"];
}

- (void) setHttpPost: (DDCurlMultipartForm *) httpPost;
{
    [self setCurlHttpPost: [httpPost curl_httppost]];
    [self setProperty: httpPost forOption: CURLOPT_HTTPPOST];
}

- (void) setCurlHttpPost: (struct curl_httppost *) httpPost;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_HTTPPOST, httpPost)
         message: @"set HTTP post"];
}

- (void) setCaInfo: (NSString *) caInfo;
{
    [self setString: caInfo forOption: CURLOPT_CAINFO
            message: @"set CAINFO"];
}

- (void) setUseSignals: (BOOL) useSignals;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_NOSIGNAL, !useSignals)
         message: @"set use signals"];
}

- (void) setVerbose: (BOOL) verbose;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_VERBOSE, verbose)
         message: @"set verbose"];
}

- (void) setCookieFile: (NSString *) cookieFile;
{
    [self setString:  cookieFile forOption: CURLOPT_COOKIEFILE
            message: @"set cookie file"];
}

- (void) setResumeFromLarge: (curl_off_t) resumeFrom;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_RESUME_FROM_LARGE, resumeFrom)
         message: @"set resume from (large)"];
}

#if LIBCURL_VERSION_NUM > 0x070f05
- (void) setMaxSendSpeedLarge: (curl_off_t) maxSendSpeed;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_MAX_SEND_SPEED_LARGE, maxSendSpeed)
         message: @"set max send speed (large)"];
}

- (void) setMaxReceiveSpeedLarge: (curl_off_t) maxReceiveSpeed;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_MAX_RECV_SPEED_LARGE, maxReceiveSpeed)
         message: @"set max receive speed (large)"];
}
#endif

#pragma mark -

- (CURLcode) perform;
{
    return curl_easy_perform(mCurl);
}

- (const char *) errorBuffer;
{
    return mErrorBuffer;
}

- (NSString *) errorString;
{
    return [NSString stringWithUTF8String: mErrorBuffer];
}

#pragma mark -
#pragma mark Informational

- (long) responseCode;
{
    long responseCode;
    [self assert: curl_easy_getinfo(mCurl, CURLINFO_RESPONSE_CODE, &responseCode)
         message: nil];
    return responseCode;
}

- (NSString *) contentType;
{
    char * contentType;
    [self assert: curl_easy_getinfo(mCurl, CURLINFO_CONTENT_TYPE, &contentType)
         message: nil];
    if (contentType == NULL)
        return nil;
    return [NSString stringWithUTF8String: contentType];
}

- (NSString *) effectiveUrl;
{
    char * effectiveUrl;
    [self assert: curl_easy_getinfo(mCurl, CURLINFO_EFFECTIVE_URL, &effectiveUrl)
         message: nil];
    if (effectiveUrl == NULL)
        return nil;
    return [NSString stringWithUTF8String: effectiveUrl];
}

#pragma mark -
#pragma mark Callback functions

- (void) setWriteData: (void *) writeData;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_WRITEDATA, writeData)
         message: @"set write data"];
}

- (void) setWriteFunction: (curl_write_callback) writeFunction;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_WRITEFUNCTION, writeFunction)
         message: @"set write function"];
}

- (void) setWriteHeaderData: (void *) writeHeaderData;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_WRITEHEADER, writeHeaderData)
         message: @"set write header data"];
}

- (void) setWriteHeaderFunction: (curl_write_callback) writeHeaderFunction;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_HEADERFUNCTION, writeHeaderFunction)
         message: @"set write header function"];
}

- (void) setProgressData: (void *) progressData;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_PROGRESSDATA, progressData)
         message: @"set progress data"];
}

- (void) setProgressFunction: (curl_progress_callback) progressFunction;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_PROGRESSFUNCTION, progressFunction)
         message: @"set progress function"];
}

- (void) setDebugData: (void *) debugData;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_DEBUGDATA, debugData)
         message: @"set debug data"];
}

- (void) setDebugFunction: (curl_debug_callback) debugFunction;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_DEBUGFUNCTION, debugFunction)
         message: @"set debug function"];
}

- (void) setSslCtxData: (void *) sslCtxData;
{
    {
        [self assert: curl_easy_setopt(mCurl, CURLOPT_SSL_CTX_DATA, sslCtxData)
             message: @"set SSL context data"];
    }
}

- (void) setSslCtxFunction: (curl_ssl_ctx_callback) sslCtxFunction;
{
    [self assert: curl_easy_setopt(mCurl, CURLOPT_SSL_CTX_FUNCTION, sslCtxFunction)
         message: @"set SSL context function"];
}

@end

@implementation DDCurlEasy (Private)

- (void) assert: (CURLcode) errorCode
        message: (NSString *) message, ...;
{
    if (errorCode != CURLE_OK)
    {
        const char * curlError = curl_easy_strerror(errorCode);
        NSMutableString * reason = [NSMutableString string];
        
        if (message != nil)
        {
            va_list arguments;
            va_start(arguments, message);
            NSString * prefix = [[NSString alloc] initWithFormat: message
                                                       arguments: arguments];
            [prefix autorelease];
            va_end(arguments);
            
            [reason appendFormat: @"Coult not %@: ", prefix];
        }
        
        [reason appendFormat: @"curl error #%d (%s)", errorCode, curlError];
        
        [reason appendFormat: @": %s", mErrorBuffer];
        NSException * exception = [NSException exceptionWithName: @"CurlException"
                                                          reason: reason
                                                        userInfo: nil];
        @throw exception;
    }
}

- (void) setProperty: (id) property forOption: (int) option;
{
    [mProperties setObject: property forKey: [NSNumber numberWithInt: option]];
}

- (void) setString: (NSString *) string forOption: (int) option
           message: (NSString *) message;
{
    const char * utf8String = NULL;
    if (string != nil)
    {
        utf8String = [string UTF8String];
        NSData * data = [NSData dataWithBytes: utf8String length: strlen(utf8String)];
        [self setProperty: data forOption: option];
    }

    [self assert: curl_easy_setopt(mCurl, option, utf8String)
         message: message];
}

@end
