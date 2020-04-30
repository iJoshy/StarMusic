//
//  MainTabViewController.m
//  momentsapp
//
//  Created by Joshua Balogun on 9/29/13.
//
//

#import "MainTabViewController.h"
#import "phoneLoginViewController.h"
#import "AppDelegate.h"
#import <sqlite3.h>

@interface MainTabViewController () 

@end

@implementation MainTabViewController

@synthesize userKey;

- (NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kFilename];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
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
            
            [[NSUserDefaults standardUserDefaults] setObject:userKey forKey:@"USERKEY"];
            
        }
        else
        {
            [self performSelector:@selector(abegLogIn) withObject:nil afterDelay:0.0];
        }
        
        sqlite3_finalize(statement);
        
    }
    
    sqlite3_close(database);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStateChanged:)
                                                 name:FBSessionStateChangedNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedOut) name:@"Logged-out" object:nil];
    
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (FBSession.activeSession.isOpen)
    {
        NSLog(@"Inside viewWillAppear to populate :::: ");
        //[self populateUserDetails];
    }
    else if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)
    {
        // Check the session for a cached token to show the proper authenticated
        // UI. However, since this is not user intitiated, do not show the login UX.
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        [appDelegate openSessionWithAllowLoginUI:NO];
    }
}
*/

-(void)abegLogIn
{
    [self performSegueWithIdentifier:@"phoneLoginSegue" sender:self];
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
    
    [self performSegueWithIdentifier:@"phoneLoginSegue" sender:self];
    
}

#pragma mark - UITabBarControllerDelegate

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	
	NSLog(@"Tabs tapped ::::: ");
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    phoneLoginViewController* detail = segue.destinationViewController;
    
    [detail setTitle:[@"Login" lowercaseString]];
    
}

@end
