//
//  phonesignupViewController.m
//  momentsapp
//
//  Created by Joshua Balogun on 9/29/13.
//
//

#import "phonesignupViewController.h"
#import "SimpleFlickrAPI.h"
#import "SVProgressHUD.h"
#import <sqlite3.h>

#define FIELDS_COUNT   7

@implementation phonesignupViewController

@synthesize userTextField,passwordTextField,confirmpassTextField,dobTextField,phoneTextField,emailTextField;
@synthesize titleButton, signupButton, backButton, birthdayDatePicker,loginview;
@synthesize signupFrame, alert, loginParams, birthday, keyboardToolbar, fieldsview;


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
        
        if(up)
        {
            int moveUpValue = temp.x + textField.frame.size.height;
            animatedDis = 352 - (768 - moveUpValue - 55);
        }
        
        if(animatedDis > 0)
        {
            const int movementDistance = animatedDis;
            const float movementDuration = 0.3f;
            int movement = (up ? -movementDistance : movementDistance);
            
            [UIView beginAnimations: nil context: nil];
            [UIView setAnimationBeginsFromCurrentState: YES];
            [UIView setAnimationDuration: movementDuration];
            
            self.view.superview.frame = CGRectOffset(self.view.superview.frame, movement, 0);
            
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
    
    if([[[UIDevice currentDevice] systemVersion] integerValue] < 7)
    {
        [loginview setFrame:CGRectMake(33,100,255,280)];
        
    }
    
    imageView.frame = self.view.bounds;
    imageView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.view addSubview:imageView];
    [self.view sendSubviewToBack:imageView];
    
    
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"button-grrey.png"] forState:UIControlStateNormal];
    [self.backButton setBackgroundImage:[UIImage imageNamed:@"button-grey-down.png"] forState:UIControlStateHighlighted];
    
    
    [self.signupButton setBackgroundImage:[UIImage imageNamed:@"button-green.png"] forState:UIControlStateNormal];
    [self.signupButton setBackgroundImage:[UIImage imageNamed:@"button-green-down.png"] forState:UIControlStateHighlighted];

    if (self.birthdayDatePicker == nil)
    {
        self.birthdayDatePicker = [[UIDatePicker alloc] init];
        [self.birthdayDatePicker addTarget:self action:@selector(birthdayDatePickerChanged:) forControlEvents:UIControlEventValueChanged];
        self.birthdayDatePicker.datePickerMode = UIDatePickerModeDate;
        NSDate *currentDate = [NSDate date];
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setYear:-18];
        NSDate *selectedDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:currentDate  options:0];
        [self.birthdayDatePicker setDate:selectedDate animated:NO];
        //[self.birthdayDatePicker setMaximumDate:currentDate];
        
        NSDate *now = [NSDate date];
        NSDate *eighteenyearsago = [now dateByAddingTimeInterval:-18*365*24*60*60];
        [self.birthdayDatePicker setMaximumDate:eighteenyearsago];
        
    }
    
    if (self.keyboardToolbar == nil)
    {
        self.keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 38.0f)];
        [self.keyboardToolbar setBackgroundImage:[UIImage imageNamed:@"header.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        self.keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
        
        UIBarButtonItem *spaceBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                      target:nil
                                                                                      action:nil];
        
        UIBarButtonItem *doneBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"done", @"")
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(resignKeyboard:)];
        
        [self.keyboardToolbar setItems:[NSArray arrayWithObjects: spaceBarItem, doneBarItem, nil]];
        
        self.dobTextField.inputAccessoryView = self.keyboardToolbar;
        self.dobTextField.inputView = self.birthdayDatePicker;
        
    }
    
}

- (void)resignKeyboard:(id)sender
{
    id firstResponder = [self getFirstResponder];
    
    if ([firstResponder isKindOfClass:[UITextField class]])
    {
        [firstResponder resignFirstResponder];
    }
}

- (id)getFirstResponder
{
    NSUInteger index = 0;
    while (index <= FIELDS_COUNT)
    {
        UITextField *textField = (UITextField *)[self.view viewWithTag:index];
        if ([textField isFirstResponder])
        {
            return textField;
        }
        index++;
    }
    
    return NO;
}

- (void)setBirthdayData
{
    self.birthday = self.birthdayDatePicker.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    self.dobTextField.text = [dateFormatter stringFromDate:self.birthday];
    
}

- (void)birthdayDatePickerChanged:(id)sender
{
    [self setBirthdayData];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 2;
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
    
    [SVProgressHUD show];
    
    loginParams = [[NSArray alloc] initWithObjects:@"signin", userTextField.text, phoneTextField.text,emailTextField.text,confirmpassTextField.text,dobTextField.text, nil];
    
    [self fetchFlickrPhotoWithSearchString];
    
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
                           [SVProgressHUD dismiss];
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
    
    [[NSUserDefaults standardUserDefaults] setObject:api_key forKey:@"USERKEY"];
    
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
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
    NSLog(@"NSNotificationCenter !");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Logged-in" object:nil userInfo:nil];
    
}

@end
