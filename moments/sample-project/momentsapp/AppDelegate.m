//
//  AppDelegate.m
//  momentsapp
//
//  Created by M.A.D on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "MapViewController.h"
#import "SimpleFlickrAPI.h"
#import <FacebookSDK/FBSessionTokenCachingStrategy.h>
#import <sqlite3.h>

NSString *const FBSessionStateChangedNotification =
@"com.facebook.samples.SocialCafe:FBSessionStateChangedNotification";

NSString *const FBMenuDataChangedNotification =
@"com.facebook.samples.SocialCafe:FBMenuDataChangedNotification";

@implementation AppDelegate

@synthesize window = _window, openedURL = _openedURL;
@synthesize colorSwitcher, user = _user, jsonResponse, userKey;
@synthesize username = _username, birthday = _birthday, email = _email;

+ (AppDelegate *) instance
{
	return (AppDelegate *) [[UIApplication sharedApplication] delegate];
}

- (NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kFilename];
}


-(void)iPadInit
{
    
}

-(void)iPhoneInit
{
    
}

- (void)customizeGlobalTheme
{
    
     //UIImage *navBarImage = [colorSwitcher getImageWithName:@"menubar"];
     //[[UINavigationBar appearance] setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsDefault];
    
    if([[[UIDevice currentDevice] systemVersion] integerValue] < 7)
    {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"header.png"] forBarMetrics:UIBarMetricsDefault];
    }
    else
    {
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"header_ios7.png"] forBarMetrics:UIBarMetricsDefault];
    }
    
    /*
    [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0], UITextAttributeTextColor,
                                                           [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],UITextAttributeTextShadowColor,
                                                           [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
                                                           UITextAttributeTextShadowOffset,
                                                           [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], UITextAttributeFont, nil]];
     */
    
    UIImage* barButtonImage = [self createSolidColorImageWithColor:[UIColor colorWithWhite:1.0 alpha:0.1] andSize:CGSizeMake(10, 10)];
    
    [[UIBarButtonItem appearance] setBackgroundImage:barButtonImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];

    
    [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor], UITextAttributeTextColor,
                                                          [UIFont boldSystemFontOfSize:16.0f], UITextAttributeFont, [UIColor darkGrayColor], UITextAttributeTextShadowColor, [NSValue valueWithCGSize:CGSizeMake(0.0, -1.0)], UITextAttributeTextShadowOffset,
                                                          nil] forState:UIControlStateNormal];
    
    [[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"tabbar"]];
    
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"highlightes"]];
    
    UIImage *barButton = [[UIImage imageNamed:@"menubar-button"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    [[UIBarButtonItem appearance] setBackgroundImage:barButton forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    UIImage *backButton = [[UIImage imageNamed:@"menubar-back-button"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 8)];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    //[[UIToolbar appearance]setBackgroundImage:[UIImage imageNamed:@"menubar"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    [[UISegmentedControl appearance] setBackgroundImage:[UIImage imageNamed:@"bar-button"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[UISegmentedControl appearance]setDividerImage:[UIImage imageNamed:@"seperator"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [[UISwitch appearance]setOnTintColor:[UIColor colorWithRed:233/255.0 green:107/255.0 blue:149/255.0 alpha:1.0]];
    
    UIImage *minImage = [UIImage imageNamed:@"slider-fill.png"];
    UIImage *maxImage = [UIImage imageNamed:@"slider-track.png"];
    UIImage *thumbImage = [UIImage imageNamed:@"slider-knob.png"];
    
    [[UISlider appearance] setMaximumTrackImage:maxImage forState:UIControlStateNormal];
    [[UISlider appearance] setMinimumTrackImage:minImage forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage forState:UIControlStateNormal];
    
}


-(UIImage*)createSolidColorImageWithColor:(UIColor*)color andSize:(CGSize)size{
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGRect fillRect = CGRectMake(0,0,size.width,size.height);
    CGContextSetFillColorWithColor(currentContext, color.CGColor);
    CGContextFillRect(currentContext, fillRect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
    UIApplication* app = [UIApplication sharedApplication];
    UILocalNotification* notifyAlarm = [[UILocalNotification alloc] init];
    
    NSCalendar *calendar = [NSCalendar currentCalendar]; // gets default calendar
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:[NSDate date]]; // gets the year, month, day,hour and minutesfor today's date
    [components setHour:17];
    [components setMinute:59];
    
    if (notifyAlarm)
    {
        notifyAlarm.fireDate = [calendar dateFromComponents:components];
        notifyAlarm.timeZone = [NSTimeZone defaultTimeZone];
        notifyAlarm.repeatInterval = NSDayCalendarUnit;
        notifyAlarm.applicationIconBadgeNumber = 1;
        notifyAlarm.soundName = @"Glass.aiff";
        notifyAlarm.alertBody = @"Will you like to find a Star Bar closest to you.";
        [app scheduleLocalNotification:notifyAlarm];
    }
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notify_allbars" object:nil];
    
}

/**
 * A function for parsing URL parameters.
 */
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        if ([kv count] > 1) {
            NSString *val = [[kv objectAtIndex:1]
                             stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [params setObject:val forKey:[kv objectAtIndex:0]];
        }
    }
    return params;
}

/*
 * A function to get the access token info and save
 * it in the cache, useful for deep linking support
 * in cases where the session is not open.
 */
- (void) handleOpenURLPre:(NSURL *) url
{
    // Parse the URL
    NSString *query = [url fragment];
    if (!query) {
        query = [self.openedURL query];
    }
    NSDictionary *params = [self parseURLParams:query];
    // Look for a valid access token
    if ([params objectForKey:@"access_token"]) {
        NSString *accessToken = [params objectForKey:@"access_token"];
        NSString *expires_in = [params objectForKey:@"expires_in"];
        // Determine the expiration data
        NSDate *expirationDate = nil;
        if (expires_in != nil) {
            int expValue = [expires_in intValue];
            if (expValue != 0) {
                expirationDate = [NSDate dateWithTimeIntervalSinceNow:expValue];
            }
        }
        if (!expirationDate) {
            expirationDate = [NSDate distantFuture];
        }
        NSDate *nowDate = [NSDate date];
        // Check expiration date later than now
        if (NSOrderedDescending == [expirationDate compare:nowDate]) {
            // Cache the token
            NSDictionary *tokenInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                       accessToken, FBTokenInformationTokenKey,
                                       expirationDate, FBTokenInformationExpirationDateKey,
                                       nowDate, FBTokenInformationRefreshDateKey,
                                       nil];
            FBSessionTokenCachingStrategy *tokenCachingStrategy = [FBSessionTokenCachingStrategy defaultInstance];
            [tokenCachingStrategy cacheTokenInformation:tokenInfo];
            // Now open the session and the cached token should
            // be picked up, open with nil permissions because
            // what you send is checked against any cached permissions
            // to determine token validity.
            [FBSession openActiveSessionWithReadPermissions:nil
                                               allowLoginUI:NO
                                          completionHandler:^(FBSession *session,
                                                              FBSessionState state,
                                                              NSError *error) {
                                              [self sessionStateChanged:session
                                                                  state:state
                                                                  error:error];
                                          }];
        }
    }
}

