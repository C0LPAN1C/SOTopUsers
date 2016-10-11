//
//  SOViewController.m
//  SOTopUsers
//
//  Created by Amit Barman on 10/5/16.
//  Copyright (c) 2016 Apollo Software All rights reserved.
//

#import "SOViewController.h"
#import "SOFetcher.h"

@interface SOViewController ()

@property (weak, nonatomic) IBOutlet UIWebView *WebView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activitySpinner;

@end

@implementation SOViewController

- (void) setUser:(NSDictionary *)user {
    _user = user;
    [self updateUI];
}

- (NSString *)userBody {
    return _userBody ? _userBody : @"?";
}

- (NSString *)getBadgeInfo {
    NSDictionary *badges = self.user[SO_USER_BADGES];
    
    NSString *goldBadges = [badges objectForKey:@"gold"];
    NSString *silverBadges = [badges objectForKey:@"silver"];
    NSString *bronzeBadges = [badges objectForKey:@"bronze"];
    
    return [NSString stringWithFormat:@"<font face='Arial' color='white'><center><b><font color='gold'>● </b></font>%@ <font color='silver'><b>● </b></font>%@ <font color='bronze'><b>● </b></font>%@</center></font><br><br>",
                              goldBadges,
                              silverBadges,
                              bronzeBadges];
    
}


- (void)downloadImage:(NSString *)url userid:(NSString *)uid {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"Downloading Started");
        NSString *urlToDownload = url;
        NSURL  *url = [NSURL URLWithString:urlToDownload];
        NSData *urlData = [NSData dataWithContentsOfURL:url];
        if ( urlData ) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            NSString *filePath = [NSString stringWithFormat:@"%@/%@%@", documentsDirectory,uid,@".png"];
            
                    //saving is done on main thread
                    dispatch_async(dispatch_get_main_queue(), ^{
                    [urlData writeToFile:filePath atomically:YES];
                        NSLog(@"File Saved !");
                        [self loadUserBody];
                });
            
        }
        
    });
}

- (NSString *)grabUserInformation {
    NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString  *documentsDirectory = [paths objectAtIndex:0];
    NSString  *filePath = [NSString stringWithFormat:@"%@/%@%@", documentsDirectory,self.user[SO_USER_ACCOUNT_ID],@".png"];

    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
        [self downloadImage:self.user[SO_USER_IMAGE_URL] userid:self.user[SO_USER_ACCOUNT_ID]];
    
    NSString* URLPath = [NSString stringWithFormat:@"%@.png",self.user[SO_USER_ACCOUNT_ID]];
    
    if (!URLPath) {
        URLPath = self.user[SO_USER_IMAGE_URL];
    }

    return [NSString stringWithFormat:@"<body  bgcolor=\"black\"><table><tr><th><img src=\"%@\"></th><th></th><th align='left'></b><b><font face='Arial' color='white'><font align='left'>   Account ID: </b>%@</div><br><b>  Reputation: </b>%@<br><b>   Location: </b>%@<br><b>   Age: </b>%@ (yrs)<br><a href=\"%@\">    Profile URL</a></left></font></th></tr>%@</table></body>",
            URLPath,
            self.user[SO_USER_ACCOUNT_ID],
            self.user[SO_USER_REPUTATION],
            self.user[SO_USER_LOCATION],
            self.user[SO_USER_AGE],
            self.user[SO_USER_LINK_URL],
            [self getBadgeInfo]];
}

- (void)loadUserBody {
    if (self.user) {
        [self.activitySpinner startAnimating];
        
        NSString *body = [self grabUserInformation];
        NSArray       *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString  *documentsDirectory = [paths objectAtIndex:0];
        NSURL *baseURL = [NSURL fileURLWithPath:documentsDirectory];
        [self.WebView loadHTMLString:body baseURL:baseURL];
        [self.activitySpinner stopAnimating];
    } else {
        self.userBody = nil;
    }
}

- (void)updateUI {
    NSLog(@"%@", self.user);
    self.navigationItem.title = self.user[SO_USER_DISPLAY_NAME];
    [self loadUserBody];
    NSLog(@"%@", self.userBody);
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateUI];
}

- (void)presentActivityController:(UIActivityViewController *)controller {
    controller.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:controller animated:YES completion:nil];
    
    UIPopoverPresentationController *popController = [controller popoverPresentationController];
    popController.permittedArrowDirections = UIPopoverArrowDirectionAny;
    popController.barButtonItem = self.navigationItem.leftBarButtonItem;
    
    // access the completion handler
    controller.completionWithItemsHandler = ^(NSString *activityType,
                                              BOOL completed,
                                              NSArray *returnedItems,
                                              NSError *error){
        // react to the completion
        if (completed) {
            
            // user shared an item
            NSLog(@"We used activity type%@", activityType);
            
        } else {
            
            // user cancelled
            NSLog(@"We didn't want to share anything after all.");
        }
        
        if (error) {
            NSLog(@"An Error occured: %@, %@", error.localizedDescription, error.localizedFailureReason);
        }
    };
}

-(NSData *)getImageFromView:(UIView *)view {
    NSData *pngImg;
    CGFloat max, scale = 1.0;
    CGSize viewSize = [view bounds].size;
    
    // Get the size of the the FULL Content, not just the bit that is visible
    CGSize size = [view sizeThatFits:CGSizeZero];
    
    // Scale down if on iPad to something more reasonable
    max = (viewSize.width > viewSize.height) ? viewSize.width : viewSize.height;
    if( max > 960 )
        scale = 960/max;
    
    UIGraphicsBeginImageContextWithOptions( size, YES, scale );
    
    // Set the view to the FULL size of the content.
    [view setFrame: CGRectMake(0, 0, size.width, size.height)];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    pngImg = UIImagePNGRepresentation( UIGraphicsGetImageFromCurrentImageContext() );
    
    UIGraphicsEndImageContext();
    return pngImg;    // Voila an image of the ENTIRE CONTENT, not just visible bit
}

- (IBAction)shareButtonTest:(id)sender {
    NSLog(@"Sharing Data");
    
    NSData *compressedImage = [self getImageFromView:self.WebView];
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"%@.png",self.user[SO_USER_ACCOUNT_ID]];
    NSString *imagePath = [docsPath stringByAppendingPathComponent:fileName];
    NSURL *imageUrl     = [NSURL fileURLWithPath:imagePath];
    
    [compressedImage writeToURL:imageUrl atomically:YES]; // save the file
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[ @"Check this out!", imageUrl ] applicationActivities:nil];
    // and present it
    [self presentActivityController:controller];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
