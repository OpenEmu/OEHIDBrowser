//
//  DDMultipartInputStream.h
//  nsurl
//
//  Created by Dave Dribin on 5/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class DDTemporaryFile;

@interface DDMultipartInputStream : NSInputStream
{
    NSString * mBoundary;
    NSMutableArray * mParts;
    NSMutableArray * mPartStreams;
    unsigned long long mLength;
    DDTemporaryFile * mTemporaryFile;

    NSInputStream * mCurrentStream;
    unsigned mStreamIndex;
}

- (NSString *) boundary;

- (void) addPartWithName: (NSString *) name data: (NSData *) data;

- (void) addPartWithName: (NSString *) name string: (NSString *) string;

- (void) addPartWithName: (NSString *) name intValue: (int) intValue;

- (void) addPartWithName: (NSString *) name fileAtPath: (NSString *) path;

- (void) buildBody;

- (unsigned long long) length;

- (NSInputStream *) inputStreamWithTemporaryFile;

@end

@interface DDMultipartDataPart : NSObject
{
    NSString * mHeaders;
    NSInputStream * mContentStream;
    unsigned long long mContentLength;
}

+ partWithName: (NSString *) name dataContent: (NSData *) data;

+ partWithName: (NSString *) name fileContent: (NSString *) path;

- (id) initWithName: (NSString *) name dataContent: (NSData *) data;

- (id) initWithName: (NSString *) name fileContent: (NSString *) path;

- (id) initWithHeaders: (NSString *) headers dataContent: (NSData *) data;

- (id) initWithHeaders: (NSString *) headers
         streamContent: (NSInputStream *) stream
                length: (unsigned long long) length;

- (NSString *) headersAsString;

- (NSInputStream *) contentAsStream;

- (unsigned long long) contentLength;

@end