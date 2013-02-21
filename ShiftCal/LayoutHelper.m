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

#pragma mark - public methods

+ (UIView *)emptyListViewWithTarget:(id)target action:(SEL)selector
{
    // Plus Icon
    UIImage *addImage        = [UIImage imageNamed:@"plus.png"];
    UIImage *addImagePressed = [UIImage imageNamed:@"plus_pressed.png"];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, addImage.size.width, addImage.size.height)];
    [addButton setImage:addImage forState:UIControlStateNormal];
    [addButton setImage:addImagePressed forState:UIControlStateHighlighted];
    [addButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];

    UIView *view = [LayoutHelper splashScreenViewFor:addButton titleText:@"No Event Templates, yet." detailText:@"Add templates and start\nto Paste Your Time!"];

    [addButton release];
    
    return view;
}

+ (UIView *)grantCalendarAccessView
{
    // Lock Icon
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock.png"]];
    
    UIView *view = [LayoutHelper splashScreenViewFor:imageView titleText:@"This app needs Calendar access\nto work." detailText:@"You can enable access in Privacy Settings."];

    [imageView release];
    
    return view;
}

#pragma mark - private factory methods

+ (UIView *)splashScreenViewFor:(UIView *)iconView titleText:(NSString *)titleText detailText:(NSString *)detailText
{
    CGRect frame = [LayoutHelper contentFrame];
    UIView *view = [[UIView alloc] initWithFrame:frame];
    
    view.backgroundColor = [UIColor whiteColor];
    
    static float kScreenWidth = 320.0f;
    static float kY4InchOffset = 40.0f;
    
    CGPoint iconViewCenter = CGPointMake(kScreenWidth / 2, 160.0f);
    
    if (IS_4INCH_DISPLAY)
    {
        iconViewCenter.y += kY4InchOffset;
    }
    
    iconView.center = iconViewCenter;
    
    [view addSubview:iconView];
    
    
    CGPoint offset = CGPointMake(10.0f, iconViewCenter.y + 120.0f);
    CGSize size = CGSizeMake(kScreenWidth - 2*offset.x, 40.0f);
    
    if (IS_4INCH_DISPLAY)
    {
        offset.y += 10.0f;
    }
    
    CGRect labelFrame = CGRectMake(offset.x, offset.y, size.width, size.height);
    [view addSubview:[LayoutHelper titleLabelWithFrame:labelFrame text:titleText]];
    
    CGRect detailLabelFrame = labelFrame;
    detailLabelFrame.origin.y += size.height;
    [view addSubview:[LayoutHelper labelWithFrame:detailLabelFrame text:detailText]];
    
    return [view autorelease];
}

+ (UILabel *)labelWithFrame:(CGRect)frame text:(NSString *)text
{
    UIColor *textColor = [UIColor colorWithRed:0.5 green:0.53 blue:0.58 alpha:1.0];
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.numberOfLines = 2;
    label.font = [UIFont systemFontOfSize:15.0f];
    label.text = text;
    label.textColor = textColor;
    label.textAlignment = NSTextAlignmentCenter;
    
    return [label autorelease];
}

+ (UILabel *)titleLabelWithFrame:(CGRect)frame text:(NSString *)text
{
    UILabel *label = [LayoutHelper labelWithFrame:frame text:text];
    label.font = [UIFont boldSystemFontOfSize:18.0f];
    
    return label;
}

+ (CGRect)contentFrame
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.size = CGSizeMake(frame.size.width, frame.size.height - TOP_BAR_HEIGHT);
    
    return frame;
}

@end
