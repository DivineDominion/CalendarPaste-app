//
//  ShiftTemplate.h
//  ShiftCal
//
//  Created by Christian Tietze on 25.07.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ShiftTemplate : NSObject

@property (nonatomic, copy)   NSString *title;
@property (nonatomic, strong) NSDate   *from;
@property (nonatomic, strong) NSDate   *until;

- (id)initWithTitle:(NSString *)title from:(NSDate *)from until:(NSDate *)until;

@end
