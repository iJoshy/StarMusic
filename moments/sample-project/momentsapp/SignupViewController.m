//
//  SignupViewController.m
//  momentsapp
//
//  Created by Joshua Balogun on 8/9/13.
//
//

#import "SignupViewController.h"
#import "SimpleFlickrAPI.h"
#import "MBProgressHUD.h"
#import <sqlite3.h>

@implementation SignupViewController

@synthesize userTextField,passwordTextField,confirmpassTextField,dobTextField,phoneTextField,emailTextField;
@synthesize titleButton, signupButton, HUD;
@synthesize signupFrame, alert, loginParams;


- (NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kFilename];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    dismisskeypad = 0;
    
    CGRect newFrame = CGRectZero;
    
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    if (UIInterfaceOrientationIsLandscape(deviceOrientation))
    {
        newFrame = CGRectMake(320, 120, 360,523);
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
    CGRect newFrame = CGRectMake(320, 120, 360,523);
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
    
    
    //Add the First Child Scene
    
    titlelabel.text = @"Sign Up";
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)signUpPressed:(id)sender
{
    NSLog(@"Clicked button to sign up ::::");
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"Processing ...";
    [self.view addSubview:HUD];
    
    loginParams = [[NSArray alloc] initWithObjects:@"signin", userTextField.text, phoneTextField.text,emailTextField.text,confirmpassTextField.text,dobTextField.text, nil];
    
    [HUD showWhileExecuting:@selector(fetchFlickrPhotoWithSearchString) onTarget:self withObject:nil animated:YES];
    
}

#pragma mark - Flickr

- (void)fetchFlickrPhotoWithSearchString
{
    
    //NSLog(@" Starting- going to fetch images .....");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSDictionary *photos = [flickr signinProcess:loginParams];
                       
                       [self setJsonResponse:photos];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self authenticateuser];
                           [HUD removeFromSuperview];
                           HUD = nil;
                       });
                   });
}

- (void)authenticateuser
{
    
    NSDictionary *flickrPhoto = [self jsonResponse];
    
    NSString *status = [flickrPhoto objectForKey:@"status"];
    NSString *description = [flickrPhoto objectForKey:@"description"];
    
    
    if ([status isEqualToString:@"SUCCESS"])
    {
        [self goHome];
    }
    else
    {
        alert = [[UIAlertView alloc] initWithTitle:@"Sign-In!"
                                           message:description
                                          delegate:self
                                 cancelButtonTitle:@"Ok"
                                 otherButtonTitles:nil];
        [alert show];
    }
    
}


-(void) goHome
{
    
    NSDictionary *flickrPhoto = [self jsonResponse];
    NSString *api_key = [flickrPhoto objectForKey:@"api-key"];
    NSString *username = userTextField.text;
    NSString *phone = phoneTextField.text;
    NSString *email = emailTextField.text;
    NSString *password = passwordTextField.text;
    NSString *dob = dobTextField.text;
    
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK)
    {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    NSLog(@"Opened DB so as to save Record !");
    
    // Note that the continuation char on next line is not part of string...
    
    NSString *updateS;
    sqlite3_stmt *stmt;

    updateS = @"INSERT OR REPLACE INTO USER (KEY, USERNAME, PHONE, EMAIL, PASSWORD, DATE) VALUES (?, ?, ?, ?, ?, ?);";
    NSLog(@"insert into memworddb-> %@",updateS);
    
    const char *update2 = [updateS UTF8String];
    
    if (sqlite3_prepare_v2(database, update2, -1, &stmt, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(stmt, 1, [api_key UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [username UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [phone UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [email UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 5, [password UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 6, [dob UTF8String], -1, NULL);
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE)
        NSAssert(0, @"Error updating table");
    
    NSLog(@"Record has been updated in USER !");
    
    
    sqlite3_finalize(stmt);
    
    sqlite3_close(database);
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSLog(@"NSNotificationCenter !");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Logged-in" object:nil userInfo:nil];
    
}

@end
