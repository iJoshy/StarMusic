//
//  MainViewController.h
//  momentsapp
//
//  Created by Joshua Balogun on 8/8/13.
//
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "PopoverDemoController.h"
#import "MasterViewController.h"
#import "iPadPhotoViewController.h"
#import "MapViewController.h"
#import "ADVLoginViewController.h"
#define kFilename @"data.sqlite3"

@interface MainViewController : UIViewController <PopoverDemoControllerDelegate, FBUserSettingsDelegate>

@property (nonatomic, strong) UILabel *titlelabel;
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *titleButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *showPopoverButton;
@property (nonatomic, strong) UIPopoverController *menuPopover;
@property (nonatomic, strong) PopoverDemoController *menuPicker;
@property (nonatomic, strong) IBOutlet UIImageView *bgimage;

@property (nonatomic, strong) UIStoryboard *storyboard;
@property (nonatomic, strong) ADVLoginViewController *loginScene;
@property (nonatomic, strong) MasterViewController *newsScene;
@property (nonatomic, strong) iPadPhotoViewController *galleryScene;
@property (nonatomic, strong) MapViewController *mapScene;
@property (nonatomic, strong) UIView *labelview;
@property (nonatomic, strong) NSString *userKey;
@property (strong, nonatomic) NSDictionary<FBGraphUser> *user;


- (IBAction)chooseMenu:(id)sender;
- (NSString *)dataFilePath;
- (void)sessionStateChanged:(NSNotification*)notification;
- (void)populateUserDetails;

@end