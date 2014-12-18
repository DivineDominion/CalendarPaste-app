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
    UIImage *addImage        = [UIImage imageNamed:@"Plus"];
    UIImage *addImagePressed = [UIImage imageNamed:@"PlusPressed"];
    
    UIButton *addButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, addImage.size.width, addImage.size.height)];
    [addButton setImage:addImage forState:UIControlStateNormal];
    [addButton setImage:addImagePressed forState:UIControlStateHighlighted];
    [addButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];

    UIView *view = [LayoutHelper splashScreenViewFor:addButton titleText:@"No Event Templates, yet." detailText:@"Add templates and start\nto Paste Your Time!"];
    NSLog(@"%f, %f", view.frame.size.width, view.frame.size.height);
    return view;
}

+ (UIView *)grantCalendarAccessView
{
    // Lock Icon
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Lock"]];
    
    UIView *view = [LayoutHelper splashScreenViewFor:imageView titleText:@"This app needs Calendar access\nto work." detailText:@"You can enable access in Privacy Settings."];
    NSLog(@"%f, %f", view.frame.size.width, view.frame.size.height);
    
    return view;
}

#pragma mark - private factory methods

+ (UIView *)splashScreenViewFor:(UIView *)iconView titleText:(NSString *)titleText detailText:(NSString *)detailText
{
    CGRect screenFrame = [LayoutHelper contentFrame];

    UIView *view = [[UIView alloc] initWithFrame:screenFrame];
    view.backgroundColor = [UIColor whiteColor];
    
    float screenWidth = screenFrame.size.width;
    float screenHeight = screenFrame.size.height;
    
    CGPoint iconViewCenter = CGPointMake(screenWidth / 2, screenHeight / 2);
    
    iconView.center = iconViewCenter;
    
    [view addSubview:iconView];
    
    
    CGPoint offset = CGPointMake(10.0f, iconViewCenter.y + 120.0f);
    CGSize size = CGSizeMake(screenWidth - 2*offset.x, 50.0f);
    
    if (IS_4INCH_DISPLAY)
    {
        offset.y += 10.0f;
    }
    
    CGRect labelFrame = CGRectMake(offset.x, offset.y, size.width, size.height);
    [view addSubview:[LayoutHelper titleLabelWithFrame:labelFrame text:titleText]];
    
    CGRect detailLabelFrame = labelFrame;
    detailLabelFrame.origin.y += size.height;
    [view addSubview:[LayoutHelper labelWithFrame:detailLabelFrame text:detailText]];
    
    return view;
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
    
    return label;
}

+ (UILabel *)titleLabelWithFrame:(CGRect)frame text:(NSString *)text
{
    UILabel *label = [LayoutHelper labelWithFrame:frame text:text];
    label.font = [UIFont boldSystemFontOfSize:18.0f];
    
    return label;
}

+ (CGRect)contentFrame
{
    CGRect frame = [self screenBounds];
    frame.size = CGSizeMake(frame.size.width, frame.size.height - TOP_BAR_HEIGHT);
    
    return frame;
}

+ (CGRect)screenBounds
{
    return [[UIScreen mainScreen] bounds];
}

#pragma mark - App Color

+ (UIColor *)appColor
{
    return [UIColor colorWithRed:116.0/255 green:128.0/255 blue:199.0/255 alpha:1.0];
}
@end
