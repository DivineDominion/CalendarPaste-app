//
//  UserCalendarProviderTests.m
//  ShiftCal
//
//  Created by Christian Tietze on 16/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "UserCalendarProvider.h"

#import "TestEventStoreWrapper.h"
#import "CTKNotificationCenter.h"
#import "TestNotificationCenter.h"
#import "CTKUserDefaults.h"
#import "TestUserDefaults.h"

@interface UserCalendarProviderTests : XCTestCase
@end

@implementation UserCalendarProviderTests
{
    UserCalendarProvider *calendarProvider;
    
    TestNotificationCenter *testNotificationCenter;
    TestEventStoreWrapper *testEventStoreWrapper;
    TestUserDefaults *testUserDefaults;
}

- (void)setUp {
    [super setUp];
    
    testNotificationCenter = [[TestNotificationCenter alloc] init];
    [CTKNotificationCenter setSharedInstance:[CTKNotificationCenter notificationCenterWith:testNotificationCenter]];
    
    testUserDefaults = [[TestUserDefaults alloc] init];
    [CTKUserDefaults setSharedInstance:[CTKUserDefaults userDefaultsWith:(id)testUserDefaults]];
    
    testEventStoreWrapper = [[TestEventStoreWrapper alloc] init];
    calendarProvider = [[UserCalendarProvider alloc] initWithEventStoreWrapper:(id)testEventStoreWrapper];
}

- (void)tearDown {
    [CTKUserDefaults resetSharedInstance];
    [CTKNotificationCenter resetSharedInstance];
    [super tearDown];
}

- (void)testStoreChange_Unauthorized_DoesntBroadcast {
    testEventStoreWrapper.isAuthorizedForCalendarAccess = NO;
    
    [calendarProvider eventStoreChanged:nil];
    
    XCTAssertFalse(testNotificationCenter.didReceiveNotifications);
}

- (void)testStoreChange_Authorized_BroadcastCalendar {
    testEventStoreWrapper.isAuthorizedForCalendarAccess = YES;
    NSString *calendarIdentifier = @"the identifier";
    testEventStoreWrapper.defaultCalendarIdentifier = calendarIdentifier;
    
    [calendarProvider eventStoreChanged:nil];
    
    XCTAssert(testNotificationCenter.didReceiveNotifications);
    NSDictionary *userInfo = [testNotificationCenter.notifications.firstObject objectForKey:@"userInfo"];
    XCTAssertEqual(userInfo[kKeyNotificationDefaultCalendar], calendarIdentifier);
}

@end
