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

+ (UIView *)splashScreenViewFor:(UIView *)iconView titleText:(NSString *)titleText description:(NSString *)description
{
    CGRect frame = [LayoutHelper contentFrame];
    UIView *view = [[UIView alloc] initWithFrame:frame];
    
    view.backgroundColor = [UIColor whiteColor];
    
    float yBottomOffset = [LayoutHelper bottomOffsetModifiedFor4Inch:276.0f];
    
    iconView.center = CGPointMake(160.0, frame.size.height - yBottomOffset);
    
    //Labels
    UIColor *textColor = [UIColor colorWithRed:0.5 green:0.53 blue:0.58 alpha:1.0];
    
    static float kXOffset       = 10.0f;
    float yOffset               = frame.size.height - [LayoutHelper bottomOffsetModifiedFor4Inch:146.0f];
    static float kWidth         = 300.0f; // 320 - 2 * x-offset
    static float kHeight        = 40.0f;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kXOffset, yOffset, kWidth, kHeight)];
    label.numberOfLines = 2;
    label.text = titleText;
    label.font = [UIFont boldSystemFontOfSize:18.0f];
    label.textColor = textColor;
    label.textAlignment = NSTextAlignmentCenter;
    
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(kXOffset, yOffset + kHeight, kWidth, kHeight)];
    detailLabel.numberOfLines = 2;
    detailLabel.text = description;
    detailLabel.font = [UIFont systemFontOfSize:15.0f];
    detailLabel.textColor = textColor;
    detailLabel.textAlignment = NSTextAlignmentCenter;
    
    [view addSubview:iconView];
    [view addSubview:label];
    [view addSubview:detailLabel];
    
    return [view autorelease];
}

+ (UIView *)emptyListViewWithTarget:(id)target action:(SEL)selector
{
    // Plus Icon
    UIImage *addImage        = [UIImage imageNamed:@"plus.png"];
    UIImage *addImagePressed = [UIImage imageNamed:@"plus_pressed.png"];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, addImage.size.width, addImage.size.height)];
    [addButton setImage:addImage forState:UIControlStateNormal];
    [addButton setImage:addImagePressed forState:UIControlStateHighlighted];
    [addButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];

    UIView *view = [LayoutHelper splashScreenViewFor:addButton titleText:@"No Event Templates, yet." description:@"Add templates and start\nto Paste Your Time!"];

    [addButton release];
    
    return view;
}

+ (UIView *)grantCalendarAccessView
{
    // Lock Icon
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock.png"]];
    
    UIView *view = [LayoutHelper splashScreenViewFor:imageView titleText:@"This app needs Calendar access\nto work." description:@"You can enable access in Privacy Settings."];

    [imageView release];
    
    return view;
}

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
