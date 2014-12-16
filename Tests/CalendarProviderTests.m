//
//  CalendarProviderTests.m
//  ShiftCal
//
//  Created by Christian Tietze on 16/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "CalendarProvider.h"

#import "CTKNotificationCenter.h"
#import "CTKUserDefaults.h"
#import "EventStore.h"

@interface TestNotificationCenter : NSNotificationCenter
@property (nonatomic, strong) NSMutableArray *notifications;
@end

@implementation TestNotificationCenter
- (NSArray *)notifications {
    if (!_notifications) {
        _notifications = [NSMutableArray array];
    }
    
    return _notifications;
}

- (BOOL)didReceiveNotifications {
    return self.notifications && self.notifications.count > 0;
}

- (void)postNotificationName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo {
    NSDictionary *notification = @{@"name" : aName, @"object" : anObject, @"userInfo" : aUserInfo};
    [self.notifications addObject:notification];
}

- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject { /* no op */ }
- (void)removeObserver:(id)observer { /* no op */ }
- (void)removeObserver:(id)observer name:(NSString *)aName object:(id)anObject { /* no op */ }
@end

@interface TestUserDefaults : NSObject
@property (nonatomic, strong) NSMutableDictionary *defaultsStub;
@end

@implementation TestUserDefaults

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _defaultsStub = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (id)objectForKey:(NSString *)defaultName {
    return self.defaultsStub[defaultName];
}

- (void)setObject:(id)value forKey:(NSString *)defaultName {
    if (value == nil) {
        value = [NSNull null];
    }
    
    self.defaultsStub[defaultName] = value;
}

- (void)setURL:(NSURL *)url forKey:(NSString *)defaultName {
    [self setObject:url forKey:defaultName];
}

- (void)setBool:(BOOL)value forKey:(NSString *)defaultName {
    [self setObject:@(value) forKey:defaultName];
}

- (void)setInteger:(NSInteger)value forKey:(NSString *)defaultName {
    [self setObject:@(value) forKey:defaultName];
}

- (void)setDouble:(double)value forKey:(NSString *)defaultName {
    [self setObject:@(value) forKey:defaultName];
}

- (void)setFloat:(float)value forKey:(NSString *)defaultName {
    [self setObject:@(value) forKey:defaultName];
}

- (void)synchronize { /* no op */ }

@end

@interface TestEventStoreWrapper : NSObject
@property (nonatomic, assign) BOOL isAuthorizedForCalendarAccess;
@property (nonatomic, strong) id eventStore;
@property (nonatomic, strong) id defaultCalendar;
@property (nonatomic, copy) NSString *defaultCalendarIdentifier;
@end

@implementation TestEventStoreWrapper
@end

@interface CalendarProviderTests : XCTestCase
@end

@implementation CalendarProviderTests
{
    CalendarProvider *calendarProvider;
    
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
    calendarProvider = [[CalendarProvider alloc] initWithEventStore:(id)testEventStoreWrapper];
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
