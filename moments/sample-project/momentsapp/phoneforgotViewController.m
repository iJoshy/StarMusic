//
//  phoneforgotViewController.m
//  momentsapp
//
//  Created by Joshua Balogun on 9/29/13.
//
//


#import "phoneforgotViewController.h"
#import "SVProgressHUD.h"
#import "SimpleFlickrAPI.h"

@interface phoneforgotViewController ()

@end

@implementation phoneforgotViewController

@synthesize titleButton, sendButton, emailTextField;
@synthesize signupFrame, backButton, loginParams;


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
    

    [self.backButton setBackgroundImage:[UIImage imageNamed:@"button-grrey.png"] forState:UIControlStateNormal];
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"button-grey-down.png"] forState:UIControlStateHighlighted];

    
    [self.sendButton setBackgroundImage:[UIImage imageNamed:@"button-green.png"] forState:UIControlStateNormal];
    [self.sendButton setBackgroundImage:[UIImage imageNamed:@"button-green-down.png"] forState:UIControlStateHighlighted];
    
}

- (IBAction)backBtnPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)retrievePressed:(id)sender
{
    NSLog(@"Clicked button to sign up ::::");
    
    [SVProgressHUD show];
    
    [self fetchFlickrPhotoWithSearchString];
}

- (void)fetchFlickrPhotoWithSearchString
{
    
    //NSLog(@" Starting- going to fetch images .....");
    loginParams = [[NSArray alloc] initWithObjects:@"forgotpassword",emailTextField.text,nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSDictionary *photos = [flickr forgotpassword:loginParams];
                       NSLog(@" Starting- going to fetch images .....%@",photos);
                       
                       [self setJsonResponse:photos];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self authenticateuser];
                           [SVProgressHUD dismiss];
                       });
                   });
}

- (void)authenticateuser
{
    
    NSDictionary *flickrPhoto = [self jsonResponse];
    
    NSString *description = [flickrPhoto objectForKey:@"description"];
    
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign-In!"
                                                    message:description
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    
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

