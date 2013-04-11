//
//  NSURLCredentialStorage+NSUrlExtensions.h
//  nsurl
//
//  Created by Dave Dribin on 5/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


void initializeDefaultCredentials();

@interface NSURLCredentialStorage  (NSUrlCliExtensions)

- (NSURLCredential *) defaultCredentialForProtectionSpace: (NSURLProtectionSpace *) protectionSpace;

- (void) setDefaultCredential: (NSURLCredential *) credential
           forProtectionSpace: (NSURLProtectionSpace *) protectionSpace;

@end