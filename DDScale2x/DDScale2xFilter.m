//
//  DDScale2xFilter.m
//  CIHazeFilterSample
//
//  Created by Dave Dribin on 3/6/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DDScale2xFilter.h"


static CIKernel * sScale2xKernel = nil;

@implementation DDScale2xFilter

#if STANDALONE
+ (void) initialize
{
    [CIFilter registerFilterName: @"DDScale2xFilter"  constructor: self
                 classAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                     
                     @"Scale 2x",                       kCIAttributeFilterDisplayName,
                     
                     [NSArray arrayWithObjects:
                         kCICategoryGeometryAdjustment, kCICategoryVideo, kCICategoryStillImage,
                         nil],                              kCIAttributeFilterCategories,
                                          
                     nil]];
}

+ (CIFilter *) filterWithName: (NSString *) name
{
    CIFilter  *filter;
    
    filter = [[self alloc] init];
    return [filter autorelease];
}
#endif

- (id) init;
{
    self = [super init];
    if (self == nil)
        return nil;
    
    if (sScale2xKernel == nil)
    {
        NSBundle * myBundle = [NSBundle bundleForClass: [self class]];
        NSString * kernelFile = [myBundle pathForResource: @"DDScale2x"
                                                   ofType: @"cikernel"];
        NSString * code = [NSString stringWithContentsOfFile: kernelFile];
        NSArray * kernels = [CIKernel kernelsWithString: code];
        sScale2xKernel = [[kernels objectAtIndex: 0] retain];
    }
    
    return self;
}

#if 1
- (NSDictionary *) customAttributes;
{
    return [NSDictionary dictionary];
}
#endif

#if 0
- (NSDictionary *)customAttributes
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        
        [NSDictionary dictionaryWithObjectsAndKeys:
            [CIVector vectorWithX:200.0 Y:200.0],       kCIAttributeDefault,
            kCIAttributeTypePosition,           kCIAttributeType,
            nil],                               @"inputCenter",

        nil];
}
#endif

#if 0
- (CGRect)regionOf:(int)samplerIndex destRect:(CGRect)r userInfo:img
{
    // return [img extent];
    return r;
}
#endif

- (CIImage *) outputImage;
{
    NSDictionary * samplerOptions = [NSDictionary dictionaryWithObjectsAndKeys:
        kCISamplerFilterNearest, kCISamplerFilterMode,
        // kCISamplerFilterLinear, kCISamplerFilterMode,
        nil];
#if 1
    CISampler * src = [CISampler samplerWithImage: inputImage
                                          options: samplerOptions];
#else
    CISampler * src = [CISampler samplerWithImage: inputImage];
#endif
    const float scale = 2.0;
    CGRect e = [inputImage extent];
    NSArray * extent = [NSArray arrayWithObjects:
        [NSNumber numberWithInt: e.origin.x], [NSNumber numberWithInt: e.origin.y],
        [NSNumber numberWithInt: e.size.width*scale], [NSNumber numberWithInt: e.size.height*scale],
        nil];

    // [sScale2xKernel setROISelector: @selector(regionOf:destRect:userInfo:)];

    NSArray * arguments = [NSArray arrayWithObject: src];
    NSDictionary * options = [NSDictionary dictionaryWithObjectsAndKeys:
        extent, kCIApplyOptionExtent,
        // extent, kCIApplyOptionDefinition,
        // [src definition], kCIApplyOptionDefinition,
        // inputImage, kCIApplyOptionUserInfo,
        nil];

#if 1
    CIImage * output = [self apply: sScale2xKernel
                         arguments: arguments
                           options: options];
#else
    CIImage * output = [self apply: sScale2xKernel, src,
        kCIApplyOptionDefinition, [src definition],
        nil];
#endif
    return output;
}    

@end
