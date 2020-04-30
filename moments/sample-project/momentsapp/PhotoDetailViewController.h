//
//  PhotoDetailViewController.h
//  momentsapp
//
//  Created by Joshua Balogun on 9/25/13.
//
//

#import <UIKit/UIKit.h>
#import "Model.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ASIHTTPRequestDelegate.h"
#import "ASIProgressDelegate.h"

@interface PhotoDetailViewController : UIViewController <UIWebViewDelegate, MFMailComposeViewControllerDelegate, FBUserSettingsDelegate, UIActionSheetDelegate, ASIHTTPRequestDelegate, ASIProgressDelegate>

@property (nonatomic, strong) IBOutlet UIBarButtonItem* share;
@property (nonatomic, strong) IBOutlet UIButton *downloadButton;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UILabel* dateLabel;
@property (nonatomic, strong) IBOutlet UIScrollView* scrollView;
@property (nonatomic, strong) IBOutlet UIImageView* articleImageView;
@property (nonatomic, strong) IBOutlet UIView* shadowView;
@property (nonatomic, strong) IBOutlet UIView *tagContainer;
@property (nonatomic, retain) Model* model;
@property (nonatomic, strong) NSString *userKey;
@property (nonatomic, strong) NSString *whichView;
@property (nonatomic, strong) NSString *commentID;
@property (nonatomic, strong) NSString *noLikes;
@property (nonatomic, strong) NSString *noComments;
@property (nonatomic, strong) NSString *titlelabel;
@property (nonatomic, strong) NSString *imagePath;

-(UIBarButtonItem*)createBackBarButtonWithImage:(NSString*)imageName;
- (IBAction)downloadPressed:(id)sender;

-(void)back;

@end
