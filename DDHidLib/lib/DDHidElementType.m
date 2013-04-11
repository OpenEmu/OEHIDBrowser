//
//  DDHidElementType.m
//  DDHidLib
//
//  Created by Remy Demarest on 10/04/2013.
//
//

#import "DDHidElementType.h"
#import <IOKit/hid/IOHIDKeys.h>

@implementation DDHidElementType

+ (instancetype)elementTypeWithTypeIdentifier:(unsigned)elementType;
{
    return [[DDHidElementType alloc] initWithElementType:elementType collectionType:0];
}

+ (instancetype)collectionTypeWithTypeIdentifier:(unsigned)collectionType;
{
    return [[DDHidElementType alloc] initWithElementType:kIOHIDElementTypeCollection collectionType:collectionType];
}

- (id) initWithElementType: (unsigned) elementType
            collectionType: (unsigned) collectionType;
{
    if((self = [super init]))
    {
        _elementType = elementType;
        if(_elementType == kIOHIDElementTypeCollection)
            _collectionType = collectionType;
    }

    return self;
}

- (NSString *)typeName;
{
    switch(_elementType)
    {
        case kIOHIDElementTypeInput_Misc :
            return @"Input Misc";
        case kIOHIDElementTypeInput_Button :
            return @"Input Button";
        case kIOHIDElementTypeInput_Axis :
            return @"Input Axis";
        case kIOHIDElementTypeInput_ScanCodes :
            return @"Input ScanCodes";
        case kIOHIDElementTypeOutput :
            return @"Output";
        case kIOHIDElementTypeFeature :
            return @"Feature";
        case kIOHIDElementTypeCollection :
        {
            switch(_collectionType)
            {
                case kIOHIDElementCollectionTypePhysical :
                    return @"Physical Collection";
                case kIOHIDElementCollectionTypeApplication :
                    return @"Application Collection";
                case kIOHIDElementCollectionTypeLogical :
                    return @"Logical Collection";
                case kIOHIDElementCollectionTypeReport :
                    return @"Report Collection";
                case kIOHIDElementCollectionTypeNamedArray :
                    return @"Named Array Collection";
                case kIOHIDElementCollectionTypeUsageSwitch :
                    return @"Usage Switch Collection";
                case kIOHIDElementCollectionTypeUsageModifier :
                    return @"Usage Modifier Collection";
            }
        }
    }

    return @"Unknown Type";
}

@end
