//
//  iPadPhotoViewController.h
//  momentsapp
//
//  Created by Joshua Balogun on 8/2/13.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioViewController.h"
#import "PopoverSegment.h"
#import "AQGridView.h"
#import "ASIHTTPRequestDelegate.h"
#import "ASIProgressDelegate.h"
#import "MBProgressHUD.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface iPadPhotoViewController : UIViewController<AQGridViewDelegate, AQGridViewDataSource, PopoverSegmentDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ASIHTTPRequestDelegate, ASIProgressDelegate, MBProgressHUDDelegate, UIPopoverControllerDelegate, MFMailComposeViewControllerDelegate, FBUserSettingsDelegate, UIActionSheetDelegate>
{
    float totalSize;
    float sentSize;
}

@property (nonatomic, strong) AQGridView * gridView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* refresh;
@property (nonatomic, strong) IBOutlet UIBarButtonItem* share;
@property (nonatomic, strong) AudioViewController *audioView;
@property (nonatomic, weak) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) IBOutlet UIView *contentFrame;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) IBOutlet PopoverSegment *ctrl;
@property (nonatomic, strong) NSMutableArray *loadJsonResponse;
@property (nonatomic, strong) NSArray *jsonResponse;
@property (nonatomic, strong) NSMutableArray *downloaders;
@property (nonatomic, strong) NSString *whichView;
@property (nonatomic, strong) NSString *thumbnail;
@property (nonatomic, strong) NSString *celltitle;
@property (nonatomic, strong) NSString *image;
@property (nonatomic, strong) NSString *userKey;
@property (nonatomic, strong) NSString *videoIndex;
@property (nonatomic, strong) UIImage *imageSelected;
@property (nonatomic, strong) NSString *detailSegue;
@property (nonatomic, retain) NSString *catergoryID;
@property (nonatomic, retain) NSString *pageno;
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIPopoverController *popOver;
@property (nonatomic, strong) UIPopoverController *audioPopOver;
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) NSDictionary *uploadVideoPath;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

- (IBAction) refreshTapped:(id) sender;

@end