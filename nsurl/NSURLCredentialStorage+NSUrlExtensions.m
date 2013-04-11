//
//  NSURLCredentialStorage+NSUrlExtensions.m
//  nsurl
//
//  Created by Dave Dribin on 5/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "NSURLCredentialStorage+NSUrlExtensions.h"
#import "JRLog.h"


static NSMutableDictionary * sDefaultCredentials;

void initializeDefaultCredentials()
{
    sDefaultCredentials = [[NSMutableDictionary alloc] init];;
}

@implementation NSURLCredentialStorage  (NSUrlCliExtensions)

- (NSURLCredential *) defaultCredentialForProtectionSpace: (NSURLProtectionSpace *) protectionSpace;
{
    JRLogDebug(@"%@ (%@)", NSStringFromSelector(_cmd), protectionSpace);
    return [sDefaultCredentials objectForKey: protectionSpace];
}

- (void) setDefaultCredential: (NSURLCredential *) credential
           forProtectionSpace: (NSURLProtectionSpace *) protectionSpace;
{
    JRLogDebug(@"%@ (%@, %@)", NSStringFromSelector(_cmd), credential,
               protectionSpace);
    [sDefaultCredentials setObject: credential forKey: protectionSpace];
}

@end

