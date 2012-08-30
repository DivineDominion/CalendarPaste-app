//
//  ShiftTemplate.m
//  ShiftCal
//
//  Created by Christian Tietze on 25.07.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftTemplate.h"

@implementation ShiftTemplate

@synthesize title = _title;
@synthesize from  = _from;
@synthesize until = _until;

- (id)initWithTitle:(NSString *)title
               from:(NSDate *)from
              until:(NSDate *)until
{
    self = [super init];
    
    if (self) {
        self.title = title;
        self.from  = from;
        self.until = until;
        
        return self;
    }
    
    return nil;
}

@end
