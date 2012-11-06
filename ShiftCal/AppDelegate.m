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
    
    // TODO display 'grant access' screen
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];

    if ([EKEventStore instancesRespondToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        // TODO fallback to "please grant access" screen
        self.window.rootViewController = [[[UIViewController alloc] init] autorelease];
        
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
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
