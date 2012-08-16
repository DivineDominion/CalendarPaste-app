//
//  ShiftAddController.h
//  ShiftCal
//
//  Created by Christian Tietze on 16.08.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShiftTemplate.h"
#import "ShiftAddDelegate.h"
#import "ShiftAddView.h"

@interface ShiftAddViewController : UIViewController
{
    id <ShiftAddDelegate> addDelegate_;

    ShiftTemplate *shift_;
}

@property (nonatomic, assign) id <ShiftAddDelegate> addDelegate;
@property (nonatomic, retain) ShiftTemplate *shift;

- (void)save:(id)sender;
- (void)cancel:(id)sender;

@end
