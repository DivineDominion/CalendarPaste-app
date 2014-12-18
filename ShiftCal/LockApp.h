//
//  LockApp.h
//  ShiftCal
//
//  Created by Christian Tietze on 18/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CalendarAccessResponder.h"

@interface LockApp : NSObject <CalendarAccessResponder>
@property (nonatomic, strong, readwrite) UIViewController *viewController;
@property (nonatomic, strong, readwrite) UINavigationController *navigationController;

- (instancetype)initWithViewController:(UIViewController *)viewController navigationController:(UINavigationController *)navigationController NS_DESIGNATED_INITIALIZER;
@end
