//
//  AppDelegate.h
//  ShiftCal
//
//  Created by Christian Tietze on 25.07.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKit/EventKit.h>

@class ShiftOverviewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    EKEventStore *_eventStore;
}

// public properties
@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain, readonly) EKEventStore *eventStore;

@end