#pragma mark - Authentication methods
/*
 * Callback for session changes.
 */
- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state)
    {
        case FBSessionStateOpen:
            if (!error) {
                // We have a valid session
                //NSLog(@"User session found");
            }
            break;
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            NSLog(@"FBSessionStateClosedLoginFailed ERROR: %@", [error description]);
            break;
        default:
            break;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FBSessionStateChangedNotification object:session];
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}

/*
 * Opens a Facebook session and optionally shows the login UX.
 */
- (BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI {
    // Ask for permissions for getting info about uploaded
    // custom photos.
    NSArray *permissions = [NSArray arrayWithObjects:@"email", @"user_birthday", nil];
    
#ifdef IOS_NEWER_OR_EQUAL_TO_6
    NSArray *permissions = [NSArray arrayWithObjects:@"email",nil];
#endif
    
    return [FBSession openActiveSessionWithReadPermissions:permissions
                                              allowLoginUI:allowLoginUI
                                         completionHandler:^(FBSession *session,
                                                             FBSessionState state,
                                                             NSError *error) {
                                             [self sessionStateChanged:session
                                                                 state:state
                                                                 error:error];
                                         }];
}

/*
 * Closes the active Facebook session
 */
- (void) closeSession
{
    [FBSession.activeSession closeAndClearTokenInformation];
}

#pragma mark - Personalization methods
/*
 * Makes a request for user data and invokes a callback
 */
- (void)requestUserData:(UserDataLoadedHandler)handler
{
    // If there is saved data, return this.
    if (nil != self.user) {
        if (handler) {
            handler(self, self.user);
        }
    } else if (FBSession.activeSession.isOpen) {
        [FBRequestConnection startForMeWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error)
        {
             if (!error)
             {
                 // Update menu user info
                 // Save the user data
                 self.user = user;
                 _username = user.name;
                 _birthday = user.birthday;
                 _email = user[@"email"];
                 
                 [self fetchFlickrPhotoWithSearchString];
                 
                 if (handler)
                 {
                     handler(self, self.user);
                 }
             }
         }];
    }
}


