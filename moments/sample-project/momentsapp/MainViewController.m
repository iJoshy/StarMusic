//
//  MainViewController.m
//  momentsapp
//
//  Created by Joshua Balogun on 8/8/13.
//
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import <sqlite3.h>

@implementation MainViewController

@synthesize bgimage, titlelabel, labelview, user = _user;
@synthesize showPopoverButton, titleButton, userKey, toolbar;
@synthesize storyboard, loginScene, newsScene, galleryScene, mapScene;


- (NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kFilename];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Background Image of parent view
    [[UIToolbar appearance]setBackgroundImage:[UIImage imageNamed:@"menubar"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"landscapeBG.png"]];
    
    imageView.frame = self.view.bounds;
    imageView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.view addSubview:imageView];
    [self.view sendSubviewToBack:imageView];
    
    //Add a title
    titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0 , 0, 150, 250)];
    [titlelabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
    [titlelabel setBackgroundColor:[UIColor clearColor]];
    [titlelabel setTextColor:[UIColor whiteColor]];
    [titlelabel setTextAlignment:NSTextAlignmentCenter];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedIn:) name:@"Logged-in" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedOut) name:@"Logged-out" object:nil];
    
    NSLog(@"This is Did appear calling ....");
    userKey = nil;
    
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK)
    {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    //NSLog(@"Database Created !");
    
    char *errorMsg;
    
    // Note that the continuation char on next line is not part of string...
    //create PDDB
    
    NSString *createSQL = @"CREATE TABLE IF NOT EXISTS USER (ID INTEGER PRIMARY KEY AUTOINCREMENT, KEY TEXT, USERNAME TEXT, PHONE TEXT, EMAIL TEXT, PASSWORD TEXT, DATE TEXT);";
    if (sqlite3_exec (database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
    {
        sqlite3_close(database);
        NSAssert1(0, @"Error creating DB tables: %s", errorMsg);
    }
    
    NSLog(@"PDDB Created !");
    
    
    NSString *query = @"SELECT * FROM USER";
    sqlite3_stmt *statement;
    if (sqlite3_prepare_v2(database, [query UTF8String], -1, &statement, nil) == SQLITE_OK)
    {
        if(sqlite3_step(statement) == SQLITE_ROW)
        {
            /*
             NSLog(@"Record found in PDDB !");
             
             char *cId = (char *)sqlite3_column_text(statement, 0);
             char *cKey = (char *)sqlite3_column_text(statement, 1);
             char *cUsername = (char *)sqlite3_column_text(statement, 2);
             char *cPhone = (char *)sqlite3_column_text(statement, 3);
             char *cEmail = (char *)sqlite3_column_text(statement, 4);
             char *cPassword = (char *)sqlite3_column_text(statement, 5);
             char *cDate = (char *)sqlite3_column_text(statement, 6);
             
             NSString *cid = [[NSString alloc] initWithUTF8String:cId];
             NSString *key = [[NSString alloc] initWithUTF8String:cKey];
             NSString *username = [[NSString alloc] initWithUTF8String:cUsername];
             NSString *phone = [[NSString alloc] initWithUTF8String:cPhone];
             NSString *email = [[NSString alloc] initWithUTF8String:cEmail];
             NSString *password = [[NSString alloc] initWithUTF8String:cPassword];
             NSString *date = [[NSString alloc] initWithUTF8String:cDate];
             
             NSLog(@" cid  from DB %@",cid);
             NSLog(@" key from DB %@",key);
             NSLog(@" username  from DB %@",username);
             NSLog(@" phone from DB %@",phone);
             NSLog(@" email from DB %@",email);
             NSLog(@" password from DB %@",password);
             NSLog(@" date from DB %@",date);
             */
            
            char *cKey = (char *)sqlite3_column_text(statement, 1);
            userKey = [[NSString alloc] initWithUTF8String:cKey];
            NSLog(@" key from DB %@",userKey);
            
            [self selectMenu:@"News"];
            
        }
        else
        {
            [self selectMenu:@"Login"];
        }
        
        sqlite3_finalize(statement);
        
    }
    
    sqlite3_close(database);
     
    // Register for notifications on FB session state changes
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStateChanged:)
     name:FBSessionStateChangedNotification object:nil];
    
    // Register for notifications on menu data changes
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuDataChanged:)
     //name:FBMenuDataChangedNotification object:nil];
    
    // Register for notifications on grid view
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadGridview:)
    name:@"ReloadGridview" object:nil];
    
}


