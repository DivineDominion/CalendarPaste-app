//
//  ShiftAddDelegate.h
//  ShiftCal
//
//  Created by Christian Tietze on 16.08.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShiftAddController.h"

@protocol ShiftAddDelegate <NSObject>

- (void)shiftAddViewController:(ShiftAddController *)shiftAddViewController
                   didAddShift:(id)shift;

@end
