//
//  UserCalendarProvider.m
//  ShiftCal
//
//  Created by Christian Tietze on 15/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import "UserCalendarProvider.h"
#import "EventStoreWrapper.h"

#import "CTKNotificationCenter.h"
#import "CTKUserDefaults.h"

NSString * const SCStoreChangedNotification = @"SCStoreChanged";
NSString * const kKeyNotificationDefaultCalendar = @"defaultCalendarIdentifier";
NSString * const kKeyPrefsDefaultCalendar = @"DefaultCalendar";

@interface UserCalendarProvider ()
@property (nonatomic, strong, readwrite) EventStoreWrapper *eventStoreWrapper;
@property (nonatomic, strong, readwrite) EKCalendar *defaultCalendar;
@end

@implementation UserCalendarProvider
static UserCalendarProvider *_sharedInstance = nil;
static dispatch_once_t once_token = 0;

+ (instancetype)sharedInstance
{
    dispatch_once(&once_token, ^{
        if (_sharedInstance == nil)
        {
            EKEventStore *eventStore = [[EKEventStore alloc] init];
            EventStoreWrapper *wrapper = [[EventStoreWrapper alloc] initWithEventStore:eventStore];
            _sharedInstance = [[UserCalendarProvider alloc] initWithEventStoreWrapper:wrapper];
        }
    });
    
    return _sharedInstance;
}

+ (void)setSharedInstance:(UserCalendarProvider *)instance
{
    once_token = 0; // resets the once_token so dispatch_once will run again
    _sharedInstance = instance;
}

+ (void)resetSharedInstance
{
    [self setSharedInstance:nil];
}

+ (instancetype)calendarProviderWithEventStoreWrapper:(EventStoreWrapper *)eventStoreWrapper
{
    return [[self alloc] initWithEventStoreWrapper:eventStoreWrapper];
}

- (instancetype)init
{
    return [self initWithEventStoreWrapper:nil];
}

- (instancetype)initWithEventStoreWrapper:(EventStoreWrapper *)eventStoreWrapper
{
    NSParameterAssert(eventStoreWrapper);
    
    self = [super init];
    if (self)
    {
        _eventStoreWrapper = eventStoreWrapper;
        
        [self.notificationCenter addObserver:self
                                    selector:@selector(eventStoreChanged:)
                                        name:EKEventStoreChangedNotification
                                      object:_eventStoreWrapper.eventStore];
    }
    
    return self;
}

- (void)dealloc
{
    EKEventStore *eventStore = _eventStoreWrapper.eventStore;
    [self.notificationCenter removeObserver:self name:EKEventStoreChangedNotification object:eventStore];
}

- (NSUserDefaults *)standardUserDefaults
{
    return [CTKUserDefaults standardUserDefaults];
}

- (NSNotificationCenter *)notificationCenter
{
    return [CTKNotificationCenter defaultCenter];
}

- (EKEventStore *)eventStore
{
    return self.eventStoreWrapper.eventStore;
}


#pragma mark -
#pragma mark Accessing the default calendar

- (NSString *)userDefaultCalendarIdentifier
{
    NSUserDefaults *prefs = [self standardUserDefaults];
    return [prefs objectForKey:kKeyPrefsDefaultCalendar];
}

- (void)setUserDefaultCalendarIdentifier:(NSString *)userDefaultCalendarIdentifier
{
    NSUserDefaults *prefs = [self standardUserDefaults];
    [prefs setObject:userDefaultCalendarIdentifier forKey:kKeyPrefsDefaultCalendar];
#ifdef DEVELOPMENT
    [prefs synchronize];
#endif
}

- (EKCalendar *)userDefaultCalendar
{
    EKEventStore *eventStore = self.eventStore;
    NSString *calendarIdentifier = [self userDefaultCalendarIdentifier];
    EKCalendar *defaultCalendar = [eventStore calendarWithIdentifier:calendarIdentifier];
    
    return defaultCalendar;
}

#pragma mark -

- (void)eventStoreChanged:(NSNotification *)notification
{
    if ([self isAuthorizedForCalendarAccess])
    {
        [self registerPreferenceDefaults];
        [self broadcastStoreChange];
    }
}

- (BOOL)isAuthorizedForCalendarAccess
{
    return [self.eventStoreWrapper isAuthorizedForCalendarAccess];
}

- (void)registerPreferenceDefaults
{
    if ([self needsUserDefaultSetup])
    {
        [self registerDefaultCalendarUserDefaults];
        return;
    }

    [self checkUserDefaultsIntegrity];
}

- (BOOL)needsUserDefaultSetup
{
    NSString *calendarIdentifier = [self userDefaultCalendarIdentifier];
    return calendarIdentifier == nil;
}

- (void)registerDefaultCalendarUserDefaults
{
    NSUserDefaults *prefs = [self standardUserDefaults];
    EventStoreWrapper *eventStoreWrapper = self.eventStoreWrapper;
    NSString *defaultCalendarIdentifier = [eventStoreWrapper defaultCalendarIdentifier];
    NSAssert(defaultCalendarIdentifier, @"we assume there's at least 1 calendar present"); // TODO make more lenient
    
    self.defaultCalendar = [eventStoreWrapper defaultCalendar];
    
    [prefs setObject:defaultCalendarIdentifier forKey:kKeyPrefsDefaultCalendar];
#ifdef DEVELOPMENT
    [prefs synchronize];
#endif
}

- (void)checkUserDefaultsIntegrity
{
    // Perform sanity check: was Calendar deleted?
    EKCalendar *calendar = self.userDefaultCalendar;
    
    if (calendar == nil)
    {
        [self registerDefaultCalendarUserDefaults];
    }
}

- (void)broadcastStoreChange
{
    if ([self needsUserDefaultSetup]) {
        return;
    }
    
    NSString *calendarIdentifier = [self userDefaultCalendarIdentifier];
    NSDictionary *userInfo = @{ kKeyNotificationDefaultCalendar : calendarIdentifier };
    [self.notificationCenter postNotificationName:SCStoreChangedNotification object:self userInfo:userInfo];
}

@end
