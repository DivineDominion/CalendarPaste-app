//
//  CalendarAccessGuardTests.m
//  ShiftCal
//
//  Created by Christian Tietze on 16/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "CalendarAccessGuard.h"

#import "CalendarAccessResponder.h"
#import "UserCalendarProvider.h"
#import "TestEventStoreWrapper.h"


@interface TestCalendarAccessGuardDelegate : NSObject <CalendarAccessGuardDelegate>
@property (nonatomic, assign, readonly) BOOL didGrantCalendarAccess;
@property (nonatomic, strong, readonly) id pushedViewController;
@end
@implementation TestCalendarAccessGuardDelegate
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    _pushedViewController = viewController;
}

- (void)grantCalendarAccess
{
    _didGrantCalendarAccess = YES;
}
@end

@interface TestLockResponder : NSObject <CalendarAccessResponder>
@property (nonatomic, assign, readonly) BOOL didActivate;
@end
@implementation TestLockResponder
- (void)activate
{
    _didActivate = YES;
}
@end

@interface TestUnlockResponder : TestLockResponder <CalendarAccessResponderUnlock>
@property (nonatomic, assign, readwrite) BOOL unlocksImmediately;
@end
@implementation TestUnlockResponder
@end

@interface CalendarAccessGuardTests : XCTestCase
@end

@implementation CalendarAccessGuardTests
{
    CalendarAccessGuard *guard;
    
    TestCalendarAccessGuardDelegate *testDelegate;
    TestLockResponder *testLockResponder;
    TestUnlockResponder *testUnlockResponder;
    TestEventStoreWrapper *testEventStoreWrapper;
}

- (void)setUp {
    [super setUp];
    
    testEventStoreWrapper = [[TestEventStoreWrapper alloc] init];
    [UserCalendarProvider setSharedInstance:[UserCalendarProvider calendarProviderWithEventStoreWrapper:(id)testEventStoreWrapper]];
    
    testDelegate = [[TestCalendarAccessGuardDelegate alloc] init];
    testLockResponder = [[TestLockResponder alloc] init];
    testUnlockResponder = [[TestUnlockResponder alloc] init];
    guard = [[CalendarAccessGuard alloc] initWithLockResponder:testLockResponder unlockResponder:testUnlockResponder];
    guard.delegate = testDelegate;
}

- (void)tearDown {
    [UserCalendarProvider resetSharedInstance];
    [super tearDown];
}

- (void)testGuard_WithoutAuth_RequestsAccess {
    testEventStoreWrapper.isAuthorizedForCalendarAccess = NO;
    
    [guard guardCalendarAccess];
    
    XCTAssert(testEventStoreWrapper.didRequestAccess);
    XCTAssert(testLockResponder.didActivate);
    XCTAssertFalse(testDelegate.didGrantCalendarAccess);
    XCTAssertFalse(testUnlockResponder.didActivate);
}

- (void)testGuard_WitAuth_RequestsAccess {
    testEventStoreWrapper.isAuthorizedForCalendarAccess = YES;
    
    [guard guardCalendarAccess];
    
    XCTAssertFalse(testEventStoreWrapper.didRequestAccess);
    XCTAssert(testLockResponder.didActivate);
    XCTAssert(testDelegate.didGrantCalendarAccess);
    XCTAssert(testUnlockResponder.didActivate);
}

@end
