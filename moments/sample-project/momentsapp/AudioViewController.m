//
//  AudioViewController.m
//  momentsapp
//
//  Created by Joshua Balogun on 9/19/13.
//
//


#import "AudioViewController.h"
#import "ASIFormDataRequest.h"

@interface AudioViewController ()
{
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
}

@end


@implementation AudioViewController

@synthesize recordPauseButton, stopButton, playButton, uploadButton;
@synthesize HUD, nameField, userkey, outputFileURL, audioData;

- (void)viewDidLoad
{
    
    self.contentSizeForViewInPopover=CGSizeMake(320.0,320.0);
    [super viewDidLoad];
	
    // Disable Stop/Play button when application launches
    
    UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"landscapeBG.png"]];
    [self.view addSubview:imageView];
    [self.view sendSubviewToBack:imageView];
    
    recordPauseButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [recordPauseButton addTarget:self
                action:@selector(recordPauseTapped:)
      forControlEvents:UIControlEventTouchUpInside];
    [recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    [recordPauseButton setBackgroundImage:[UIImage imageNamed:@"button-pink.png"] forState:UIControlStateNormal];
    [recordPauseButton setBackgroundImage:[UIImage imageNamed:@"button-pink-down.png"] forState:UIControlStateHighlighted];
    
    
    stopButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [stopButton addTarget:self
                   action:@selector(stopTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    [stopButton setTitle:@" Stop " forState:UIControlStateNormal];
    [stopButton setBackgroundImage:[UIImage imageNamed:@"button-grrey.png"] forState:UIControlStateNormal];
    [stopButton setBackgroundImage:[UIImage imageNamed:@"button-grey-down.png"] forState:UIControlStateHighlighted];
    
    
    playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [playButton addTarget:self
                   action:@selector(playTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    [playButton setTitle:@" Play Back " forState:UIControlStateNormal];
    [playButton setBackgroundImage:[UIImage imageNamed:@"button-grrey.png"] forState:UIControlStateNormal];
    [playButton setBackgroundImage:[UIImage imageNamed:@"button-grey-down.png"] forState:UIControlStateHighlighted];
    
    
    uploadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [uploadButton addTarget:self
                   action:@selector(uploadAudio:)
         forControlEvents:UIControlEventTouchUpInside];
    [uploadButton setTitle:@" Upload " forState:UIControlStateNormal];
    [uploadButton setBackgroundImage:[UIImage imageNamed:@"button-green.png"] forState:UIControlStateNormal];
    [uploadButton setBackgroundImage:[UIImage imageNamed:@"button-green-down.png"] forState:UIControlStateHighlighted];
    
    
    UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
    
    if (idiom == UIUserInterfaceIdiomPad)
    {
        recordPauseButton.frame = CGRectMake(10.0, 20.0, 300.0, 40.0);
        stopButton.frame = CGRectMake(10.0, 80.0, 300.0, 40.0);
        playButton.frame = CGRectMake(10.0, 140.0, 300.0, 40.0);
        uploadButton.frame = CGRectMake(10.0, 200.0, 300.0, 40.0);
    }
    else
    {
        recordPauseButton.frame = CGRectMake(10.0, 100.0, 300.0, 40.0);
        stopButton.frame = CGRectMake(10.0, 160.0, 300.0, 40.0);
        playButton.frame = CGRectMake(10.0, 220.0, 300.0, 40.0);
        uploadButton.frame = CGRectMake(10.0, 280.0, 300.0, 40.0);
        
        UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        labelTitle.text = [@"Audio Console" capitalizedString];
        labelTitle.backgroundColor = [UIColor clearColor];
        labelTitle.textColor = [UIColor whiteColor];
        labelTitle.font = [UIFont fontWithName:@"Avenir-Black" size:19];
        [labelTitle sizeToFit];
        self.navigationItem.titleView = labelTitle;
        
        UIBarButtonItem* backButton = [self createBackBarButtonWithImage:@"back.png"];
        [self.navigationItem setLeftBarButtonItem:backButton];
        
    }
    
    [self.view addSubview:recordPauseButton];
    [self.view addSubview:stopButton];
    [self.view addSubview:playButton];
    [self.view addSubview:uploadButton];
    
    
    [stopButton setEnabled:NO];
    [playButton setEnabled:NO];
    [uploadButton setEnabled:NO];
    
    // Set the audio file
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.m4a",
                               nil];
    outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:nil];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)recordPauseTapped:(id)sender
{
    
    // Stop the audio player before recording
    if (player.playing) {
        [player stop];
    }
    
    if (!recorder.recording) {
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
        [recordPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
        
    } else {
        
        // Pause recording
        [recorder pause];
        [recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    }
    
    [stopButton setEnabled:YES];
    [playButton setEnabled:NO];
    [uploadButton setEnabled:NO];
}

- (void)stopTapped:(id)sender
{
    [recorder stop];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (void)playTapped:(id)sender
{
    if (!recorder.recording)
    {
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
        [player setDelegate:self];
        [player play];
        NSLog(@"url of the player ::::  %@", recorder.url);
    }
}

#pragma mark - AVAudioRecorderDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag
{
    [recordPauseButton setTitle:@"Record" forState:UIControlStateNormal];
    [stopButton setEnabled:NO];
    [playButton setEnabled:YES];
    [uploadButton setEnabled:YES];
}

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Done"
                                                    message: @"Finish playing the recording!"
                                                   delegate: nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

-(void)uploadAudio:(id)sender
{
    [self nameVideo];
    
}

- (void)nameVideo
{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Give a title to this recording\n\n"
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Continue", nil];
    [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    alert.tag = 200;
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    //NSLog(@"button pressed -> %i",buttonIndex);
    
    if (buttonIndex == 1)
    {
        
        if (alertView.tag == 200 )
        {
            
            nameField = [alertView textFieldAtIndex:0];
            //NSLog(@"Entered Password: %@", pass.text);
            
            if ([nameField.text isEqualToString:@""])
            {
                [self nameVideo];
            }
            else
            {
                [self startUploading];
            }
            
        }
        
    }
    else if (buttonIndex == 0)
    {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
    
}

-(void)startUploading
{
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = @"Loading ...";
    HUD.delegate = (id)self;
    [self.view addSubview:HUD];
	
	// myProgressTask uses the HUD instance to update progress
    [self performSelectorOnMainThread:@selector(myProgressTask) withObject:nil waitUntilDone:YES];
}

-(void)myProgressTask
{
    sentSize=0;
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://208.109.186.98/starcmssite/api/audio_upload/upload"]];
    
    //NSString *audioPath=[[NSBundle mainBundle] pathForResource:@"MyAudioMemo" ofType:@"m4a"];
    //NSData *audioData=[[NSData alloc] initWithContentsOfFile:audioPath];
    audioData = [NSData dataWithContentsOfFile:[outputFileURL path]];
    totalSize= (float)audioData.length;
    
    [request setRequestMethod:@"POST"];
    [request setPostValue:userkey forKey:@"key"];
    [request setPostValue:nameField.text forKey:@"title"];
    [request addData:audioData withFileName:@"MyAudioMemo.mp3" andContentType:(@"audio/*") forKey:@"audio"];
    [request setPostValue:@"ios" forKey:@"client"];
    
    [request setDelegate:self];
    [request setUploadProgressDelegate:self];
    [request startAsynchronous];
    
}

- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes
{
    float settoprogress;
    
    sentSize+=bytes;
    settoprogress=(sentSize/totalSize);
    HUD.progress=settoprogress;
    NSLog(@"%f",settoprogress);
}

- (void) requestFinished:(ASIHTTPRequest *)request
{
    //NSString *responseString = [request responseString];
    NSLog(@"Response %d : %@", request.responseStatusCode, [request responseString]);
    
    //NSData *responseData = [request responseData];
    [HUD hide:YES afterDelay:1];
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setDelegate:self];
    [alert setTitle:@"Star Music"];
    [alert setMessage:@"File Successfully Uploaded."];
    [alert addButtonWithTitle:@"OK"];
    [alert setTag:93];
    [alert show];
    
    [self performSelector: @selector(refreshTapped:) withObject:self afterDelay: 1.0];
    
}

- (void) requestStarted:(ASIHTTPRequest *) request
{
    NSLog(@"request started...");
}

- (void) requestFailed:(ASIHTTPRequest *) request
{
    NSError *error = [request error];
    NSLog(@"%@", error);
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setDelegate:self];
    [alert setTitle:@"Error"];
    [alert setMessage:@"Could not upload at this time. check internet settings or try again later."];
    [alert addButtonWithTitle:@"OK"];
    [alert setTag:93];
    [alert show];
}

-(void)refreshTapped: (id)sender
{
    NSLog(@"Finished");
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshContent" object:@"audio uploads"];
}

- (void)viewDidUnload
{
    [HUD hide:YES];
    [super viewDidUnload];
}

@end

