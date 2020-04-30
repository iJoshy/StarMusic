//
//  phonesignupViewController.h
//  momentsapp
//
//  Created by Joshua Balogun on 9/29/13.
//
//


#import <UIKit/UIKit.h>
#define kFilename @"data.sqlite3"

@interface phonesignupViewController : UIViewController<UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UINavigationControllerDelegate>
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
@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *titleButton;
@property (nonatomic, strong) IBOutlet UIView *signupFrame;
@property (nonatomic, strong) IBOutlet UIImageView *loginview;
@property (nonatomic, strong) IBOutlet UIImageView *fieldsview;
@property (nonatomic, strong) NSDictionary *jsonResponse;
@property (nonatomic, strong) NSArray *loginParams;
@property(nonatomic, retain) UIDatePicker *birthdayDatePicker;

@property(nonatomic, retain) UIToolbar *keyboardToolbar;
@property(nonatomic, retain) NSDate *birthday;

- (IBAction)backBtnPressed:(id)sender;
- (IBAction)signUpPressed:(id)sender;
- (NSString *)dataFilePath;

@end
