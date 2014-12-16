//
//  TestEventStoreWrapper.m
//  ShiftCal
//
//  Created by Christian Tietze on 16/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import "TestEventStoreWrapper.h"

@implementation TestEventStoreWrapper
- (void)requestEventAccessWithGrantedBlock:(void (^)())closure
{
    _didRequestAccess = YES;
}
@end
