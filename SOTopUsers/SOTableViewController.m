//
//  SOTableViewController.m
//  SOTopUsers
//
//  Created by Amit Barman on 10/5/16.
//  Copyright (c) 2016 Apollo Software All rights reserved.
//

#import "SOTableViewController.h"
#import "SOFetcher.h"
#import "SOController.h"

@interface SOTableViewController ()
@end

@implementation SOTableViewController

- (void)viewDidLoad {
    _searchBox.delegate = self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self searchUser];
    return NO;
}

-(BOOL)textFieldShouldClear:(UITextField *)textField {
    [SOFetcher setSearchCriteria:[textField text]];
    textField.text = @"";
    [textField resignFirstResponder];
    [self topUsers];
    return NO;
}

- (void)setSoUsers:(NSArray *)soUsers {
    _soUsers = soUsers;
    [self.tableView reloadData];
}

- (void) searchUser {
    if ([_searchBox text].length > 2) {
        NSLog(@"%@ing %@", @"Search",[_searchBox text]);
        [SOFetcher setSearchCriteria:[_searchBox text]];
        [self.tableView reloadData];
        
        [self.refreshControl beginRefreshing];
        dispatch_queue_t loadSO= dispatch_queue_create("top users", NULL);
        dispatch_async(loadSO, ^{
            NSArray *topSOUsers = [SOFetcher searchSOUsers:(NSString*)[_searchBox text]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.soUsers = topSOUsers;
                [self.refreshControl endRefreshing];
            });
        });
    } else {
        [self throwErrorMessage];
    }
}

- (void) topUsers {
    [self.tableView reloadData];
    _searchBox.text = @"";
    [SOFetcher setSearchCriteria:@""];
    [self.refreshControl beginRefreshing];
    dispatch_queue_t loadSO= dispatch_queue_create("top users", NULL);
    dispatch_async(loadSO, ^{
        NSArray *topSOUsers = [SOFetcher topSOUsers];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.soUsers = topSOUsers;
            [self.refreshControl endRefreshing];
        });
    });

}
- (IBAction)searchButton:(id)sender {
    [self searchUser];
}

- (void)throwErrorMessage {
    UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:@"You must enter more than 2 characters to search for a user."  message:nil  preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Back" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self topUsers];
        [_searchBox resignFirstResponder];
        [self dismissViewControllerAnimated:YES completion:nil];
           }]];
    [self presentViewController:alertController animated:YES completion:nil];
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
