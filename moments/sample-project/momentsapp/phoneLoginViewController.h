//
//  phoneLoginViewController.h
//  momentsapp
//
//  Created by Joshua Balogun on 9/29/13.
//
//

#import <UIKit/UIKit.h>
#define kFilename @"data.sqlite3"

@interface phoneLoginViewController : UIViewController

@property (nonatomic, strong) UIAlertView *alert;

@property (nonatomic, strong) IBOutlet UITextField *userTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;
@property (nonatomic, strong) IBOutlet UIImageView *loginview;
@property (nonatomic, weak) IBOutlet UIButton *loginButton;
@property (nonatomic, weak) IBOutlet UIButton *forgotButton;
@property (nonatomic, weak) IBOutlet UIButton *signupButton;

@property (nonatomic, strong) NSArray *loginParams;

@property (nonatomic, strong) NSString *apikey;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSDictionary *jsonResponse;

@property (nonatomic, strong) NSDictionary *profileData;

-(IBAction)signUpPressed:(id)sender;
-(IBAction)logInPressed:(id)sender;
-(IBAction)forgotpasswordPressed:(id)sender;
-(IBAction) textFieldDoneEditing:(id) sender;
- (NSString *)dataFilePath;

@end

