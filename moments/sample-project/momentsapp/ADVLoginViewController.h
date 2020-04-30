//
//  ADVLoginViewController.h
//  apartmentshare
//
//  Created by Tope Abayomi on 22/01/2013.
//  Copyright (c) 2013 App Design Vault. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kFilename @"data.sqlite3"

@class MBProgressHUD;

@interface ADVLoginViewController : UIViewController

@property (nonatomic, strong) UIAlertView *alert;

@property (nonatomic, strong) IBOutlet UITextField *userTextField;

@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;

@property (nonatomic, weak) IBOutlet UIButton *loginButton;

@property (nonatomic, weak) IBOutlet UIButton *signupButton;

@property (nonatomic, strong) NSArray *loginParams;

@property (nonatomic, strong) NSString *apikey;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSDictionary *jsonResponse;

@property (nonatomic, strong) NSDictionary *profileData;

@property (nonatomic, strong) MBProgressHUD *HUD;

-(IBAction)signUpPressed:(id)sender;
-(IBAction)logInPressed:(id)sender;
-(IBAction)forgotpasswordPressed:(id)sender;
-(IBAction) textFieldDoneEditing:(id) sender;
- (NSString *)dataFilePath;

@end
