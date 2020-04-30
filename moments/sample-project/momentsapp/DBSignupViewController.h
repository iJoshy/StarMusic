//
//  DBSignupViewController.h
//  DBSignup
//
//  Created by Davide Bettio on 7/4/11.
//  Copyright 2011 03081340121. All rights reserved.
//

#import <UIKit/UIKit.h>
#define kFilename @"data.sqlite3"

@interface DBSignupViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    UIScrollView *scrollview;
    UITextField *nameTextField_;
    UITextField *lastNameTextField_;
    UITextField *emailTextField_;
    UITextField *passwordTextField_;
    UITextField *birthdayTextField_;
    UITextField *genderTextField_;
    UITextField *phoneTextField_;
    UIButton *photoButton_;
    UIButton *changePassword_;
    UITextView *termsTextView_;
    
    UILabel *emailLabel_;
    UILabel *passwordLabel_;
    UILabel *birthdayLabel_;
    UILabel *genderLabel_;
    UILabel *phoneLabel_;
    
    UIToolbar *keyboardToolbar_;
    UIPickerView *genderPickerView_;
    UIDatePicker *birthdayDatePicker_;
    
    NSDate *birthday_;
    NSString *gender_;
    UIImage *photo_;
    
}

@property(nonatomic, retain) IBOutlet UIScrollView *scrollview;
@property(nonatomic, retain) IBOutlet UITextField *nameTextField;
@property(nonatomic, retain) IBOutlet UITextField *lastNameTextField;
@property(nonatomic, retain) IBOutlet UITextField *emailTextField;
@property(nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property(nonatomic, retain) IBOutlet UITextField *birthdayTextField;
@property(nonatomic, retain) IBOutlet UITextField *genderTextField;
@property(nonatomic, retain) IBOutlet UITextField *phoneTextField;
@property(nonatomic, retain) IBOutlet UIButton *photoButton;
@property(nonatomic, retain) IBOutlet UIButton *changePassword;
@property(nonatomic, retain) IBOutlet UITextView *termsTextView;

@property(nonatomic, retain) IBOutlet UILabel *emailLabel;
@property(nonatomic, retain) IBOutlet UILabel *passwordLabel;
@property(nonatomic, retain) IBOutlet UILabel *birthdayLabel;
@property(nonatomic, retain) IBOutlet UILabel *genderLabel;
@property(nonatomic, retain) IBOutlet UILabel *phoneLabel;
@property(nonatomic, retain) IBOutlet UIView *profileView;

@property(nonatomic, retain) UIToolbar *keyboardToolbar;
@property(nonatomic, retain) UIPickerView *genderPickerView;
@property(nonatomic, retain) UIDatePicker *birthdayDatePicker;

@property(nonatomic, strong) NSArray *loginParams;
@property(nonatomic, retain) NSDate *birthday;
@property(nonatomic, retain) NSString *gender;
@property(nonatomic, retain) NSString *userkey;
@property(nonatomic, retain) UIImage *photo;
@property(nonatomic, retain) NSDictionary *response;

- (IBAction)choosePhoto:(id)sender;
- (IBAction)update:(id)sender;
- (IBAction)logout:(id)sender;

- (void)resignKeyboard:(id)sender;
- (void)previousField:(id)sender;
- (void)nextField:(id)sender;
- (id)getFirstResponder;
- (void)animateView:(NSUInteger)tag;
- (void)checkBarButton:(NSUInteger)tag;
- (void)checkSpecialFields:(NSUInteger)tag;
- (void)setBirthdayData;
- (void)setGenderData;
- (void)birthdayDatePickerChanged:(id)sender;
- (void)resetLabelsColors;
- (NSString *)dataFilePath;

+ (UIColor *)labelNormalColor;
+ (UIColor *)labelSelectedColor;

@end
