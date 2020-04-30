//
//  SignupViewController.h
//  momentsapp
//
//  Created by Joshua Balogun on 8/9/13.
//
//

#import <UIKit/UIKit.h>
#define kFilename @"data.sqlite3"

@class MBProgressHUD;

@interface SignupViewController : UIViewController<UITextFieldDelegate>
{
    
    int animatedDis;
    int dismisskeypad;
}

@property (nonatomic, strong) UIAlertView *alert;
@property (nonatomic, strong) IBOutlet UITextField *userTextField;
@property (nonatomic, strong) IBOutlet UITextField *phoneTextField;
@property (nonatomic, strong) IBOutlet UITextField *emailTextField;
@property (nonatomic, strong) IBOutlet UITextField *passwordTextField;
@property (nonatomic, strong) IBOutlet UITextField *confirmpassTextField;
@property (nonatomic, strong) IBOutlet UITextField *dobTextField;
@property (nonatomic, weak) IBOutlet UIButton *signupButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *titleButton;
@property (nonatomic, strong) IBOutlet UIView *signupFrame;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) NSDictionary *jsonResponse;
@property (nonatomic, strong) NSArray *loginParams;

- (IBAction)backBtnPressed:(id)sender;
- (IBAction)signUpPressed:(id)sender;
- (NSString *)dataFilePath;

@end
