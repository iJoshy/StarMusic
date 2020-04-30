//
//  DetailThemeController.m
//  blogplex
//
//  Created by Tope on 27/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailThemeController.h"
#import "SVProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "phoneCommentsViewController.h"
#import "KxMenu.h"

@implementation DetailThemeController

@synthesize titleLabel, articleImageView, articleWebView, dateLabel, scrollView, model, shadowView;
@synthesize userKey, whichView, noComments, noLikes, commentID, titlelabel, share, imagePath;



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    
    [SVProgressHUD dismiss];
    
    if([[[UIDevice currentDevice] systemVersion] integerValue] < 7)
    {
        [scrollView setFrame:CGRectMake(0, 95, 320, 400)];
    }
    else
    {
        [scrollView setFrame:CGRectMake(0, 0, 320, 520)];
    }
    
    if (model.image != nil)
    {
        [articleImageView setImage:model.image];
        [articleImageView setContentMode:UIViewContentModeScaleAspectFit];
    }
    
    NSString *content = model.content;
    NSString *removeRN = [content stringByReplacingOccurrencesOfString: @"\\r\\n" withString:@""];
    NSString *bodyContent = [removeRN stringByReplacingOccurrencesOfString: @"&nbsp;" withString:@" "];
    
    [articleWebView loadHTMLString:bodyContent baseURL:nil];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"EEE, dd MMMM yyyy"];
    [dateLabel setText:[format stringFromDate:model.date]];
    [titleLabel setText:model.title];
    
    articleWebView.delegate = self;
    
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1.0]];

    shadowView.layer.shadowColor = [UIColor blackColor].CGColor; 
    shadowView.layer.shadowOffset = CGSizeMake(0, 0);
    shadowView.layer.shadowOpacity = 0.4;
    shadowView.layer.shadowRadius = 4; 
    shadowView.layer.masksToBounds = NO;
    
    [articleImageView setClipsToBounds:YES];
  
    UIBarButtonItem* backButton = [self createBackBarButtonWithImage:@"back.png"];
    [self.navigationItem setLeftBarButtonItem:backButton];
    

    UIImage *menuButtonImage = [UIImage imageNamed:@"share.png"];// set your image Name here
    UIButton *btnShare = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnShare setImage:menuButtonImage forState:UIControlStateNormal];
    btnShare.frame = CGRectMake(0, 0, menuButtonImage.size.width, menuButtonImage.size.height);
    [btnShare addTarget:self action:@selector(shareStuff) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuBarButton = [[UIBarButtonItem alloc] initWithCustomView:btnShare];
    menuBarButton.width = 0.0;
    self.navigationItem.rightBarButtonItem = menuBarButton;
    
    
    //share = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareStuff)];
    //share.width = 0.0;
    //[self.navigationItem setRightBarButtonItem:share];
    
    [KxMenu setTitleFont:[UIFont systemFontOfSize:14]];
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    labelTitle.text = [whichView capitalizedString];
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.textColor = [UIColor whiteColor];
    labelTitle.font = [UIFont fontWithName:@"Avenir-Black" size:19];
    [labelTitle sizeToFit];
    self.navigationItem.titleView = labelTitle;

    [super viewDidLoad];
    
}

- (void) shareStuff
{
    NSLog(@"uploading  ::::");
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"  facebook   "
                     image:[UIImage imageNamed:@"share_facebook"]
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"   twitter  "
                     image:[UIImage imageNamed:@"share_twitter"]
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"   email  "
                     image:[UIImage imageNamed:@"share_email"]
                    target:self
                    action:@selector(pushMenuItem:)],
      ];
    
    if([[[UIDevice currentDevice] systemVersion] integerValue] < 7)
    {
        [KxMenu showMenuInView:self.view fromRect:CGRectMake(270, -30, 50, 30) menuItems:menuItems];
    }
    else
    {
        [KxMenu showMenuInView:self.view fromRect:CGRectMake(260, 35, 50, 30) menuItems:menuItems];
    }
    
}

