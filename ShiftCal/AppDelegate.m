//
//  AppDelegate.m
//  ShiftCal
//
//  Created by Christian Tietze on 25.07.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "AppDelegate.h"
#import "EventStoreConstants.h"

#import "ShiftOverviewController.h"
#import "LayoutHelper.h"

@interface AppDelegate ()

// private properties
@property (nonatomic, retain, readwrite) UINavigationController *navController;
@property (nonatomic, retain, readwrite) EKEventStore *eventStore;

- (void)requestCalendarAccessForOverviewViewController;
- (void)showOverviewViewControllerAnimated:(BOOL)animated;
- (UIViewController *)grantCalendarAccessViewController;
- (void)eventStoreChanged:(id)sender;
@end


@implementation AppDelegate
@synthesize eventStore = _eventStore;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_navController release];
    [_eventStore release];
    
    [super dealloc];
}

#pragma mark - Launch and Set-Up

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.eventStore    = [[[EKEventStore alloc] init] autorelease];
    self.window        = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.navController = [[[UINavigationController alloc] init] autorelease];
    
    if ([EKEventStore instancesRespondToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        [self requestCalendarAccessForOverviewViewController];
    }
    else
    {
        [self showOverviewViewControllerAnimated:NO];
    }

    self.window.rootViewController = self.navController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)requestCalendarAccessForOverviewViewController
{
    [self.navController pushViewController:[self grantCalendarAccessViewController] animated:NO];
    
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    
    switch (status) {
        case EKAuthorizationStatusAuthorized:
            [self showOverviewViewControllerAnimated:NO];
            break;
            
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusNotDetermined:
        case EKAuthorizationStatusRestricted:
        default:
            [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                if (granted)
                {
                    SEL selector = @selector(showOverviewViewControllerAnimated:);
                    BOOL animated = YES;
                    
                    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:selector]];
                    [inv setSelector:selector];
                    [inv setTarget:self];
                    [inv setArgument:&animated atIndex:2]; // 0 and 1 are preoccupied by default
                    
                    [inv performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:NO];
                }
            }];
            
            break;
    }
}

- (void)showOverviewViewControllerAnimated:(BOOL)animated
{
    // Register just now because calendar access, if necessary, is granted
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(eventStoreChanged:)
                                                 name:EKEventStoreChangedNotification
                                               object:self.eventStore];
    
    [self registerPreferenceDefaults];
    
    [self.navController pushViewController:[[[ShiftOverviewController alloc] init] autorelease]
                                  animated:animated];
}

- (UIViewController *)grantCalendarAccessViewController
{
    UIViewController *grantCalendarAccessViewController = [[UIViewController alloc] init];
    
    UIView *view = [LayoutHelper grantCalendarAccessView];
    grantCalendarAccessViewController.view = view;
    
    return [grantCalendarAccessViewController autorelease];
}

#pragma mark User preferences

- (void)eventStoreChanged:(NSNotification *)notification
{
    [self registerPreferenceDefaults];
    
    // Inform observers to change calendars if necessary
    NSString *defaultCalendarIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:PREFS_DEFAULT_CALENDAR_KEY];
    NSDictionary *userInfo = @{ NOTIFICATION_DEFAULT_CALENDAR_KEY : defaultCalendarIdentifier };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SCStoreChangedNotification
                                                        object:self
                                                      userInfo:userInfo];
}

- (void)registerPreferenceDefaults
{
    NSUserDefaults *prefs               = [NSUserDefaults standardUserDefaults];
    NSString *defaultCalendarIdentifier = [prefs objectForKey:PREFS_DEFAULT_CALENDAR_KEY];
    
    if (defaultCalendarIdentifier == nil)
    {
        defaultCalendarIdentifier      = [self.eventStore defaultCalendarForNewEvents].calendarIdentifier;

        [prefs setObject:defaultCalendarIdentifier forKey:PREFS_DEFAULT_CALENDAR_KEY];
#ifdef DEVELOPMENT
        [prefs synchronize];
#endif
    }
    else
    {
        // Sanity Check
        EKCalendar *defaultCalendar = [self.eventStore calendarWithIdentifier:defaultCalendarIdentifier];
        
        if (defaultCalendar == nil)
        {
            defaultCalendarIdentifier = [self.eventStore defaultCalendarForNewEvents].calendarIdentifier;
            [prefs setObject:defaultCalendarIdentifier forKey:PREFS_DEFAULT_CALENDAR_KEY];
#ifdef DEVELOPMENT
            [prefs synchronize];
#endif
        }
    }
}


#pragma mark Application callbacks

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
