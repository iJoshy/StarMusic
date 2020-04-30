//
//  MasterViewController.h
//  mapper
//
//  Created by Tope on 09/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "PopoverSegment.h"
#import "CommentViewController.h"


@class MBProgressHUD;

@interface MasterViewController : UIViewController <UITableViewDelegate, FBUserSettingsDelegate, UITableViewDataSource,UIWebViewDelegate, PopoverSegmentDelegate, UISearchBarDelegate, MFMailComposeViewControllerDelegate, UIPopoverControllerDelegate>

@property (nonatomic, strong) IBOutlet UIBarButtonItem* refresh;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* share;
@property (nonatomic, strong) IBOutlet UITableView* masterTableView;
@property (nonatomic, strong) IBOutlet UIToolbar* toolbar;
@property (nonatomic, strong) IBOutlet PopoverSegment *ctrl;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UILabel* dateLabel;
@property (nonatomic, strong) IBOutlet UIWebView* articleWebView;
@property (nonatomic, strong) IBOutlet UIScrollView* scrollView;
@property (nonatomic, strong) IBOutlet UIImageView* articleImageView;
@property (nonatomic, strong) IBOutlet UIView* shadowView;
@property (nonatomic, strong) IBOutlet UIView* sideGradientView;
@property (nonatomic, strong) IBOutlet UIView *tagContainer;
@property (nonatomic, strong) IBOutlet UIView* newsView;
@property (nonatomic, strong) IBOutlet UIView* listView;
@property (nonatomic, strong) IBOutlet UIView *commentView;
@property (nonatomic, strong) IBOutlet UIButton *commentButton;
@property (nonatomic, strong) IBOutlet UITextField *commentTextField;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) NSMutableArray *jsonResponse;
@property (nonatomic, strong) NSMutableArray *downloaders;
@property (nonatomic, strong) NSString *whichView;
@property (nonatomic, strong) NSString *userKey;
@property (nonatomic, strong) NSString *newcomment;
@property (nonatomic, strong) NSString *toggleComment;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) NSString *commentId;
@property (nonatomic, strong) NSString *catergoryID;
@property (nonatomic, strong) NSString *selectedCell;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) NSString *pageno;
@property (nonatomic, strong) NSArray *segmentedItems;
@property (nonatomic, strong) IBOutlet UILabel *title2Label;
@property (nonatomic, strong) UIPopoverController *commentPopOver;
@property (nonatomic, strong) CommentViewController *commentTableView;

-(IBAction)commentPressed:(id)sender;
-(NSDate*)getDateFromString:(NSString*)dateString;
-(NSString*)addCSSTo:(NSString*)content;
-(IBAction) refreshTapped:(id) sender;

@end

