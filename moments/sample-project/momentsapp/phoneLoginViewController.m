//
//  phoneLoginViewController.m
//  momentsapp
//
//  Created by Joshua Balogun on 9/29/13.
//
//

#import "phoneLoginViewController.h"
#import "SimpleFlickrAPI.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import <sqlite3.h>

@implementation phoneLoginViewController

@synthesize userTextField = _userTextField, passwordTextField = _passwordTextField;
@synthesize jsonResponse, alert, loginParams, apikey, profileData, description, loginview;

- (NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kFilename];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Login";
    
    if([[[UIDevice currentDevice] systemVersion] integerValue] >= 7)
    {
        [loginview setFrame:CGRectMake(33,140,255,280)];
    }
    
    UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"landscapeBG.png"]];
    
    imageView.frame = self.view.bounds;
    imageView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.view addSubview:imageView];
    [self.view sendSubviewToBack:imageView];
    
    
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"button-grrey.png"] forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"button-grey-down.png"] forState:UIControlStateHighlighted];
    
    [self.signupButton setBackgroundImage:[UIImage imageNamed:@"button-green.png"] forState:UIControlStateNormal];
    [self.signupButton setBackgroundImage:[UIImage imageNamed:@"button-green-down.png"] forState:UIControlStateHighlighted];
    
    [_passwordTextField setSecureTextEntry:YES];
    
    // Register for notifications on FB session state changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStateChanged:) name:FBSessionStateChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(goHome) name:@"Logged-in" object:nil];
    
}


-(void)viewDidAppear:(BOOL)animated{
    
    [super viewDidAppear:animated];
    
    self.title = @"Log In";
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.userTextField = nil;
    self.passwordTextField = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark IB Actions

//Show the forgot password view
-(IBAction)forgotpasswordPressed:(id)sender
{
    
    [self performSegueWithIdentifier:@"phoneForgotSegue" sender:self];
    
}

//Show the hidden register view
-(IBAction)signUpPressed:(id)sender
{

    [self performSegueWithIdentifier:@"phoneSignupSegue" sender:self];

}

//Login button pressed
-(IBAction)logInPressed:(id)sender
{
    
    NSString *username = self.userTextField.text;
    NSString *password = self.passwordTextField.text;
    
     [self goHome];
    
    /*
    
    if ( [username length] < 1 || [password length] < 1 )
    {
        alert = [[UIAlertView alloc] initWithTitle:@"Login!"
                                           message:@"Please enter a valid username and password"
                                          delegate:self
                                 cancelButtonTitle:@"Ok"
                                 otherButtonTitles:nil];
        [alert show];
    }
    else
    {
        loginParams = [[NSArray alloc] initWithObjects:@"login", username, password, nil];
        
        [SVProgressHUD show];
        
        [self fetchFlickrPhotoWithSearchString];
    }
     */
    
}

#pragma mark - Flickr

- (void)fetchFlickrPhotoWithSearchString
{
    
    //NSLog(@" Starting- going to fetch images .....");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSDictionary *photos = [flickr loginProcess:loginParams];
                       
                       [self setJsonResponse:photos];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self authenticateuser];
                           [SVProgressHUD dismiss];
                       });
                   });
}

- (void)authenticateuser
{
    NSLog(@" jsonresponse .....");
    
    NSDictionary *flickrPhoto = [self jsonResponse];
    
    NSString *status = [flickrPhoto objectForKey:@"status"];
    description = [flickrPhoto objectForKey:@"description"];
    apikey = [flickrPhoto objectForKey:@"api-key"];
    NSLog(@"apikey :::: %@",apikey);
    
    [[NSUserDefaults standardUserDefaults] setObject:apikey forKey:@"USERKEY"];
    
    
    if ([status isEqualToString:@"SUCCESS"])
    {
        [SVProgressHUD show];
        
        [self fetchFlickrPhoto];
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


- (void)fetchFlickrPhoto
{
    
    //NSLog(@" Starting- going to fetch images .....");
    jsonResponse = nil;
    NSString *username = self.userTextField.text;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSDictionary *photos = [flickr profile:@"profile":username:apikey];
                       
                       [self setProfileData:photos];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self logCredentials];
                           [SVProgressHUD dismiss];
                       });
                   });
}


-(void)logCredentials
{
    NSLog(@"profileData :::: %@",profileData);
    
    NSDictionary *flickrPhoto = [self profileData];
    NSString *username = [flickrPhoto objectForKey:@"username"];
    NSString *phone = [flickrPhoto objectForKey:@"phone"];
    NSString *email = [flickrPhoto objectForKey:@"email"];
    NSString *password = _passwordTextField.text;
    NSString *dob = [flickrPhoto objectForKey:@"dob"];
    
    NSLog(@" username  from DB %@",username);
    NSLog(@" phone from DB %@",phone);
    NSLog(@" email from DB %@",email);
    NSLog(@" password from DB %@",password);
    NSLog(@" date from DB %@",dob);
    
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
        sqlite3_bind_text(stmt, 1, [apikey UTF8String], -1, NULL);
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
    
    [self goHome];
    
}

-(void)goHome
{
    NSLog(@"goHome Called");
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)goHomeFromSignup
{
    [self performSelector:@selector(goHome) withObject:nil afterDelay:0.7];
}

- (void)sessionStateChanged:(NSNotification*)notification
{
    if (FBSession.activeSession.isOpen)
    {
        // If the session is open, cache friend data
        FBCacheDescriptor *cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
        [cacheDescriptor prefetchAndCacheForSession:FBSession.activeSession];
        
        // Go to the menu page by dismissing the modal view controller
        // instead of using segues.
        NSLog(@"User Logged in :::::");
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Logged-in" object:nil userInfo:nil];
        
        //[self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)loginButtonClicked:(id)sender
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate openSessionWithAllowLoginUI:YES];
}

- (IBAction) textFieldDoneEditing:(id) sender
{
    [sender resignFirstResponder];
}

@end

