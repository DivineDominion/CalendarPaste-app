//
//  TestNotificationCenter.m
//  ShiftCal
//
//  Created by Christian Tietze on 16/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import "TestNotificationCenter.h"

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