- (void)sessionStateChanged:(NSNotification*)notification
{
    if (FBSession.activeSession.isOpen)
    {
        NSLog(@"Inside sessionStateChanged to populate :::: ");
        
        if (userKey == nil)
        {
            [self populateUserDetails];
        }
        
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Logged-out" object:nil userInfo:nil];
    }
}

- (void)populateUserDetails
{
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate requestUserData:^(id sender, id<FBGraphUser> user)
    {
        NSLog(@"username :::: %@",user.name);
        NSLog(@"birthday :::: %@",user.birthday);
        NSLog(@"email :::: %@",user[@"email"]);
    }];

}
    

#pragma mark - View life cycle

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (FBSession.activeSession.isOpen)
    {
         NSLog(@"Inside viewWillAppear to populate :::: ");
        [self populateUserDetails];
    }
    else if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)
    {
        // Check the session for a cached token to show the proper authenticated
        // UI. However, since this is not user intitiated, do not show the login UX.
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate openSessionWithAllowLoginUI:NO];
    }
}

/*
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Present login modal if necessary after the view has been
    // displayed, not in viewWillAppear: so as to allow display
    // stack to "unwind"
    if (FBSession.activeSession.isOpen)
    {
    }
    else if (FBSession.activeSession.isOpen ||
             FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded ||
             FBSession.activeSession.state == FBSessionStateCreatedOpening)
    {
    }
    else
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Logged-out" object:nil userInfo:nil];
    }
    
}
*/


-(void) reloadGridview:(NSNotification *) obj
{
    
    NSLog(@"reloadGridview :::::");
    
    NSArray *cord = (NSArray *) [obj object];
    NSString *menu = [cord objectAtIndex:0];
    NSString *pageno = [cord objectAtIndex:1];
    NSArray *content = [cord objectAtIndex:2];
    
    if (galleryScene)
    {
        [galleryScene willMoveToParentViewController:nil];
        [galleryScene.view removeFromSuperview];
        [galleryScene removeFromParentViewController];
        galleryScene = nil;
    }
    
    galleryScene = [storyboard instantiateViewControllerWithIdentifier:@"GalleryScene"];
    galleryScene.whichView = [menu lowercaseString];
    galleryScene.jsonResponse = content;
    galleryScene.pageno = pageno;
    galleryScene.userKey = userKey;
    [self addChildViewController:galleryScene];
    [galleryScene didMoveToParentViewController:self];
    
    
}

-(void) loggedIn:(NSNotification*)obj
{
    
    NSString *cord = (NSString *) [obj object];
    
    userKey = cord;
    
    showPopoverButton.width = 0;
    
    [self selectMenu:@"News"];
    
}

