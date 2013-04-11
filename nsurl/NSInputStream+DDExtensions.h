//
//  NSInputStream+DDExtensions.h
//  nsurl
//
//  Created by Dave Dribin on 5/15/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSInputStream (DDExtensions)

- (NSData *) dd_readUntilEndOfStream;

- (void) dd_readIntoFile: (NSString *) path;

@end
