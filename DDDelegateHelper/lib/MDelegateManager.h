//
//  MDelegateManager.h
//  DDDelegateHelper
//
//  Created by Dave Dribin on 1/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MDelegateManager : NSProxy {
	id _proxiedObject;
	BOOL _justResponded,_logOnNoResponse;
}

-(void)forwardInvocation:(NSInvocation*)invocation;
-(id)proxiedObject;
-(void)setProxiedObject:(id)proxied;
-(BOOL)justResponded;
-(void)setLogOnNoResponse:(BOOL)log;
-(BOOL)logOnNoResponse;
@end