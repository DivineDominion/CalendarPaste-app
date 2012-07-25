//
//  ShiftTemplate.h
//  ShiftCal
//
//  Created by Christian Tietze on 25.07.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShiftTemplate : NSObject

@property NSString *title;
@property NSDate   *from;
@property NSDate   *until;

-(id)initWithTitle:(NSString *)title from:(NSDate *)from until:(NSDate *)until;

@end
