//
//  SOController.h
//  SOTopUsers
//
//  Created by Amit Barman on 10/5/16.
//  Copyright (c) 2016 Apollo Software All rights reserved.
//

#import "SOTableViewController.h"

@interface SOController : SOTableViewController

- (void)showThis;
- (void)hideThis;
- (void)mutateCounter:(NSUInteger)change;

@end
