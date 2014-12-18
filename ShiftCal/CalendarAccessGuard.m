//
//  CalendarAccessGuard.m
//  ShiftCal
//
//  Created by Christian Tietze on 12/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import "CalendarAccessGuard.h"
#import "CalendarAccessResponder.h"

#import "LayoutHelper.h"
#import "ShiftOverviewController.h"

#import "UserCalendarProvider.h"
#import "EventStoreWrapper.h"

@implementation CalendarAccessGuard

- (instancetype)init
{
    return [self initWithLockResponder:nil unlockResponder:nil];
}

- (instancetype)initWithLockResponder:(id<CalendarAccessResponder>)lockResponder unlockResponder:(id<CalendarAccessResponderUnlock>)unlockResponder
{
    NSParameterAssert(lockResponder);
    NSParameterAssert(unlockResponder);
    
    self = [super init];
    
    if (self)
    {
        _lockResponder = lockResponder;
        _unlockResponder = unlockResponder;
    }

    return self;
}

- (EventStoreWrapper *)eventStoreWrapper
{
    return [[UserCalendarProvider sharedInstance] eventStoreWrapper];
}


#pragma mark -

- (void)guardCalendarAccess
{
    [self activateLockResponder];
    
    if ([self isAuthorizedForCalendarAccess])
    {
        [self activateUnlockResponderImmediately];
        return;
    }
    
    [self requestCalendarAccess];
}

- (void)activateLockResponder
{
    [self.lockResponder activate];
}

- (BOOL)isAuthorizedForCalendarAccess
{
    return [self.eventStoreWrapper isAuthorizedForCalendarAccess];
}

- (void)requestCalendarAccess
{
    [self.eventStoreWrapper requestEventAccessWithGrantedBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self activateUnlockResponder];
        });
    }];
}

- (void)activateUnlockResponderImmediately
{
    [self activateUnlockResponder:self.unlockResponder immediately:YES];
    [self grantCalendarAccess];
}

- (void)activateUnlockResponder
{
    [self activateUnlockResponder:self.unlockResponder immediately:NO];
    [self grantCalendarAccess];
}

- (void)activateUnlockResponder:(id<CalendarAccessResponderUnlock>)unlockResponder immediately:(BOOL)immediate
{
    [unlockResponder setUnlocksImmediately:immediate];
    [unlockResponder activate];
}

- (void)grantCalendarAccess
{
    id<CalendarAccessGuardDelegate> delegate = self.delegate;
    
    if (delegate && [delegate respondsToSelector:@selector(grantCalendarAccess)])
    {
        [delegate grantCalendarAccess];
    }
}
@end
