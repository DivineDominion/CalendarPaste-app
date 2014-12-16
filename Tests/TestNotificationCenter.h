//
//  TestNotificationCenter.h
//  ShiftCal
//
//  Created by Christian Tietze on 16/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestNotificationCenter : NSNotificationCenter
@property (nonatomic, strong) NSMutableArray *notifications;
@property (nonatomic, readonly) BOOL didReceiveNotifications;
@end
