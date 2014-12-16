//
//  CalendarProvider.m
//  ShiftCal
//
//  Created by Christian Tietze on 15/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import "CalendarProvider.h"
#import "EventStore.h"

#import "CTKNotificationCenter.h"
#import "CTKUserDefaults.h"

NSString * const SCStoreChangedNotification = @"SCStoreChanged";
NSString * const kKeyNotificationDefaultCalendar = @"defaultCalendarIdentifier";
NSString * const kKeyPrefsDefaultCalendar = @"DefaultCalendar";

@interface CalendarProvider ()
@property (nonatomic, strong, readwrite) EventStore *eventStoreWrapper;
@property (nonatomic, strong, readwrite) EKCalendar *defaultUserCalendar;
@end

@implementation CalendarProvider
static CalendarProvider *_sharedInstance = nil;
static dispatch_once_t once_token = 0;

+ (instancetype)sharedInstance
{
    dispatch_once(&once_token, ^{
        if (_sharedInstance == nil)
        {
            EKEventStore *eventStore = [[EKEventStore alloc] init];
            EventStore *wrapper = [[EventStore alloc] initWithEventStore:eventStore];
            _sharedInstance = [[CalendarProvider alloc] initWithEventStore:wrapper];
        }
    });
    
    return _sharedInstance;
}

+ (void)setSharedInstance:(CalendarProvider *)instance
{
    once_token = 0; // resets the once_token so dispatch_once will run again
    _sharedInstance = instance;
}

+ (void)resetSharedInstance
{
    [self setSharedInstance:nil];
}

- (instancetype)init
{
    return [self initWithEventStore:nil];
}

- (instancetype)initWithEventStore:(EventStore *)eventStore
{
    NSParameterAssert(eventStore);
    
    self = [super init];
    if (self)
    {
        _eventStoreWrapper = eventStore;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
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

- (NSString *)defaultCalendarIdentifier
{
    NSUserDefaults *prefs = [self standardUserDefaults];
    return [prefs objectForKey:kKeyPrefsDefaultCalendar];
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
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    return status == EKAuthorizationStatusAuthorized;
}

- (void)broadcastStoreChange
{
    NSString *defaultCalendarIdentifier = [self defaultCalendarIdentifier];
    
    if (defaultCalendarIdentifier == nil)
    {
        return;
    }
    
    NSDictionary *userInfo = @{ kKeyNotificationDefaultCalendar : defaultCalendarIdentifier };
    [[NSNotificationCenter defaultCenter] postNotificationName:SCStoreChangedNotification object:self userInfo:userInfo];
}

- (void)registerPreferenceDefaults
{
    NSString *defaultCalendarIdentifier = [self defaultCalendarIdentifier];
    
    if (defaultCalendarIdentifier == nil)
    {
        // Initial setup
        [self registerDefaultCalendarUserDefaults];
    }
    else
    {
        // Consecutive call
        // Perform sanity check: was Calendar deleted?
        EKEventStore *eventStore = self.eventStore;
        EKCalendar *defaultCalendar = [eventStore calendarWithIdentifier:defaultCalendarIdentifier];
        
        if (defaultCalendar == nil) {
            [self registerDefaultCalendarUserDefaults];
        }
    }
}

- (void)registerDefaultCalendarUserDefaults
{
    NSUserDefaults *prefs = [self standardUserDefaults];
    EKEventStore *eventStore = self.eventStore;
    NSString *defaultCalendarIdentifier = [eventStore defaultCalendarForNewEvents].calendarIdentifier;
    self.defaultUserCalendar = [eventStore calendarWithIdentifier:defaultCalendarIdentifier];
    
    [prefs setObject:defaultCalendarIdentifier forKey:kKeyPrefsDefaultCalendar];
#ifdef DEVELOPMENT
    [prefs synchronize];
#endif
}

@end
