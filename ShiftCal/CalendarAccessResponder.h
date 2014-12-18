//
//  CalendarAccessResponder.h
//  ShiftCal
//
//  Created by Christian Tietze on 18/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CalendarAccessResponder <NSObject>
- (void)activate;
@end

@protocol CalendarAccessResponderUnlock <CalendarAccessResponder>
/// Determines whether the unlock screen is displayed from the start or after
/// the lock screen has been shown.
- (void)setUnlocksImmediately:(BOOL)isImmediate;
@end
