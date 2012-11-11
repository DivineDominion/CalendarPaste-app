//
//  AppDelegate.m
//  ShiftCal
//
//  Created by Christian Tietze on 25.07.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "AppDelegate.h"

#import "ShiftOverviewController.h"

@interface AppDelegate ()

// private properties
@property (nonatomic, retain, readwrite) UINavigationController *navController;
@property (nonatomic, retain, readwrite) EKEventStore *eventStore;

- (void)setupOverviewController;
@end


@implementation AppDelegate
@synthesize eventStore = _eventStore;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.eventStore = [[[EKEventStore alloc] init] autorelease];
    self.window     = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    if ([EKEventStore instancesRespondToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        self.window.rootViewController = [self grantCalendarAccessViewController];
        
        [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted)
            {
                [self setupOverviewController];
            }
            else
            {
                NSLog(@"access (still) denied");
            }
        }];
    }
    else
    {
        [self setupOverviewController];
    }

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)setupOverviewController
{
    [self registerPreferenceDefaults];
    
    ShiftOverviewController *viewController = [[ShiftOverviewController alloc] init];
    self.navController  = [[[UINavigationController alloc] initWithRootViewController:viewController] autorelease];
    [viewController release];
    
    self.window.rootViewController = self.navController;    
}

- (UIViewController *)grantCalendarAccessViewController
{
    UIViewController *grantCalendarAccessViewController = [[[UIViewController alloc] init] autorelease];
    
    UIColor *backgroundColor = [UIColor colorWithRed:210.0/256 green:210.0/256 blue:230.0/256 alpha:1.0];
    CGRect frame = [[UIScreen mainScreen] bounds];
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = backgroundColor;
    
    frame = CGRectMake(20, 120, 300, 100);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.numberOfLines = 2;
    label.text = @"Please grant Calendar Access\nin your device's Settings\nfor this app to work.";
    label.font = [UIFont boldSystemFontOfSize:28.0f];
    label.textColor = [UIColor colorWithWhite:0.3 alpha:0.6];
    label.backgroundColor = backgroundColor;
    label.shadowColor = [UIColor lightTextColor];
    label.shadowOffset = CGSizeMake(0.5, 1);
    
    [view addSubview:label];

    
    [view addSubview:label];
    
    grantCalendarAccessViewController.view = [view autorelease];
    
    return grantCalendarAccessViewController;
}

- (void)dealloc
{
    [_navController release];
    [_eventStore release];
    
    [super dealloc];
}

#pragma mark User preferences

- (void)registerPreferenceDefaults
{
    NSString *defaultCalendarIdentifier = [self.eventStore defaultCalendarForNewEvents].calendarIdentifier;
    NSDictionary *calendarDefaults      = [NSDictionary dictionaryWithObject:defaultCalendarIdentifier
                                                                      forKey:PREFS_DEFAULT_CALENDAR_KEY];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:calendarDefaults];

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
    
    // TODO check access privileges
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
