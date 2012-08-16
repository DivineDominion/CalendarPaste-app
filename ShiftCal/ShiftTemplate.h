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
    NSString *title_;

    NSDate *from_;
    NSDate *until_;
    
    NSString *location_;
    NSString *note_;
    NSString *url_;
    
    // TODO calendar_;
    // TODO reminder_;
}

@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, copy, readwrite) NSDate   *from;
@property (nonatomic, copy, readwrite) NSDate   *until;

- (id)initWithTitle:(NSString *)title from:(NSDate *)from until:(NSDate *)until;

@end
