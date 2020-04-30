//
//  AppDelegate.h
//  momentsapp
//
//  Created by M.A.D on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "ColorSwitcher.h"
#define kFilename @"data.sqlite3"

@class MapViewController;

extern NSString *const FBSessionStateChangedNotification;
extern NSString *const FBMenuDataChangedNotification;

typedef void(^UserDataLoadedHandler)(id sender, id<FBGraphUser> user);

@interface AppDelegate : UIResponder <UIApplicationDelegate>

+(AppDelegate *) instance;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) ColorSwitcher * colorSwitcher;
@property (strong, nonatomic) NSURL *openedURL;
@property (nonatomic, strong) NSString *userKey;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) NSDictionary *jsonResponse;
@property (strong, nonatomic) id<FBGraphUser> user;

-(void)requestUserData:(UserDataLoadedHandler)handler;
-(BOOL)openSessionWithAllowLoginUI:(BOOL)allowLoginUI;
-(void)closeSession;
-(void)customizeGlobalTheme;
- (NSString *)dataFilePath;
-(void)iPadInit;
-(void)iPhoneInit;
@end
