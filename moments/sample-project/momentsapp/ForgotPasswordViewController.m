//
//  SignupViewController.m
//  momentsapp
//
//  Created by Joshua Balogun on 8/9/13.
//
//

#import "ForgotPasswordViewController.h"

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController

@synthesize titleButton, signupButton;
@synthesize signupFrame;

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    dismisskeypad = 0;
    
    CGRect newFrame = CGRectZero;
    
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    if (UIInterfaceOrientationIsLandscape(deviceOrientation))
    {
        newFrame = CGRectMake(340, 130, 360,523);
    }
    else
    {
        newFrame = CGRectMake(232, 232, 360, 523);
    }
    
    [signupFrame setFrame:newFrame];
    [[self view] setBackgroundColor:[UIColor clearColor]];
}

- (void)layoutForLandscape
{
    CGRect newFrame = CGRectMake(340, 130, 360,523);
    [signupFrame setFrame:newFrame];
}

- (void)layoutForPortrait
{
    CGRect newFrame = CGRectMake(232, 232, 360, 523);
    [signupFrame setFrame:newFrame];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        [self layoutForLandscape];
    }
    else
    {
        [self layoutForPortrait];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextField:textField up:YES method:@"showpad"];
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self animateTextField:textField up:NO method:@"dismisspad"];
}


-(IBAction) doneEditing:(id) sender
{
    [self animateTextField:sender up:NO method:@"return"];
}


- (void) animateTextField: (UITextField*) textField up: (BOOL) up method: (NSString *) method
{
    
    if ( dismisskeypad == 0 )
    {
        CGPoint temp = [textField.superview convertPoint:textField.frame.origin toView:nil];
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        
        if(orientation == UIInterfaceOrientationLandscapeLeft)
        {
            if(up)
            {
                int moveUpValue = temp.x + textField.frame.size.height;
                animatedDis = 352 - (768 - moveUpValue - 15);
            }
        }
        else if(orientation == UIInterfaceOrientationLandscapeRight)
        {
            if(up)
            {
                int moveUpValue = 768-temp.x + textField.frame.size.height;
                animatedDis = 352 - (768 - moveUpValue - 15);
            }
            
        }
        
        
        if(animatedDis > 0)
        {
            const int movementDistance = animatedDis;
            const float movementDuration = 0.3f;
            int movement = (up ? -movementDistance : movementDistance);
            
            [UIView beginAnimations: nil context: nil];
            [UIView setAnimationBeginsFromCurrentState: YES];
            [UIView setAnimationDuration: movementDuration];
            
            if(orientation == UIInterfaceOrientationLandscapeLeft)
            {
                
                self.view.superview.frame = CGRectOffset(self.view.superview.frame, movement, 0);
            }
            else if(orientation == UIInterfaceOrientationLandscapeRight)
            {
                self.view.superview.frame = CGRectOffset(self.view.superview.frame, -movement, 0);
            }
            
            [UIView commitAnimations];
        }
    }
    
    if ([method isEqualToString:@"dismisspad"])
	{
		dismisskeypad = 0;
    }
    
	if ([method isEqualToString:@"return"])
	{
		dismisskeypad = 1;
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"landscapeBG.png"]];
    
    imageView.frame = self.view.bounds;
    imageView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.view addSubview:imageView];
    [self.view sendSubviewToBack:imageView];
    
    [self.signupButton setBackgroundImage:[UIImage imageNamed:@"button-green.png"] forState:UIControlStateNormal];
    [self.signupButton setBackgroundImage:[UIImage imageNamed:@"button-green-down.png"] forState:UIControlStateHighlighted];
    
    UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0 , 0, 50, 250)];
    [titlelabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
    [titlelabel setBackgroundColor:[UIColor clearColor]];
    [titlelabel setTextColor:[UIColor whiteColor]];
    [titlelabel setTextAlignment:NSTextAlignmentCenter];
    
    
    titlelabel.text = @"Forgot Password";
    UIView *view = (UIView *) titlelabel;
    [self.titleButton setCustomView:view];
    
}

- (IBAction)backBtnPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
