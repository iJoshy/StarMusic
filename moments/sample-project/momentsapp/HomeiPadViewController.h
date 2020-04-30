//
//  HomeiPadViewController.h
//  momentsapp
//
//  Created by M.A.D on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "ASIHTTPRequestDelegate.h"
#import "ASIProgressDelegate.h"

@class MBProgressHUD;

@interface HomeiPadViewController : UIViewController <UIActionSheetDelegate, ASIHTTPRequestDelegate, ASIProgressDelegate, MFMailComposeViewControllerDelegate, FBUserSettingsDelegate>
{
    IBOutlet UIView *commentsView;
    IBOutlet UITableView *table;
    
    IBOutlet UIView *bigPhoto2;
    IBOutlet UIView *bigPhotoFrame;
    IBOutlet UIImageView *bigPhoto;
    
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIToolbar *toolbar;
    
    IBOutlet UIBarButtonItem *titleButton;
    IBOutlet UIBarButtonItem *backButton;
    IBOutlet UIBarButtonItem *downloadButton;
    IBOutlet UIBarButtonItem *share;
    IBOutlet UITextField *commentTextField;
    IBOutlet UIButton *like;
    
    float sentSize;
}

@property (nonatomic, strong) NSString *whichView;
@property (nonatomic, retain) NSString *catergoryID;
@property (nonatomic, strong) NSArray *jsonResponse;
@property (nonatomic, strong) NSMutableArray *downloaders;
@property (nonatomic, retain) NSArray *comments;
@property (nonatomic, strong) IBOutlet UILabel* noComments;
@property (nonatomic, strong) IBOutlet UILabel* noLikes;
@property (nonatomic, retain) NSString *thumbnail;
@property (nonatomic, retain) NSString *bigimage;
@property (nonatomic, retain) NSString *videoIndex;
@property (nonatomic, retain) NSString *commentId;
@property (nonatomic, strong) NSString *userKey;
@property (nonatomic, strong) IBOutlet UILabel* moreLabel;
@property (nonatomic, retain) UIImageView *bigPhoto;
@property (nonatomic, retain) UIImage *homePhoto;
@property (nonatomic, retain) UIWebView *videoView;
@property (nonatomic, strong) UIBarButtonItem *backButton;
@property (nonatomic, strong) UIBarButtonItem *titleButton;
@property (nonatomic, strong) UIBarButtonItem *downloadButton;
@property (nonatomic, strong) UIBarButtonItem *share;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) UITableView *table;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) UIToolbar *toolbar;

- (IBAction)downloadPressed:(id)sender;
- (IBAction)btnPressed:(id)sender;
- (IBAction)backBtnPressed:(id)sender;
- (IBAction) textFieldDoneEditing:(id) sender;
- (IBAction)likeTapped:(id)sender;

@end
