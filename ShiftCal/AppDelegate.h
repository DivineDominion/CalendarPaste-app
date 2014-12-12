//
//  AppDelegate.h
//  ShiftCal
//
//  Created by Christian Tietze on 25.07.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

#import "CalendarAccessGuard.h"

@class ShiftOverviewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, CalendarAccessGuardDelegate>
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong, readonly) EKEventStore *eventStore;
@property (nonatomic, strong, readonly) UIColor *appColor;
@end
