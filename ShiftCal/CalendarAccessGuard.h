//
//  CalendarAccessGuard.h
//  ShiftCal
//
//  Created by Christian Tietze on 12/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@protocol CalendarAccessGuardDelegate <NSObject>
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)grantCalendarAccess;
@end

@interface CalendarAccessGuard : NSObject
@property (nonatomic, strong, readwrite) EKEventStore *eventStore;
@property (nonatomic, weak, readwrite) id<CalendarAccessGuardDelegate> delegate;

- (instancetype)initWithEventStore:(EKEventStore *)eventStore NS_DESIGNATED_INITIALIZER;

- (void)guardCalendarAccess;
@end
