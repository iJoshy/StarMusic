//
//  DBSignupViewController.m
//  DBSignup
//
//  Created by Davide Bettio on 7/4/11.
//  Copyright 2011 03081340121. All rights reserved.
//

#import "DBSignupViewController.h"
#import "SVProgressHUD.h"
#import "SimpleFlickrAPI.h"
#import <sqlite3.h>

// Safe releases
#define RELEASE_SAFELY(__POINTER) { [__POINTER release]; __POINTER = nil; }
#define FIELDS_COUNT            7
#define BIRTHDAY_FIELD_TAG      5
#define GENDER_FIELD_TAG        6

@implementation DBSignupViewController

@synthesize scrollview = scrollview_;
@synthesize nameTextField = nameTextField_;
@synthesize lastNameTextField = lastNameTextField_;
@synthesize changePassword = changePassword_;
@synthesize emailTextField = emailTextField_;
@synthesize passwordTextField = passwordTextField_;
@synthesize birthdayTextField = birthdayTextField_;
@synthesize genderTextField = genderTextField_;
@synthesize phoneTextField = phoneTextField_;
@synthesize photoButton = photoButton_;
@synthesize termsTextView = termsTextView_;

@synthesize emailLabel = emailLabel_;
@synthesize passwordLabel = passwordLabel_;
@synthesize birthdayLabel = birthdayLabel_;
@synthesize genderLabel = genderLabel_;
@synthesize phoneLabel = phoneLabel_;

@synthesize profileView = profileView_;
@synthesize keyboardToolbar = keyboardToolbar_;
@synthesize genderPickerView = genderPickerView_;
@synthesize birthdayDatePicker = birthdayDatePicker_;

@synthesize birthday = birthday_;
@synthesize gender = gender_;
@synthesize userkey = userkey_;
@synthesize photo = photo_;
@synthesize loginParams = loginParams_;
@synthesize response = response_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kFilename];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *deviceType = [UIDevice currentDevice].model;
    NSLog(@"deviceType :::::: %@",deviceType);
    
    if ([deviceType isEqualToString:@"iPhone"] || [deviceType isEqualToString:@"iPhone Simulator"])
    {
        if([[[UIDevice currentDevice] systemVersion] integerValue] < 7)
        {
            [self.profileView setFrame:(CGRectMake(15, -20, 320, 480))];
        }
        else
        {
            [self.profileView setFrame:(CGRectMake(10, 65, 320, 480))];
        }
    }
    else
    {
        [self.profileView setFrame:(CGRectMake(-10, -5, 320, 480))];
    }
    
    self.profileView.backgroundColor = [UIColor clearColor];
    
    CGSize size = CGSizeMake(280, 80); // size of view in popover
    self.contentSizeForViewInPopover = size;
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    labelTitle.text = [@"Profile" capitalizedString];
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.textColor = [UIColor whiteColor];
    labelTitle.font = [UIFont fontWithName:@"Avenir-Black" size:19];
    [labelTitle sizeToFit];
    self.navigationItem.titleView = labelTitle;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"landscapeBG.png"]];
    [self.changePassword setBackgroundImage:[UIImage imageNamed:@"button-green.png"] forState:UIControlStateNormal];
    [self.changePassword setBackgroundImage:[UIImage imageNamed:@"button-green-down.png"] forState:UIControlStateHighlighted];
    
    UIBarButtonItem* backButton = [self createBackBarButtonWithImage:@"back.png"];
    [self.navigationItem setLeftBarButtonItem:backButton];
    
    // Signup button
    UIBarButtonItem *signupBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Update", @"") style:UIBarButtonItemStyleBordered target:self action:@selector(update:)];
    self.navigationItem.rightBarButtonItem = signupBarItem;
    
    // Birthday date picker
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
        [self.birthdayDatePicker setMaximumDate:currentDate];
    }
    
    // Gender picker
    if (self.genderPickerView == nil) {
        self.genderPickerView = [[UIPickerView alloc] init];
        self.genderPickerView.delegate = self;
        self.genderPickerView.showsSelectionIndicator = YES;
    }
    
    // Keyboard toolbar
    if (self.keyboardToolbar == nil)
    {
        self.keyboardToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 38.0f)];
        [self.keyboardToolbar setBackgroundImage:[UIImage imageNamed:@"header.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
        self.keyboardToolbar.barStyle = UIBarStyleBlackTranslucent;
        
        UIBarButtonItem *previousBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"previous", @"")
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:self
                                                                           action:@selector(previousField:)];
        
        UIBarButtonItem *nextBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"next", @"")
                                                                        style:UIBarButtonItemStyleBordered
                                                                       target:self
                                                                       action:@selector(nextField:)];
        
        UIBarButtonItem *spaceBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                      target:nil
                                                                                      action:nil];
        
        UIBarButtonItem *doneBarItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"done", @"")
                                                                        style:UIBarButtonItemStyleDone
                                                                       target:self
                                                                       action:@selector(resignKeyboard:)];
        
        [self.keyboardToolbar setItems:[NSArray arrayWithObjects:previousBarItem, nextBarItem, spaceBarItem, doneBarItem, nil]];
        
        self.nameTextField.inputAccessoryView = self.keyboardToolbar;
        self.lastNameTextField.inputAccessoryView = self.keyboardToolbar;
        self.emailTextField.inputAccessoryView = self.keyboardToolbar;
        self.passwordTextField.inputAccessoryView = self.keyboardToolbar;
        self.birthdayTextField.inputAccessoryView = self.keyboardToolbar;
        self.birthdayTextField.inputView = self.birthdayDatePicker;
        self.genderTextField.inputAccessoryView = self.keyboardToolbar;
        self.genderTextField.inputView = self.genderPickerView;
        self.phoneTextField.inputAccessoryView = self.keyboardToolbar;
        
    }
    
    // Set localization
    self.nameTextField.placeholder = NSLocalizedString(@"first_name", @"");
    self.lastNameTextField.placeholder = NSLocalizedString(@"", @"");
    self.emailLabel.text = [NSLocalizedString(@"email", @"") uppercaseString]; 
    self.passwordLabel.text = [NSLocalizedString(@"password", @"") uppercaseString];
    self.birthdayLabel.text = [NSLocalizedString(@"birthdate", @"") uppercaseString]; 
    self.genderLabel.text = [NSLocalizedString(@"gender", @"") uppercaseString]; 
    self.phoneLabel.text = [NSLocalizedString(@"phone", @"") uppercaseString];
    self.phoneTextField.placeholder = NSLocalizedString(@"optional", @"");
    self.termsTextView.text = NSLocalizedString(@"terms", @"");
    
    // Reset labels colors
    [self resetLabelsColors];
    [self loadData];
    
}


