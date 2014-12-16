//
//  CalendarAccessGuard.m
//  ShiftCal
//
//  Created by Christian Tietze on 12/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import "CalendarAccessGuard.h"

#import "LayoutHelper.h"
#import "ShiftOverviewController.h"

#import "UserCalendarProvider.h"
#import "EventStoreWrapper.h"

@implementation CalendarAccessGuard

- (EventStoreWrapper *)eventStoreWrapper
{
    return [[UserCalendarProvider sharedInstance] eventStoreWrapper];
}

#pragma mark -

- (void)guardCalendarAccess
{
    [self showCalendarAccessLock];
    
    if ([self isAuthorizedForCalendarAccess])
    {
        [self showOverviewViewController];
        return;
    }
    
    [self requestCalendarAccess];
}

- (void)showCalendarAccessLock
{
    [self pushViewController:[self grantCalendarAccessViewController] animated:NO];
}

- (BOOL)isAuthorizedForCalendarAccess
{
    return [self.eventStoreWrapper isAuthorizedForCalendarAccess];
}

- (void)requestCalendarAccess
{
    __weak CalendarAccessGuard *welf = self;
    [self.eventStoreWrapper requestEventAccessWithGrantedBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [welf showOverviewViewControllerAnimated:YES];
            [welf.delegate grantCalendarAccess];
        });
    }];
}

- (void)showOverviewViewController
{
    [self showOverviewViewControllerAnimated:NO];
    [self.delegate grantCalendarAccess];
}

- (void)showOverviewViewControllerAnimated:(BOOL)animated
{
    ShiftOverviewController *shiftOverviewController = [[ShiftOverviewController alloc] init];
    [self pushViewController:shiftOverviewController
                    animated:animated];
}

- (UIViewController *)grantCalendarAccessViewController
{
    UIViewController *grantCalendarAccessViewController = [[UIViewController alloc] init];
    UIView *view = [LayoutHelper grantCalendarAccessView];
    grantCalendarAccessViewController.view = view;
    
    return grantCalendarAccessViewController;
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    id<CalendarAccessGuardDelegate> delegate = self.delegate;
    
    if (delegate && [delegate respondsToSelector:@selector(pushViewController:animated:)])
    {
        [delegate pushViewController:viewController animated:animated];
    }
}
@end
