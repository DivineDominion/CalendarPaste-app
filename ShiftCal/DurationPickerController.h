//
//  DurationSetViewController.h
//  ShiftCal
//
//  Created by Christian Tietze on 31.08.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DurationPickerDelegate.h"

@interface DurationPickerController : NSObject <UIPickerViewDataSource, UIPickerViewDelegate>
@property (nonatomic, assign) NSInteger hours;
@property (nonatomic, assign) NSInteger minutes;
@property (nonatomic, strong, readonly) UIPickerView *pickerView;

@property (nonatomic, weak) id<DurationPickerDelegate> delegate;

- (instancetype)initWithHours:(NSInteger)hours andMinutes:(NSInteger)minutes NS_DESIGNATED_INITIALIZER;



@end
