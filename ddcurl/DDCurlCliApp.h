//
//  DDCurlCliApp.h
//  ddcurl
//
//  Created by Dave Dribin on 5/30/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DDCliApplication.h"

enum
{
    DDCurlCliAppNotDone,
    DDCurlCliAppDone,
};

@class DDMutableCurlRequest;
@class DDCurlResponse;
@class DDCurlMultipartForm;

@interface DDCurlCliApp : NSObject <DDCliApplicationDelegate>
{
    // Options
    BOOL _help;
    BOOL _version;
    BOOL _redirect;
    BOOL _cookie;
    
    DDMutableCurlRequest * mRequest;
    DDCurlMultipartForm * mForm;
    
    NSFileHandle * mFileHandle;
    BOOL mShowProgress;
    NSMutableData * mBody;
    DDCurlResponse * mResponse;
    long long mBytesReceived;
    NSConditionLock * mLock;
    BOOL mShouldKeepRunning;
    NSError * mError;
}

#pragma mark -
#pragma mark Options Accessors

- (void) setUsername: (NSString *) theUsername;

- (void) setPassword: (NSString *) thePassword;

- (void) setHeader: (NSString *) header;

- (void) setForm: (NSString *) formField;

#pragma mark -
#pragma mark DDCliApplicationDelegate

- (void) application: (DDCliApplication *) app
    willParseOptions: (DDGetoptLong *) options;

- (void) application: (DDCliApplication *) app
          printUsage: (FILE *) stream;

- (int) application: (DDCliApplication *) app
   runWithArguments: (NSArray *) arguments;


@end
