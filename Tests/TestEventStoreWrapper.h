//
//  TestEventStoreWrapper.h
//  ShiftCal
//
//  Created by Christian Tietze on 16/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestEventStoreWrapper : NSObject
@property (nonatomic, assign) BOOL isAuthorizedForCalendarAccess;
@property (nonatomic, strong) id eventStore;
@property (nonatomic, strong) id defaultCalendar;
@property (nonatomic, copy) NSString *defaultCalendarIdentifier;

@property (nonatomic, readonly) BOOL didRequestAccess;
- (void)requestEventAccessWithGrantedBlock:(void (^)())closure;
@end
