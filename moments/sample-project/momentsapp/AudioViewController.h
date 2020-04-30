//
//  AudioViewController.h
//  momentsapp
//
//  Created by Joshua Balogun on 9/19/13.
//
//


#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ASIHTTPRequestDelegate.h"
#import "ASIProgressDelegate.h"
#import "MBProgressHUD.h"

@interface AudioViewController : UIViewController <AVAudioRecorderDelegate, AVAudioPlayerDelegate, ASIHTTPRequestDelegate,ASIProgressDelegate>
{
    float totalSize;
    float sentSize;
}

@property (nonatomic, strong) IBOutlet UIButton *recordPauseButton;
@property (nonatomic, strong) IBOutlet UIButton *stopButton;
@property (nonatomic, strong) IBOutlet UIButton *playButton;
@property (nonatomic, strong) IBOutlet UIButton *uploadButton;
@property (nonatomic, strong) IBOutlet UITextField *nameField;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) NSString *userkey;
@property (nonatomic, strong) NSURL *outputFileURL;
@property (nonatomic, strong) NSData *audioData;

@end