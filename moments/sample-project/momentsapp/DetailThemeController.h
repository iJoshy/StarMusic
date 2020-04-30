//
//  DetailThemeController.h
//  blogplex
//
//  Created by Tope on 27/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Model.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface DetailThemeController : UIViewController<UIWebViewDelegate, MFMailComposeViewControllerDelegate, FBUserSettingsDelegate>

@property (nonatomic, strong) IBOutlet UIBarButtonItem* share;
@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UILabel* dateLabel;
@property (nonatomic, strong) IBOutlet UIWebView* articleWebView;
@property (nonatomic, strong) IBOutlet UIScrollView* scrollView;
@property (nonatomic, strong) IBOutlet UIImageView* articleImageView;
@property (nonatomic, strong) IBOutlet UIView* shadowView;
@property (nonatomic, retain) Model* model;
@property (nonatomic, strong) NSString *userKey;
@property (nonatomic, strong) NSString *whichView;
@property (nonatomic, strong) NSString *commentID;
@property (nonatomic, strong) NSString *noLikes;
@property (nonatomic, strong) NSString *noComments;
@property (nonatomic, strong) NSString *titlelabel;
@property (nonatomic, strong) NSString *imagePath;

-(UIBarButtonItem*)createBackBarButtonWithImage:(NSString*)imageName;

-(void)back;

@end
