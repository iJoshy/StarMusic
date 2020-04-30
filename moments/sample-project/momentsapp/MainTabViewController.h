//
//  MainTabViewController.h
//  momentsapp
//
//  Created by Joshua Balogun on 9/29/13.
//
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#define kFilename @"data.sqlite3"

@interface MainTabViewController : UITabBarController <FBUserSettingsDelegate>

@property (nonatomic, strong) NSString *userKey;
@property (strong, nonatomic) NSDictionary<FBGraphUser> *user;

- (void)sessionStateChanged:(NSNotification*)notification;
-(NSString *)dataFilePath;

@end
