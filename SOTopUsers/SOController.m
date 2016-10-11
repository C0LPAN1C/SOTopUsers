//
//  SOController.m
//  SOTopUsers
//
//  Created by Amit Barman on 10/5/16.
//  Copyright (c) 2016 Apollo Software All rights reserved.
//

#import "SOController.h"
#import "SOFetcher.h"

@interface SOController ()

@end

@implementation SOController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadTopSOUsers];
    [self.refreshControl addTarget:self
                            action:@selector(loadTopSOUsers)
                  forControlEvents:(UIControlEventValueChanged)];
    [self showBeginningAlert];
}

- (void)refreshController {
    NSLog(@"%@",@"Should refresh!");
    [self loadTopSOUsers];
}

- (void)showBeginningAlert {
    UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:@"Welcome to Stack Overflow Top Users. Click a record to view more details or search users by typing in Search Criteria and pressing search or the search icon."  message:nil  preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)loadTopSOUsers {
    [self.refreshControl beginRefreshing];
    if ([SOFetcher fetchSearchCriteria].length < 1) {
        [self displayTopUsers];
    } else {
        [self displaySearch];
    }
}
- (void)displaySearch {
    dispatch_queue_t loadSO= dispatch_queue_create("search users", NULL);
    dispatch_async(loadSO, ^{
        [self showThis];
        NSArray *topSOUsers = [SOFetcher searchSOUsers:[SOFetcher fetchSearchCriteria]];
        [self hideThis];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.soUsers = topSOUsers;
            [self.refreshControl endRefreshing];
        });
    });
}

- (void)displayTopUsers {
    dispatch_queue_t loadSO= dispatch_queue_create("top users", NULL);
    dispatch_async(loadSO, ^{
        [self showThis];
        NSArray *topSOUsers = [SOFetcher topSOUsers];
        [self hideThis];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.soUsers = topSOUsers;
            [self.refreshControl endRefreshing];
        });
    });
}

- (void)searchSOUsers: (NSString*) searchCriteria {
    [self.refreshControl beginRefreshing];
    dispatch_queue_t loadSO= dispatch_queue_create("top users", NULL);
    dispatch_async(loadSO, ^{
        [self showThis];
        NSArray *topSOUsers = [SOFetcher searchSOUsers:(NSString*)searchCriteria];
        [self hideThis];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.soUsers = topSOUsers;
            [self.refreshControl endRefreshing];
        });
    });
}


- (void)mutateCounter:(NSUInteger)change {
    static NSUInteger counter = 0;
    static dispatch_queue_t queue;
    if (!queue) {
        queue = dispatch_queue_create("GlobalNetworkActivity Queue", NULL);
    }
    dispatch_sync(queue, ^{
        if (counter + change <= 0) {
            counter = 0;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        } else {
            counter += change;
            [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        }
    });
}

- (void)showThis {
    [self mutateCounter:1];
}

- (void)hideThis {
    [self mutateCounter:-1];
}

@end
