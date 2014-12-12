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

@implementation CalendarAccessGuard

- (instancetype)init
{
    return [self initWithEventStore:nil];
}

- (instancetype)initWithEventStore:(EKEventStore *)eventStore
{
    NSParameterAssert(eventStore);
    
    self = [super init];
    
    if (self)
    {
        _eventStore = eventStore;
    }
    
    return self;
}


- (void)guardCalendarAccess
{
    EKAuthorizationStatus authorizationStatus = [self authorizationStatusForCalendarAccess];
    if (authorizationStatus == EKAuthorizationStatusAuthorized) {
        [self showOverviewViewController];
    } else {
        [self requestCalendarAccess];
    }
}

- (EKAuthorizationStatus)authorizationStatusForCalendarAccess
{
    [self pushViewController:[self grantCalendarAccessViewController] animated:NO];
    
    return [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
}

- (void)requestCalendarAccess
{
    __weak CalendarAccessGuard *welf = self;
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
        if (granted)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [welf showOverviewViewControllerAnimated:YES];
            });
        }
    }];
}

- (void)showOverviewViewController
{
    [self showOverviewViewControllerAnimated:NO];
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
