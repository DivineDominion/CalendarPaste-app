//
//  LayoutHelper.h
//  ShiftCal
//
//  Created by Christian Tietze on 21.02.13.
//  Copyright (c) 2013 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LayoutHelper : NSObject

+ (UIView *)emptyListViewWithTarget:(id)target action:(SEL)selector;
+ (UIView *)grantCalendarAccessView;
+ (UIColor *)appColor;
@end
