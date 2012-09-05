//
//  CalendarPickerController.h
//  ShiftCal
//
//  Created by Christian Tietze on 04.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EventKitUI/EventKitUI.h>

@interface CalendarPickerController : UITableViewController
{
    EKEventStore *_eventStore;
}

@property (nonatomic, retain) EKEventStore *eventStore;

@end