#pragma mark - Flickr

- (void)fetchFlickrPhotoWithSearchString
{
    if (_email == NULL)
        _email = @"facebookuser@facebook.com";
    
    NSArray *loginParams = [[NSArray alloc] initWithObjects:@"signin", _username, @"08099440203", _email, @"facebookuser", _birthday, nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSDictionary *photos = [flickr signinProcess:loginParams];
                       
                       [self setJsonResponse:photos];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self saveFacebookData];
                       });
                   });
    
}


-(void) saveFacebookData
{
    NSString *status = [jsonResponse objectForKey:@"status"];
    NSString *description = [jsonResponse objectForKey:@"description"];
    //NSLog(@"status :::: %@\nDiscription ::::: %@",status,description);
    
    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sign-In!"
                                       message:description
                                      delegate:self
                             cancelButtonTitle:@"Ok"
                             otherButtonTitles:nil];
    [alert show];
    */
    
    if ([status isEqualToString:@"SUCCESS"])
    {
        
        NSDictionary *flickrPhoto = [self jsonResponse];
        NSString *api_key = [flickrPhoto objectForKey:@"api-key"];
        
        if (api_key == NULL)
            api_key = [flickrPhoto objectForKey:@"key"];
        
        NSString *username = _username;
        NSString *phone = @"";
        NSString *email = _email;
        NSString *password = @"";
        NSString *dob = _birthday;
        
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
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshContent" object:@"news"];
        
        sqlite3_finalize(stmt);
        
        sqlite3_close(database);
    }
    else
    {
        if ([description isEqualToString:@"The email address has already been registered"])
        {
            [self getApiKey];
        }
        else
        {
            [self closeSession];
        }
        
    }
    
}

-(void)getApiKey
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSDictionary *photos = [flickr fblogin:_email];
                       
                       [self setJsonResponse:photos];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self saveFacebookData];
                       });
                   });
    
}


#pragma mark -
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [FBProfilePictureView class];
    [FBPlacePickerViewController class];
    [FBFriendPickerViewController class];
    
    // Override point for customization after application launch.
    
    self.colorSwitcher = [[ColorSwitcher alloc] initWithScheme:@"blue"];
    
    [self customizeGlobalTheme];
    
    UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
    
    if (idiom == UIUserInterfaceIdiomPad)
    {
        [self iPadInit];
    }
    else
    {
        [self iPhoneInit];
    }
    
	// Handle launching from a notification
    
    application.applicationIconBadgeNumber = 0;
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    
    // Save the incoming URL to test deep links later.
    self.openedURL = url;
    
    // Work around for app link from FB with valid info. If the
    // session is closed, set the valid info (if any) in the cache
    if ((FBSession.activeSession.state == FBSessionStateCreated) ||
        (FBSession.activeSession.state == FBSessionStateClosed)){
        [self handleOpenURLPre:url];
    }
    // We need to handle URLs by passing them to FBSession in order for SSO authentication
    // to work.
    return [FBSession.activeSession handleOpenURL:url];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // if the app is going away, we close the session object
    [FBSession.activeSession close];
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSession.activeSession handleDidBecomeActive];
    
    // Check for an incoming deep link and set the info in the Menu View Controller
    // Process the saved URL
    NSString *query = [self.openedURL fragment];
    if (!query) {
        query = [self.openedURL query];
    }
    NSDictionary *params = [self parseURLParams:query];
    // Check if target URL exists
    if ([params valueForKey:@"target_url"])
    {
        // If the incoming link is a deep link then set things up to take the user to
        // the menu view controller (if necessary), then pass along the deep link. The
        // menu controller will take care of sending the user to the correct experience.
        NSString *targetURL = [params valueForKey:@"target_url"];
        NSLog(@"targetURL :::: %@",targetURL);
        
    }
    self.openedURL = nil;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    application.applicationIconBadgeNumber = 0;
    NSLog(@"AppDelegate didReceiveLocalNotification %@", notification.userInfo);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notify_allbars" object:nil];
}

@end