-(UIBarButtonItem*)createBackBarButtonWithImage:(NSString*)imageName
{
    UIImage* buttonImage = [UIImage imageNamed:imageName];
    
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIView* buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [buttonView addSubview:button];
    
    UIBarButtonItem* barButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    
    return barButton;
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)loadData
{
    
    NSLog(@"::::: Inside to load ::::::");
    
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK)
    {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    NSString *query = @"SELECT USERNAME, PHONE, EMAIL, DATE FROM USER";
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        while(sqlite3_step(statement) == SQLITE_ROW)
        {
            char *cUsername = (char *)sqlite3_column_text(statement, 0);
            char *cPhone = (char *)sqlite3_column_text(statement, 1);
            char *cEmail = (char *)sqlite3_column_text(statement, 2);
            char *cDate = (char *)sqlite3_column_text(statement, 3);
            
            self.nameTextField.text = [[NSString alloc] initWithUTF8String:cUsername];
            self.phoneTextField.text = [[NSString alloc] initWithUTF8String:cPhone];
            self.emailTextField.text = [[NSString alloc] initWithUTF8String:cEmail];
            self.birthdayTextField.text = [[NSString alloc] initWithUTF8String:cDate];
            
            /*
            NSString* name = [[NSString alloc] initWithUTF8String:cUsername];
            NSString* phone = [[NSString alloc] initWithUTF8String:cPhone];
            NSString* email = [[NSString alloc] initWithUTF8String:cEmail];
            NSString* cob = [[NSString alloc] initWithUTF8String:cDate];
            
            NSLog(@"name :::: %@",name);
            NSLog(@"phone :::: %@",phone);
            NSLog(@"email :::: %@",email);
            NSLog(@"cob ::::: %@",cob);
            */
        }
        
        sqlite3_finalize(statement);
        
    }
    
    sqlite3_close(database);
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}


#pragma mark - IBActions

- (IBAction)choosePhoto:(id)sender
{
    UIActionSheet *choosePhotoActionSheet;
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        choosePhotoActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"choose_photo", @"")
                                                             delegate:self 
                                                    cancelButtonTitle:NSLocalizedString(@"cancel", @"") 
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"take_photo_from_camera", @""), NSLocalizedString(@"take_photo_from_library", @""), nil];
    } else {
        choosePhotoActionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"choose_photo", @"")
                                                             delegate:self 
                                                    cancelButtonTitle:NSLocalizedString(@"cancel", @"") 
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"take_photo_from_library", @""), nil];
    }
    
    [choosePhotoActionSheet showInView:self.view];
}


#pragma mark - Others

