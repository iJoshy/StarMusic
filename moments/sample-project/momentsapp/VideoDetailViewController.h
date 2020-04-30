//
//  VideoDetailViewController.h
//  momentsapp
//
//  Created by Joshua Balogun on 9/25/13.
//
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "Model.h"

@interface VideoDetailViewController : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate,UIWebViewDelegate, MFMailComposeViewControllerDelegate, FBUserSettingsDelegate>
{
    AVAudioPlayer *player;
    AVAudioRecorder *recorder;
}

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;
@property (nonatomic, strong) IBOutlet UILabel* dateLabel;
@property (nonatomic, strong) IBOutlet UIScrollView* scrollView;
@property (nonatomic, strong) IBOutlet UIWebView* articleWebView;
@property (nonatomic, strong) IBOutlet UIView* shadowView;
@property (nonatomic, retain) Model* model;
@property (nonatomic, strong) NSString *userKey;
@property (nonatomic, strong) NSString *whichView;
@property (nonatomic, strong) NSString *commentID;
@property (nonatomic, strong) NSString *noLikes;
@property (nonatomic, strong) NSString *noComments;
@property (nonatomic, strong) NSString *titlelabel;
@property (nonatomic, strong) NSString *imagePath;
@property (nonatomic, strong) NSString *categoryID;
@property (nonatomic, strong) IBOutlet UIImageView* articleImageView;

-(UIBarButtonItem*)createBackBarButtonWithImage:(NSString*)imageName;

-(void)back;

@end
