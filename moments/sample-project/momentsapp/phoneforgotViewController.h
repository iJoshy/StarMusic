//
//  phoneforgotViewController.h
//  momentsapp
//
//  Created by Joshua Balogun on 9/29/13.
//
//

#import <UIKit/UIKit.h>

@interface phoneforgotViewController : UIViewController<UITextFieldDelegate>
{
    
    int animatedDis;
    int dismisskeypad;
}

@property (nonatomic, strong) IBOutlet UITextField *emailTextField;
@property (nonatomic, weak) IBOutlet UIButton *sendButton;
@property (nonatomic, weak) IBOutlet UIButton *backButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *titleButton;
@property (nonatomic, strong) IBOutlet UIView *signupFrame;
@property (nonatomic, strong) NSDictionary *jsonResponse;
@property (nonatomic, strong) NSArray *loginParams;

- (IBAction)backBtnPressed:(id)sender;
- (IBAction)retrievePressed:(id)sender;

@end