- (IBAction)logout:(id)sender
{
    [self resignKeyboard:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Logged-out" object:nil userInfo:nil];

}

- (IBAction) update:(id)sender
{
    NSLog(@"::: update :::");
    
    UIActionSheet *actionSheetShare = [[UIActionSheet alloc] initWithTitle:nil
                                                                  delegate:self
                                                         cancelButtonTitle:nil
                                                    destructiveButtonTitle:NSLocalizedString(@" Continue ", @"")
                                                         otherButtonTitles:NSLocalizedString(@" Cancel ", @""),nil];
    [actionSheetShare setTag:10];
    [actionSheetShare showInView:self.view];
    
}

-(void)startUpdating
{
    
    NSString *updateS = @"UPDATE USER SET USERNAME = ?, PHONE = ?, EMAIL = ?, PASSWORD = ?, DATE = ? ";
    
    sqlite3_stmt *stmt;
    sqlite3 *database;
    
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK)
    {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    
    const char *update = [updateS UTF8String];
    
    if (sqlite3_prepare_v2(database, update, -1, &stmt, nil) == SQLITE_OK)
    {
        sqlite3_bind_text(stmt, 1, [self.nameTextField.text UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 2, [self.phoneTextField.text UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 3, [self.emailTextField.text UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 4, [self.passwordTextField.text UTF8String], -1, NULL);
        sqlite3_bind_text(stmt, 5, [self.birthdayTextField.text UTF8String], -1, NULL);
    }
    
    if (sqlite3_step(stmt) != SQLITE_DONE)
        NSAssert(0, @"Error updating table: %s",update);
    
    sqlite3_finalize(stmt);
    
    sqlite3_close(database);

    [self updateProfile];
}

-(void)updateProfile
{
    [SVProgressHUD showWithStatus:@"Updating ..."];
    
    //NSLog(@" Starting- going to fetch images .....");
    self.userkey = [[NSUserDefaults standardUserDefaults] stringForKey:@"USERKEY"];
    NSLog(@"UserKey  :: %@",self.userkey);
    self.loginParams = [[NSArray alloc] initWithObjects:@"update", self.userkey, self.emailTextField.text,self.phoneTextField.text,self.birthdayTextField.text, nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSDictionary *photos = [flickr updateprofile:self.loginParams];
                       self.response = photos;
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self goHome];
                           [SVProgressHUD dismiss];
                       });
                   });
    
}

-(void)goHome
{
    
    NSString* response = [self.response objectForKey:@"description"];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Star Music!"
                                                    message:response
                                                   delegate:self
                                          cancelButtonTitle:@"Ok"
                                          otherButtonTitles:nil];
    [alert show];
    
}

- (void)resignKeyboard:(id)sender
{
    id firstResponder = [self getFirstResponder];
    if ([firstResponder isKindOfClass:[UITextField class]]) {
        [firstResponder resignFirstResponder];
        [self animateView:1];
        [self resetLabelsColors];
    }
}

- (void)previousField:(id)sender
{
    id firstResponder = [self getFirstResponder];
    if ([firstResponder isKindOfClass:[UITextField class]]) {
        NSUInteger tag = [firstResponder tag];
        NSUInteger previousTag = tag == 1 ? 1 : tag - 1;
        [self checkBarButton:previousTag];
        [self animateView:previousTag];
        UITextField *previousField = (UITextField *)[self.view viewWithTag:previousTag];
        [previousField becomeFirstResponder];
        UILabel *nextLabel = (UILabel *)[self.view viewWithTag:previousTag + 10];
        if (nextLabel) {
            [self resetLabelsColors];
            [nextLabel setTextColor:[DBSignupViewController labelSelectedColor]];
        }
        [self checkSpecialFields:previousTag];
    }
}

- (void)nextField:(id)sender
{
    id firstResponder = [self getFirstResponder];
    if ([firstResponder isKindOfClass:[UITextField class]]) {
        NSUInteger tag = [firstResponder tag];
        NSUInteger nextTag = tag == FIELDS_COUNT ? FIELDS_COUNT : tag + 1;
        [self checkBarButton:nextTag];
        [self animateView:nextTag];
        UITextField *nextField = (UITextField *)[self.view viewWithTag:nextTag];
        [nextField becomeFirstResponder];
        UILabel *nextLabel = (UILabel *)[self.view viewWithTag:nextTag + 10];
        if (nextLabel) {
            [self resetLabelsColors];
            [nextLabel setTextColor:[DBSignupViewController labelSelectedColor]];
        }
        [self checkSpecialFields:nextTag];
    }
}

- (id)getFirstResponder
{
    NSUInteger index = 0;
    while (index <= FIELDS_COUNT) {
        UITextField *textField = (UITextField *)[self.view viewWithTag:index];
        if ([textField isFirstResponder]) {
            return textField;
        }
        index++;
    }
    
    return NO;
}

