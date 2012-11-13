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

- (void)showOverviewViewControllerAnimated:(BOOL)animated;
- (UIViewController *)grantCalendarAccessViewController;
@end


@implementation AppDelegate
@synthesize eventStore = _eventStore;

- (void)dealloc
{
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
        
        self.window.rootViewController = self.navController;
    }
    else
    {
        [self showOverviewViewControllerAnimated:NO];
        self.window.rootViewController = self.navController;
    }

    [self.window makeKeyAndVisible];
    return YES;
}

- (void)showOverviewViewControllerAnimated:(BOOL)animated
{
    [self registerPreferenceDefaults];
    
    [self.navController pushViewController:[[[ShiftOverviewController alloc] init] autorelease]
                                  animated:animated];
}

- (UIViewController *)grantCalendarAccessViewController
{
    UIViewController *grantCalendarAccessViewController = [[UIViewController alloc] init];
    
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    view.backgroundColor = [UIColor whiteColor];
    
    // Lock Icon
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock.png"]];
    imageView.center = CGPointMake(160.0, 160.0);
    
    //Labels
    UIColor *textColor = [UIColor colorWithRed:0.5 green:0.53 blue:0.58 alpha:1.0];
    
    static float kXOffset = 10.0f;
    static float kYOffset = 280.0f;
    static float kWidth   = 300.0f; // 320 - 2 * x-offset
    static float kHeight  = 40.0f;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kXOffset, kYOffset, kWidth, kHeight)];
    label.numberOfLines = 2;
    label.text          = @"This app needs Calendar access\nto work.";
    label.font          = [UIFont boldSystemFontOfSize:18.0f];
    label.textColor     = textColor;
    label.textAlignment = NSTextAlignmentCenter;
    
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(kXOffset, kYOffset + kHeight, kWidth, kHeight)];
    detailLabel.text          = @"You can enable access\nin Privacy Settings.";
    detailLabel.font          = [UIFont systemFontOfSize:15.0f];
    detailLabel.textColor     = textColor;
    detailLabel.textAlignment = NSTextAlignmentCenter;

    [view addSubview:imageView];
    [view addSubview:label];
    [view addSubview:detailLabel];
    
    [imageView release];
    [label release];
    [detailLabel release];

    grantCalendarAccessViewController.view = view;
    [view release];
    
    return [grantCalendarAccessViewController autorelease];
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
