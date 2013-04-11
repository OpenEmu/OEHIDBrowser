//
//  DDScale2xView.m
//  DDScale2x
//
//  Created by Dave Dribin on 3/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDScale2xView.h"
#import "DDScale2xFilter.h"

@implementation DDScale2xView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;
    
    // [DDScale2xFilter class];
    [CIPlugIn loadAllPlugIns];
    NSLog(@"Names: %@", [CIFilter filterNamesInCategory: kCICategoryGeometryAdjustment]);

    NSString    *path = [[[NSBundle mainBundle] builtInPlugInsPath] stringByAppendingPathComponent:@"DDScale2x.plugin"];
	NSURL	    *pluginURL = [NSURL fileURLWithPath:path];
	[CIPlugIn loadPlugIn:pluginURL allowNonExecutable:NO];
    
    NSURL * url = [NSURL fileURLWithPath: [[NSBundle mainBundle]
            pathForResource: @"liquidk-1s"  ofType: @"png"]];
    inputImage = [[CIImage imageWithContentsOfURL: url] retain];
    CGRect inputEXtent = [inputImage extent];
    filter   = [CIFilter filterWithName: @"DDScale2xFilter"];
    NSLog(@"Filter: %@", filter);
    [filter setValue: inputImage forKey: @"inputImage"];
    [filter retain];
    
    return self;
}

- (void) dealloc
{
    [filter release];
    [inputImage release];
    [super dealloc];
}

- (void)drawRect: (NSRect)rect
{
	CIContext* context = [[NSGraphicsContext currentContext] CIContext];
	
	if (context != nil)
    {
        CIImage * outputImage = [filter valueForKey: @"outputImage"];
        CGRect outputExtent = [outputImage extent];
        NSLog(@"outputRect: %d %@", CGRectIsInfinite(outputExtent), outputImage);
        CGPoint origin = CGPointMake(NSMinX(rect), NSMinY(rect));
        
		[context drawImage: outputImage
                   atPoint: origin  fromRect: outputExtent];
    }
}

@end
