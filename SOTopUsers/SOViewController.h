//
//  SOViewController.h
//  SOTopUsers
//
//  Created by Amit Barman on 10/5/16.
//  Copyright (c) 2016 Apollo Software All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SOViewController : UIViewController

@property (nonatomic) NSDictionary *user;
@property (nonatomic, strong) NSString *userBody;
- (IBAction)shareButtonTest:(id)sender;
@end
