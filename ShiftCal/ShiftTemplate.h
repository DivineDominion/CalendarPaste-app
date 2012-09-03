//
//  ShiftTemplate.h
//  ShiftCal
//
//  Created by Christian Tietze on 25.07.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShiftTemplate : NSObject
{
    NSString *_title;
    NSString *_location;
    
    NSInteger *_hours;
    NSInteger *_minutes;
    
    NSString *_url;
    
    NSString *_note;
    
    // TODO _calendar;
    // TODO _reminder;
}

@property (nonatomic, copy,   readwrite) NSString *title;
@property (nonatomic, assign, readwrite) NSInteger *hours;
@property (nonatomic, assign, readwrite) NSInteger *minutes;

//@property (nonatomic, copy, readwrite) NSDate   *from;
//@property (nonatomic, copy, readwrite) NSDate   *until;

//- (id)initWithTitle:(NSString *)title from:(NSDate *)from until:(NSDate *)until;
//- (id)initWithTitle:(NSString *)title duration:(NSTimeInterval *)duration;

@end
