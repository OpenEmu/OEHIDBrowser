//
//  DDScale2x.h
//  DDScale2x
//
//  Created by Dave Dribin on 3/6/07.
//  Copyright __MyCompanyName__ 2007. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/CoreImage.h>


@interface DDScale2xPlugInLoader : NSObject <CIPlugInRegistration>
{

}

-(BOOL)load:(void*)host;

@end
