//
//  CalendarAccessGuard.h
//  ShiftCal
//
//  Created by Christian Tietze on 12/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@class EventStoreWrapper;

@protocol CalendarAccessGuardDelegate <NSObject>
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)grantCalendarAccess;
@end

@interface CalendarAccessGuard : NSObject
@property (nonatomic, weak, readwrite) id<CalendarAccessGuardDelegate> delegate;

- (void)guardCalendarAccess;
@end