- (void) pushMenuItem:(id)sender
{
    NSLog(@"%@", sender);
    
    KxMenuItem *textfield= (KxMenuItem*)sender;
    if([textfield.title isEqualToString:@"  facebook   "] )
    {
        NSLog(@"fb");
        [self facebookShare];
    }
    else if([textfield.title isEqualToString:@"   twitter  "] )
    {
        NSLog(@"twitte");
        [self twitterShare];
    }
    else if([textfield.title isEqualToString:@"   email  "] )
    {
        NSLog(@"email");
        [self emailShare];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webview
{
    
    CGRect frame = self.articleWebView.frame;
    CGSize fittingSize = [self.articleWebView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    self.articleWebView.frame = frame;
    
    CGFloat totalHeight = self.articleWebView.frame.origin.y + self.articleWebView.frame.size.height + 30;
    
    
    [scrollView setContentSize:CGSizeMake(320, totalHeight)];
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([[segue identifier] isEqualToString:@"commentSegue"])
    {
        phoneCommentsViewController *commentVC = [segue destinationViewController];
        commentVC.userKey = userKey;
        commentVC.whichView = whichView;
        commentVC.commentId = commentID;
        commentVC.noComments = noComments;
        commentVC.noLikes = noLikes;
        commentVC.titlelabel = model.title;
    }
}

-(void)facebookShare
{
    
    NSString *removeRN = [model.content stringByReplacingOccurrencesOfString: @"\\r\\n" withString:@"\r\n"];
    NSString *bodyContent = [removeRN stringByReplacingOccurrencesOfString: @"&nbsp;" withString:@" "];
    
    NSDictionary* params = @{@"name": whichView,
                             @"caption": model.title,
                             @"description": bodyContent,
                             @"link": @"http://star-nigeria.com/starmusic/",
                             @"picture":imagePath};
    
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:params
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                  // handle response or error
                                              }];
}


-(void)twitterShare
{
    
    TWTweetComposeViewController *twitter = [TWTweetComposeViewController new];
    
    [twitter setInitialText:model.title];
    [twitter addImage:model.image];
    
    [self presentViewController:twitter animated:YES completion:nil];
    
    twitter.completionHandler = ^(TWTweetComposeViewControllerResult res) {
        
        if(res == TWTweetComposeViewControllerResultDone) {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Success" message:@"The Tweet was posted successfully." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            
            [alert show];
            
        }
        if(res == TWTweetComposeViewControllerResultCancelled) {
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Cancelled" message:@"You Cancelled posting the Tweet." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
            
            [alert show];
            
        }
        [self dismissModalViewControllerAnimated:YES];
        
    };
    
}

-(void) emailShare
{
    
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    
	if (mailClass != nil)
	{
		if ([mailClass canSendMail])
		{
			[self displayComposerSheet];
		}
		else
		{
			[self launchMailAppOnDevice];
		}
	}
	else
	{
		[self launchMailAppOnDevice];
	}
    
    
}


-(void)displayComposerSheet
{
    
	MFMailComposeViewController *picker = [MFMailComposeViewController new];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:model.title];
	
    NSString *removeRN = [model.content stringByReplacingOccurrencesOfString: @"\\r\\n" withString:@"\r\n"];
    NSString *bodyContent = [removeRN stringByReplacingOccurrencesOfString: @"&nbsp;" withString:@" "];
    
	[picker setMessageBody:bodyContent isHTML:NO];
    NSData *exportData = UIImageJPEGRepresentation(model.image ,1.0);
    [picker addAttachmentData:exportData mimeType:@"image/jpeg" fileName:@"Picture.jpeg"];
    
	[self presentModalViewController:picker animated:YES];
    
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    
	[self dismissViewControllerAnimated:YES completion:nil];
    
}


-(void)launchMailAppOnDevice
{
    
    NSString *removeRN = [model.content stringByReplacingOccurrencesOfString: @"\\r\\n" withString:@"\r\n"];
    NSString *bodyContent = [removeRN stringByReplacingOccurrencesOfString: @"&nbsp;" withString:@" "];
    
	NSString *urlString = [NSString stringWithFormat:@"mailto:osa@gmail.com?subject=%@&messagebody=%@",model.title,bodyContent];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
}


@end
