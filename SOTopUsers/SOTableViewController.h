//
//  SOTableViewController.h
//  SOTopUsers
//
//  Created by Amit Barman on 10/5/16.
//  Copyright (c) 2016 Apollo Software All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOTableViewController : UITableViewController <UITextFieldDelegate>
@property (nonatomic, strong) NSArray *soUsers; //of NSDictionary
@property (nonatomic, strong) IBOutlet UITextField *searchBox;
- (IBAction)searchButton:(id)sender;
@end

