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

#import "UserCalendarProvider.h"

@interface AppDelegate ()
@property (nonatomic, strong, readwrite) UINavigationController *navController;
@property (nonatomic, strong, readwrite) UIColor *appColor;

@property (nonatomic, strong, readwrite) CalendarAccessGuard *calendarAccessGuard;
@end


@implementation AppDelegate

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self.navController pushViewController:viewController animated:animated];
}

- (void)grantCalendarAccess
{
    NSLog(@"granted");
    [[UserCalendarProvider sharedInstance] registerPreferenceDefaults];
}


#pragma mark - Launch and Set-Up

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.appColor      = [UIColor colorWithRed:116.0/255 green:128.0/255 blue:199.0/255 alpha:1.0];
    [self styleNavigationBar];
    
    self.window        = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.navController = [[UINavigationController alloc] init];
    
    [self guardCalendarAccess];
    
    self.window.rootViewController = self.navController;
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)guardCalendarAccess
{
    CalendarAccessGuard *calendarAccessGuard = [[CalendarAccessGuard alloc] init];
    calendarAccessGuard.delegate = self;
    self.calendarAccessGuard = calendarAccessGuard;
    
    [calendarAccessGuard guardCalendarAccess];
}

- (void)styleNavigationBar
{
    UIColor *topBarColor = [self appColor];
    UIColor *creamWhiteColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0];
    
    [[UINavigationBar appearance] setBarTintColor:topBarColor];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    NSDictionary *titleAttributes = @{NSForegroundColorAttributeName: creamWhiteColor,
                                     NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:21.0]};
    [[UINavigationBar appearance] setTitleTextAttributes: titleAttributes];
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
