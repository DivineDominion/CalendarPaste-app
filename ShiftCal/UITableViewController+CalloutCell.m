//
//  UITableViewController+CalloutCell.m
//  ShiftCal
//
//  Created by Christian Tietze on 18.11.12.
//  Copyright (c) 2012 Christian Tietze. All rights reserved.
//

#import "UITableViewController+CalloutCell.h"

@implementation UITableViewController (CalloutCell)
- (void)calloutCell:(NSIndexPath *)indexPath
{
    __weak UITableViewController *welf = self;
    [UIView animateWithDuration:0.0
                          delay:0.0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^() {
                         [[welf.tableView cellForRowAtIndexPath:indexPath] setHighlighted:YES animated:YES];
                     }
                     completion:^(BOOL finished) {
                         [[welf.tableView cellForRowAtIndexPath:indexPath] setHighlighted:NO animated:YES];
                     }];
}
@end
