//
//  VideoDetailViewController.m
//  momentsapp
//
//  Created by Joshua Balogun on 9/25/13.
//
//

#import "VideoDetailViewController.h"
#import "phoneCommentsViewController.h"
#import "SVProgressHUD.h"
#import "KxMenu.h"

@interface VideoDetailViewController ()

@end

@implementation VideoDetailViewController

@synthesize titleLabel, articleWebView, dateLabel, scrollView, model, shadowView;
@synthesize whichView, userKey, commentID, noLikes, noComments, titlelabel, imagePath;
@synthesize articleImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    
    if([[[UIDevice currentDevice] systemVersion] integerValue] < 7)
    {
        [scrollView setFrame:CGRectMake(0, 95, 320, 400)];
    }
    else
    {
        [scrollView setFrame:CGRectMake(0, 0, 320, 520)];
    }
    
    [titleLabel setText:model.title];
    [self embedYouTube:model.content];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"EEE, dd MMMM yyyy"];
    [dateLabel setText:[format stringFromDate:model.date]];
    
    UIImage *menuButtonImage = [UIImage imageNamed:@"share.png"];// set your image Name here
    UIButton *btnShare = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnShare setImage:menuButtonImage forState:UIControlStateNormal];
    btnShare.frame = CGRectMake(0, 0, menuButtonImage.size.width, menuButtonImage.size.height);
    [btnShare addTarget:self action:@selector(shareStuff) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *menuBarButton = [[UIBarButtonItem alloc] initWithCustomView:btnShare];

    
    if ( [whichView isEqualToString:@"my downloads"] )
    {
        if ([_categoryID isEqualToString:@"0"])
            [self playdownload];
        else
            [self loadImage];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = menuBarButton;
    }
    
    [KxMenu setTitleFont:[UIFont systemFontOfSize:14]];
    
    
    NSString *toptitle = @"";
    if ( [whichView isEqualToString:@"adverts"])
        toptitle = @"star stories";
    else
        toptitle = whichView;
    
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    labelTitle.text = [toptitle capitalizedString];
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.textColor = [UIColor whiteColor];
    labelTitle.font = [UIFont fontWithName:@"Avenir-Black" size:19];
    [labelTitle sizeToFit];
    self.navigationItem.titleView = labelTitle;
    
    [self.view setBackgroundColor:[UIColor colorWithWhite:0.95 alpha:1.0]];
    
    shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowView.layer.shadowOffset = CGSizeMake(0, 0);
    shadowView.layer.shadowOpacity = 0.4;
    shadowView.layer.shadowRadius = 4;
    shadowView.layer.masksToBounds = NO;
    
    [articleWebView setClipsToBounds:YES];
    
    UIBarButtonItem* backButton = [self createBackBarButtonWithImage:@"back.png"];
    [self.navigationItem setLeftBarButtonItem:backButton];
    
    [super viewDidLoad];
}

-(void)loadImage
{
    NSString *urlString = model.content;
    NSArray* foo = [urlString componentsSeparatedByString: @"Ω"];
    titleLabel.text = [foo objectAtIndex:0];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/gallery/%@",[paths objectAtIndex:0],urlString];
    
    NSLog(@"html path  :: %@",path);
    
    articleImageView = [[UIImageView alloc] init];
    
    if([[[UIDevice currentDevice] systemVersion] integerValue] < 7)
    {
        [articleImageView setFrame:CGRectMake(0, 95, 320, 400)];
    }
    else
    {
        [articleImageView setFrame:CGRectMake(5, 50, 309, 360)];
    }
    
    articleImageView.image = [UIImage imageWithContentsOfFile:path];
    articleImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:articleImageView];
}



-(void)playdownload
{
    NSString *urlString = model.content;
    NSArray* foo = [urlString componentsSeparatedByString: @"Ω"];
    
    NSString* title = [foo objectAtIndex:0];
    titleLabel.text = title;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/videos/%@",[paths objectAtIndex:0],urlString];
    
    NSLog(@"html path  :: %@",path);
    [articleWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
    
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


- (void)embedYouTube:(NSString *)urlString
{
    [articleWebView loadHTMLString:@"" baseURL:nil];
    
    NSString *newUrlString = [urlString stringByReplacingOccurrencesOfString:@"watch?v=" withString:@"embed/"];
    
    NSString *html = [NSString stringWithFormat:@"<html><body><iframe class=\"youtube-player\" type=\"text/html\" width=\"%f\" height=\"%f\" src=\"%@?HD=1;rel=0;showinfo=0\" allowfullscreen frameborder=\"0\" rel=nofollow></iframe></body></html>", 309.0, 218.0,newUrlString];
    
    [articleWebView loadHTMLString:html baseURL:nil];
    
    [SVProgressHUD dismiss];
    
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
    
    NSDictionary* params = @{@"name": whichView,
                             @"caption": model.title,
                             @"description": model.content,
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
    
	[picker setMessageBody:model.content isHTML:NO];
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
