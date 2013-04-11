//
//  DDHidElementType.h
//  DDHidLib
//
//  Created by Remy Demarest on 10/04/2013.
//
//

#import <Foundation/Foundation.h>

@interface DDHidElementType : NSObject

+ (instancetype)elementTypeWithTypeIdentifier:(unsigned)elementType;
+ (instancetype)collectionTypeWithTypeIdentifier:(unsigned)collectionType;

- (id) initWithElementType: (unsigned) elementType
            collectionType: (unsigned) collectionType;

- (NSString *)typeName;

@property(readonly) unsigned elementType;
@property(readonly) unsigned collectionType;

@end
