//
//  CalendarAccessGuard.h
//  ShiftCal
//
//  Created by Christian Tietze on 12/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CalendarAccessResponder;
@protocol CalendarAccessResponderUnlock;

@protocol CalendarAccessGuardDelegate <NSObject>
- (void)grantCalendarAccess;
@end

@interface CalendarAccessGuard : NSObject
@property (nonatomic, weak, readwrite) id<CalendarAccessGuardDelegate> delegate;

@property (nonatomic, strong, readonly) id<CalendarAccessResponder> lockResponder;
@property (nonatomic, strong, readonly) id<CalendarAccessResponderUnlock> unlockResponder;

- (instancetype)initWithLockResponder:(id<CalendarAccessResponder>)lockResponder unlockResponder:(id<CalendarAccessResponderUnlock>)unlockResponder NS_DESIGNATED_INITIALIZER;

- (void)guardCalendarAccess;
@end