- (void)animateView:(NSUInteger)tag
{
    /*
    CGRect rect = self.view.frame;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    if (tag > 3) {
        rect.origin.y = -44.0f * (tag - 3);
    } else {
        rect.origin.y = 0;
    }
    self.view.frame = rect;
    [UIView commitAnimations];
    */
}

- (void)checkBarButton:(NSUInteger)tag
{
    UIBarButtonItem *previousBarItem = (UIBarButtonItem *)[[self.keyboardToolbar items] objectAtIndex:0];
    UIBarButtonItem *nextBarItem = (UIBarButtonItem *)[[self.keyboardToolbar items] objectAtIndex:1];
    
    [previousBarItem setEnabled:tag == 1 ? NO : YES];
    [nextBarItem setEnabled:tag == FIELDS_COUNT ? NO : YES];
}

- (void)checkSpecialFields:(NSUInteger)tag
{
    if (tag == BIRTHDAY_FIELD_TAG && [self.birthdayTextField.text isEqualToString:@""]) {
        [self setBirthdayData];
    } else if (tag == GENDER_FIELD_TAG && [self.genderTextField.text isEqualToString:@""]) {
        [self setGenderData];
    }
}

- (void)setBirthdayData
{
    self.birthday = self.birthdayDatePicker.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    self.birthdayTextField.text = [dateFormatter stringFromDate:self.birthday];
   
}

- (void)setGenderData
{
    if ([self.genderPickerView selectedRowInComponent:0] == 0) {
        self.genderTextField.text = NSLocalizedString(@"male", @"");
        self.gender = @"M";
    } else {
        self.genderTextField.text = NSLocalizedString(@"female", @"");
        self.gender = @"F";
    }
}

- (void)birthdayDatePickerChanged:(id)sender
{
    [self setBirthdayData];
}

- (void)resetLabelsColors
{
    self.emailLabel.textColor = [DBSignupViewController labelNormalColor];
    self.passwordLabel.textColor = [DBSignupViewController labelNormalColor];
    self.birthdayLabel.textColor = [DBSignupViewController labelNormalColor];
    self.genderLabel.textColor = [DBSignupViewController labelNormalColor];
    self.phoneLabel.textColor = [DBSignupViewController labelNormalColor];
}

+ (UIColor *)labelNormalColor
{
    return [UIColor colorWithRed:0.016 green:0.216 blue:0.286 alpha:1.000];
}

+ (UIColor *)labelSelectedColor
{
    return [UIColor colorWithRed:0.114 green:0.600 blue:0.737 alpha:1.000];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSUInteger tag = [textField tag];
    [self animateView:tag];
    [self checkBarButton:tag];
    [self checkSpecialFields:tag];
    UILabel *label = (UILabel *)[self.view viewWithTag:tag + 10];
    if (label) {
        [self resetLabelsColors];
        [label setTextColor:[DBSignupViewController labelSelectedColor]];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSUInteger tag = [textField tag];
    if (tag == BIRTHDAY_FIELD_TAG || tag == GENDER_FIELD_TAG) {
        return NO;
    }
    
    return YES;
}


#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 2;
}


#pragma mark - UIPickerViewDelegate

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UIImage *image = row == 0 ? [UIImage imageNamed:@"male.png"] : [UIImage imageNamed:@"female.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];        
    imageView.frame = CGRectMake(0, 0, 32, 32);
    
    UILabel *genderLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 100, 32)];
    genderLabel.text = [row == 0 ? NSLocalizedString(@"male", @"") : NSLocalizedString(@"female", @"") uppercaseString];
    genderLabel.textAlignment = UITextAlignmentLeft;
    genderLabel.backgroundColor = [UIColor clearColor];
    
    UIView *rowView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 32)];
    [rowView insertSubview:imageView atIndex:0];
    [rowView insertSubview:genderLabel atIndex:1];
    
    
    return rowView;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self setGenderData];
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 10)
    {
        if (buttonIndex == 1)
        {
            return;
        }
        else
        {
            [self startUpdating];
        }
    }
    else
    {
        NSUInteger sourceType = 0;
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        {
            switch (buttonIndex)
            {
                case 0:
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                case 1:
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
                case 2:
                    return;
            }
        }
        else
        {
            if (buttonIndex == 1)
            {
                return;
            }
            else
            {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        imagePickerController.delegate = self;
        imagePickerController.allowsEditing = YES;
        imagePickerController.sourceType = sourceType;
        [self presentModalViewController:imagePickerController animated:YES];
    }
	
}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info 
{
	[picker dismissModalViewControllerAnimated:YES];
	self.photo = [info objectForKey:UIImagePickerControllerEditedImage];
	[self.photoButton setImage:self.photo forState:UIControlStateNormal];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
	[self dismissModalViewControllerAnimated:YES];
}

@end
