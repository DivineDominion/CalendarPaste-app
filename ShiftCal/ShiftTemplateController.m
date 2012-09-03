//
//  ShiftTemplateController.m
//  ShiftCal
//
//  Created by Christian Tietze on 03.09.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "ShiftTemplateController.h"

@implementation ShiftTemplateController

+ (NSString *)durationTextForHours:(NSInteger)hours andMinutes:(NSInteger)minutes
{
    NSString *minutesString = @"";
    NSString *hoursString   = [NSString stringWithFormat:@"%dh", hours];
    
    if (minutes > 0) {
        minutesString = [NSString stringWithFormat:@" %dmin", minutes];
        
        if (hours == 0) {
            hoursString = @"";
        }
    }
    
    return [NSString stringWithFormat:@"%@%@", hoursString, minutesString];
}

@end
