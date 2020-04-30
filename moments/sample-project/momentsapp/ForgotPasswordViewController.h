//
//  SignupViewController.h
//  momentsapp
//
//  Created by Joshua Balogun on 8/9/13.
//
//

#import <UIKit/UIKit.h>

@interface ForgotPasswordViewController : UIViewController<UITextFieldDelegate>
{
    
    int animatedDis;
    int dismisskeypad;
}

@property (nonatomic, weak) IBOutlet UIButton *signupButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *titleButton;
@property (nonatomic, strong) IBOutlet UIView *signupFrame;

- (IBAction)backBtnPressed:(id)sender;
@end
