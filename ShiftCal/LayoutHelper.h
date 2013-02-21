//
//  LayoutHelper.h
//  ShiftCal
//
//  Created by Christian Tietze on 21.02.13.
//  Copyright (c) 2013 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LayoutHelper : NSObject

+ (float)bottomOffsetModifiedFor4Inch:(float)yBottomOffset;
+ (CGRect)contentFrame;

@end
