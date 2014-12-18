//
//  UnlockApp.m
//  ShiftCal
//
//  Created by Christian Tietze on 18/12/14.
//  Copyright (c) 2014 Christian Tietze. All rights reserved.
//

#import "UnlockApp.h"

@implementation UnlockApp
- (instancetype)init
{
    return [self initWithViewController:nil navigationController:nil];
}

- (instancetype)initWithViewController:(UIViewController *)viewController navigationController:(UINavigationController *)navigationController
{
    NSParameterAssert(viewController);
    NSParameterAssert(navigationController);

    self = [super init];
    
    if (self)
    {
        _viewController = viewController;
        _navigationController = navigationController;
    }
    
    return self;
}


#pragma mark -

- (void)activate
{
    [self.navigationController pushViewController:self.viewController animated:!self.unlocksImmediately];
}

@end