-(void) loggedOut
{
    sqlite3 *database;
    if (sqlite3_open([[self dataFilePath] UTF8String], &database) != SQLITE_OK)
    {
        sqlite3_close(database);
        NSAssert(0, @"Failed to open database");
    }
    //NSLog(@"Database Created !");
    
    char *errorMsg;
    
    // Note that the continuation char on next line is not part of string...
    //create PDDB
    
    NSString *createSQL = @"DROP TABLE IF EXISTS USER;";
    if (sqlite3_exec (database, [createSQL UTF8String], NULL, NULL, &errorMsg) != SQLITE_OK)
    {
        sqlite3_close(database);
        NSAssert1(0, @"Error creating DB tables: %s", errorMsg);
    }
    
    sqlite3_close(database);
    
    [self selectMenu:@"Login"];
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

- (IBAction)chooseMenu:(id)sender
{
    
    NSLog(@"going to the popover ohhhhhh ");
    
    if (_menuPicker == nil)
    {
        //Create the ColorPickerViewController.
        _menuPicker = [[PopoverDemoController alloc] initWithStyle:UITableViewStylePlain];
        
        //Set this VC as the delegate.
        _menuPicker.delegate = self;
    }
    
    if (_menuPopover == nil)
    {
        //The color picker popover is not showing. Show it.
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:_menuPicker];
        navCtrl.navigationBar.topItem.title = @"Menu";
        
        _menuPopover = [[UIPopoverController alloc] initWithContentViewController:navCtrl];
        [_menuPopover presentPopoverFromBarButtonItem:showPopoverButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        
    }
    else
    {
        //The color picker popover is showing. Hide it.
        [_menuPopover dismissPopoverAnimated:YES];
        _menuPopover = nil;
    }
    
}


- (void)selectMenu:(NSString *)menu
{
    
    NSLog(@"In Parent, selected: %@", menu);
    // Clear the parent screen
    
    if (newsScene)
    {
        [newsScene willMoveToParentViewController:nil];
        [newsScene.view removeFromSuperview];
        [newsScene removeFromParentViewController];
        newsScene = nil;
    }
    
    if (galleryScene)
    {
        [galleryScene willMoveToParentViewController:nil];
        [galleryScene.view removeFromSuperview];
        [galleryScene removeFromParentViewController];
        galleryScene = nil;
    }
    
    if (mapScene)
    {
        [mapScene willMoveToParentViewController:nil];
        [mapScene.view removeFromSuperview];
        [mapScene removeFromParentViewController];
        mapScene = nil;
    }
    
    if (loginScene)
    {
        [loginScene willMoveToParentViewController:nil];
        [loginScene.view removeFromSuperview];
        [loginScene removeFromParentViewController];
        loginScene = nil;
    }
    
    // Change title
    menu = [menu isEqualToString:@"Settings"] ? @"Login": menu;
    
    titlelabel.text = menu;
    labelview = (UIView *)titlelabel;
    [self.titleButton setCustomView:labelview];
    
    menu = [menu isEqualToString:@"Star Stories"] ? @"Adverts": menu;
    
    // Call in the child screen
    if ([menu isEqualToString:@"Gallery"] || [menu isEqualToString:@"Videos"] || [menu isEqualToString:@"Adverts"] || [menu isEqualToString:@"My Downloads"] || [menu isEqualToString:@"Video Uploads"] || [menu isEqualToString:@"Audio Uploads"] || [menu isEqualToString:@"Audios"])
    {
        NSLog(@"Present gallery view and same");
        
        galleryScene = [storyboard instantiateViewControllerWithIdentifier:@"GalleryScene"];
        galleryScene.whichView = [menu lowercaseString];
        galleryScene.userKey = userKey;
        [self addChildViewController:galleryScene];
        [galleryScene didMoveToParentViewController:self];
        
    }
    else
    {
        
        if ([menu isEqualToString:@"News"] || [menu isEqualToString:@"Blogs"] || [menu isEqualToString:@"Events"] || [menu isEqualToString:@"Contests"])
        {
            NSLog(@"Present news view");
            
            newsScene = [storyboard instantiateViewControllerWithIdentifier:@"NewsScene"];
            newsScene.whichView = [menu lowercaseString];
            newsScene.userKey = userKey;
            [self addChildViewController:newsScene];
            [newsScene didMoveToParentViewController:self];
            
        }
        else
        {
            if ([menu isEqualToString:@"Bar Finder"])
            {
                NSLog(@"Present map view");
                
                mapScene = [storyboard instantiateViewControllerWithIdentifier:@"MapScene"];
                [self addChildViewController:mapScene];
                [mapScene didMoveToParentViewController:self];
                
            }
            else if ([menu isEqualToString:@"Login"])
            {
                NSLog(@"Present login view");
                
                showPopoverButton.width = 0.01;
                
                loginScene = [storyboard instantiateViewControllerWithIdentifier:@"LoginScene"];
                [self addChildViewController:loginScene];
                [loginScene didMoveToParentViewController:self];
                
            }
            else if ([menu isEqualToString:@"Settings"])
            {
                NSLog(@"Present Setting view");
                
            }
            
        }
        
    }
    
    //Dismiss the popover if it's showing.
    
    if (_menuPopover)
    {
        [_menuPopover dismissPopoverAnimated:YES];
        _menuPopover = nil;
    }
    
}


@end
