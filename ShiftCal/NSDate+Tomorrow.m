//
//  NSDate+Tomorrow.m
//  ShiftCal
//
//  Created by Christian Tietze on 24.01.13.
//  Copyright (c) 2013 Christian Tietze. All rights reserved.
//

#import "NSDate+Tomorrow.h"

@implementation NSDate (Tomorrow)

+ (NSDate *)tomorrow {
	NSDate *date = [NSDate date];
	
    NSDateComponents *components = [[[NSDateComponents alloc] init] autorelease];
	[components setDay:1];
	
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
	return [calendar dateByAddingComponents:components toDate:date options:0];
}

@end
