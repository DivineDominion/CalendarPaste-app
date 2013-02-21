//
//  LayoutHelper.m
//  ShiftCal
//
//  Created by Christian Tietze on 21.02.13.
//  Copyright (c) 2013 Christian Tietze. All rights reserved.
//

#import "LayoutHelper.h"

#define TOP_BAR_HEIGHT 64

@implementation LayoutHelper

+ (float)bottomOffsetModifiedFor4Inch:(float)yBottomOffset
{
    static float kYBottom4InchOffset = 30.0f;
    
    if (IS_4INCH_DISPLAY)
    {
        yBottomOffset += kYBottom4InchOffset;
    }
    
    return yBottomOffset;
}

+ (CGRect)contentFrame
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.size = CGSizeMake(frame.size.width, frame.size.height - TOP_BAR_HEIGHT);
    
    return frame;
}

@end
