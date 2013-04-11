//
//  DDTemporaryFile.h
//  nsurl
//
//  Created by Dave Dribin on 4/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DDTemporaryDirectory;

@interface DDTemporaryFile : NSObject
{
    DDTemporaryDirectory * mTemporaryDirectory;
    NSString * mFullPath;
}

+ (DDTemporaryFile *) temporaryFileWithName: (NSString *) name;

- (id) initWithName: (NSString *) name;

- (NSString *) fullPath;

@end
