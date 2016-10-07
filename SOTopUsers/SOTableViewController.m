//
//  SOTableViewController.m
//  SOTopUsers
//
//  Created by Amit Barman on 10/5/16.
//  Copyright (c) 2016 Apollo Software All rights reserved.
//

#import "SOTableViewController.h"
#import "SOFetcher.h"

@interface SOTableViewController ()

@end

@implementation SOTableViewController

- (void)setSoUsers:(NSArray *)soUsers {
    _soUsers = soUsers;
    [self.tableView reloadData];
}


- (NSString *)titleForRow:(NSUInteger)row {
    NSLog(@"%@", self.soUsers[row]);
    return [NSString stringWithFormat:@"%lu.) %@ (%@)",(unsigned long)row+1,[self.soUsers[row][SO_USER_DISPLAY_NAME] description], [self.soUsers[row][SO_USER_REPUTATION] description]];
}

- (NSString *)subtitleForRow:(NSUInteger)row {
        return [NSString stringWithFormat:@"%@, (%@ yrs)",[self.soUsers[row][SO_USER_LOCATION] description], [self.soUsers[row][SO_USER_AGE] description]]; //
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.soUsers.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SOUserCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [self titleForRow:indexPath.row];
    cell.detailTextLabel.text = [self subtitleForRow:indexPath.row];    
    return cell;
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"ShowUsers"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setUser:)]) {
                    NSDictionary *user = [SOFetcher getUser:self.soUsers atIndex:indexPath.row];
                    [segue.destinationViewController performSelector:@selector(setUser:) withObject:user];
                }
            }
        }
    }
}

@end
