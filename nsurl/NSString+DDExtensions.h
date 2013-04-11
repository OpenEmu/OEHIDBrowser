//
//  NSString+DDExtensions.h
//  nsurl
//
//  Created by Dave Dribin on 5/14/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


NSString * DDMimeTypeForExtension(NSString * extension);

@interface NSString (DDExtensions)

- (NSString *) dd_pathMimeType;

- (NSArray *) dd_splitBySeparator: (NSString *) separator;

@end
