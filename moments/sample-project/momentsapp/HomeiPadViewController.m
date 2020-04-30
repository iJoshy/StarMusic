//
//  HomeiPadViewController.m
//  momentsapp
//
//  Created by M.A.D on 3/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "HomeiPadViewController.h"
#import "CommentCell.h"
#import "SimpleFlickrAPI.h"
#import "ImageDownloader.h"
#import "MBProgressHUD.h"
#import "ASIFormDataRequest.h"
#import "KxMenu.h"

@interface HomeiPadViewController ()

@end

@implementation HomeiPadViewController

@synthesize comments, videoView, table, noComments, noLikes;
@synthesize bigPhoto, thumbnail, commentId, titleLabel, moreLabel;
@synthesize backButton, homePhoto, bigimage, commentTextField, toolbar;
@synthesize titleButton, HUD, videoIndex, userKey, catergoryID, share;
@synthesize whichView, jsonResponse, downloaders = _downloaders, downloadButton;


- (IBAction)btnPressed:(id)sender
{
    
    [sender setBackgroundImage:[UIImage imageNamed:@"pink_high_new.png"]
                      forState:UIControlStateNormal];
}

- (IBAction)backBtnPressed:(id)sender
{
    [videoView loadHTMLString:@"" baseURL:nil];
    
    [HUD hide:YES];
    [HUD removeFromSuperview];
    HUD = nil;
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"landscapeBG.png"]];
    
    bigPhoto.image = homePhoto;
    bigPhoto.contentMode = UIViewContentModeScaleAspectFit;
    
    imageView.frame = self.view.bounds;
    imageView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.view addSubview:imageView];
    [self.view sendSubviewToBack:imageView];
    
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    downloadButton.width = 0.1;
    share.width = 0.1;
    
    if ([whichView isEqualToString:@"gallery"])
    {
        moreLabel.text = @"More Images";
        downloadButton.width = 0.0;
        share.width = 0.0;
        
        UIImage *configImage = [UIImage imageNamed:@"share.png"];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0,0, configImage.size.width, configImage                     .size.height)];
        [btn setBackgroundImage:configImage forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(shareStuff) forControlEvents:UIControlEventTouchUpInside];
        share.customView = btn;
        [KxMenu setTitleFont:[UIFont systemFontOfSize:14]];
        
    }
    
    if ([whichView isEqualToString:@"videos"])
    {
        share.width = 0.0;
        [toolbarItems removeObjectAtIndex:3];
        [self.toolbar setItems:toolbarItems animated:NO];
        
        UIImage *configImage = [UIImage imageNamed:@"share.png"];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0,0, configImage.size.width, configImage                     .size.height)];
        [btn setBackgroundImage:configImage forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(shareStuff) forControlEvents:UIControlEventTouchUpInside];
        share.customView = btn;
        [KxMenu setTitleFont:[UIFont systemFontOfSize:14]];
    }
    
    
    NSString *toptitle = @"";
    if ( [whichView isEqualToString:@"adverts"])
        toptitle = @"star stories";
    else
        toptitle = whichView;
    
    
    UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(0 , 0, 50, 250)];
    [titlelabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
    [titlelabel setBackgroundColor:[UIColor clearColor]];
    [titlelabel setTextColor:[UIColor whiteColor]];
    [titlelabel setTextAlignment:NSTextAlignmentCenter];
    
    titlelabel.text = [toptitle stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[toptitle substringToIndex:1] capitalizedString]];
    UIView *view = (UIView *) titlelabel;
    [self.titleButton setCustomView:view];
    
    scrollView.backgroundColor = [UIColor clearColor];
    
    NSLog(@"This view is for  :: %@",whichView);
    NSLog(@"Gallery Main Page ::::: viewDidLoad :::: %i", [self.jsonResponse count]);
    NSLog(@"index tapped ::::: viewDidLoad :::: %@", videoIndex);
    
    if ( [whichView isEqualToString:@"my downloads"])
    {
        if ([catergoryID isEqualToString:@"0"])
            [self playdownload];
        else
            [self loadImage];
    }
    else
    {
        [self fillScrollView];
        [self loadFirstVideo];
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications ];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil ];
    }
    
    
    NSLog(@"This is detailview is for  :: %@",whichView);
    
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
    
    [KxMenu showMenuInView:self.view fromRect:CGRectMake(860, 3, 100, 50) menuItems:menuItems];
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


- (IBAction)downloadPressed:(id)sender
{
    NSLog(@"download image");
    UIActionSheet *actionSheetShare = [[UIActionSheet alloc] initWithTitle:nil
                                                                  delegate:self
                                                         cancelButtonTitle:nil
                                                    destructiveButtonTitle:NSLocalizedString(@"Download Picture", @"")
                                                         otherButtonTitles:NSLocalizedString(@"Cancel", @""),nil];
    
    [actionSheetShare showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet destructiveButtonIndex])
    {
        [self startDownloading];
    }
}

-(void)startDownloading
{
    
    [HUD show:YES];
    
    // myProgressTask uses the HUD instance to update progress
    [self performSelectorOnMainThread:@selector(myDownloadTask) withObject:nil waitUntilDone:YES];
    
}

-(void)myDownloadTask
{
    
    NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:[videoIndex intValue]];
    NSString* urlString = [flickrPhoto objectForKey:@"image_path"];
    NSString *title = [flickrPhoto objectForKey:@"title"];
    NSArray* foo = [urlString componentsSeparatedByString: @"/"];
    NSString* filename = [foo lastObject];
    
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *appSupportDir = [fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL* dirPath = [[appSupportDir objectAtIndex:0] URLByAppendingPathComponent:@"gallery"];
    
    NSError*  theError = nil; //error setting
    if (![fm createDirectoryAtURL:dirPath withIntermediateDirectories:YES attributes:nil error:&theError])
    {
        NSLog(@"not created");
    }
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/gallery/%@Ω%@", documentsDirectory, title, filename];
    
    NSLog(@"Downloading begins ::: %@",filePath);

    NSData *imageData = UIImagePNGRepresentation(homePhoto);
    [imageData writeToFile:filePath atomically:NO];
    
    [HUD hide:YES afterDelay:1];
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setDelegate:self];
    [alert setTitle:@"Star Music"];
    [alert setMessage:@"File transfer Successfully."];
    [alert addButtonWithTitle:@"OK"];
    [alert setTag:93];
    [alert show];
    
}

-(void)fetchDownloadedContent
{
    [self setJsonResponse:[self ls]];
}

- (NSArray *)ls
{
    NSError *err;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@/videos",[paths objectAtIndex:0]];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&err];
    
    NSLog(@"%@", documentsDirectory);
    NSLog(@"%@", directoryContent);
    
    return directoryContent;
}

#pragma mark - Flickr

- (void)fetchFlickrPhotoWithSearchString
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSArray *photos = [flickr barFinder:whichView:catergoryID];
                       
                       NSMutableArray *downloaders = [[NSMutableArray alloc] initWithCapacity:[photos count]];
                       for (NSInteger index = 0; index < [photos count]; index++)
                       {
                           ImageDownloader *downloader = [[ImageDownloader alloc] init];
                           [downloaders addObject:downloader];
                       }
                       
                       [self setDownloaders:downloaders];
                       [self setJsonResponse:photos];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self fillScrollView];
                           [self loadFirstVideo];
                           [HUD hide:YES afterDelay:1];
                       });
                   });
}


- (void)fillScrollView
{
    
    for (int i=0; i < [[self jsonResponse] count]; i++)
    {
        
        NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:i];
        
        ImageDownloaderCompletionBlock completion =^(UIImage *image, NSError *error)
        {
            UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(30 + (i*138), 20, 129, 129)];
            [btn setContentMode:UIViewContentModeScaleAspectFit];
            [btn addTarget:self action:@selector(handleThumbClick:) forControlEvents:UIControlEventTouchUpInside];
            [btn setTag:i];
            
            if (image)
            {
                //space between button is (i*136)
                [btn setImage:image forState:UIControlStateNormal];
            }
            else
            {
                [btn setImage:[UIImage imageNamed:@"nopic.png"] forState:UIControlStateNormal];
                //NSLog(@"%s: Error: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
            }
            
            UIImageView *imgViewWhite = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"white-button"]];
            
            if ([whichView isEqualToString:@"gallery"])
                imgViewWhite.frame = CGRectMake(-5, -4, 140 , 140);
            else
                imgViewWhite.frame = CGRectMake(-4, 11, 140 , 109);
            
            [btn addSubview:imgViewWhite];
            
            if (i == [videoIndex intValue])
            {
                UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"button_frame"]];
                
                if ([whichView isEqualToString:@"gallery"])
                    imgView.frame = CGRectMake(-3, -3, 135, 135);
                else
                    imgView.frame = CGRectMake(0, 12, 133, 103);
                
                imgView.tag = 99;
                [btn addSubview:imgView];
            }
            
            UILabel *titlelabel = [[UILabel alloc] init];
            [titlelabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:10.0]];
            [titlelabel setBackgroundColor:[UIColor clearColor]];
            [titlelabel setTextColor:[UIColor whiteColor]];
            [titlelabel setTextAlignment:NSTextAlignmentLeft];
            [titlelabel setNumberOfLines:2];
            [titlelabel setText:[flickrPhoto objectForKey:@"title"]];
            
            if ([whichView isEqualToString:@"videos"])
                [titlelabel setFrame:CGRectMake(30 + (i * 138), 130, 129, 50)];
            else
                [titlelabel setFrame:CGRectMake(30 + (i * 138), 140, 129, 50)];
            
            [scrollView addSubview:titlelabel];
            [scrollView addSubview:btn];
            
        };
        
        
        NSURL *URL = [NSURL URLWithString:[flickrPhoto objectForKey:thumbnail]];
        ImageDownloader *downloader = [[ImageDownloader alloc] init];
        [downloader downloadImageAtURL:URL completion:completion];
        
        [[self downloaders] addObject:downloader];

    }
    
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(scrollingTimer) userInfo:nil repeats:YES];
}

- (void)scrollingTimer
{
    // access the scroll view with the tag
    UIScrollView *scrMain = (UIScrollView*) [self.view viewWithTag:1];
    // same way, access pagecontroll access
    UIPageControl *pgCtr = (UIPageControl*) [self.view viewWithTag:12];
    // get the current offset ( which page is being displayed )
    CGFloat contentOffset = scrMain.contentOffset.x;
    // calculate next page to display
    int nextPage = (int)(contentOffset/scrMain.frame.size.width) + 1 ;
    // if page is not 10, display it
    if( nextPage!=10 )  {
        [scrMain scrollRectToVisible:CGRectMake(nextPage*scrMain.frame.size.width, 0, scrMain.frame.size.width, scrMain.frame.size.height) animated:YES];
        pgCtr.currentPage=nextPage;
        // else start sliding form 1 :)
    } else {
        [scrMain scrollRectToVisible:CGRectMake(0, 0, scrMain.frame.size.width, scrMain.frame.size.height) animated:YES];
        pgCtr.currentPage=0;
    }
}

- (void)handleThumbClick:(id)sender
{
    
    UIButton *btn = (UIButton*)sender;
    
    for (UIButton *btn in scrollView.subviews)
    {
        [[btn viewWithTag:99] removeFromSuperview];
        
    }
    
    UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"button_frame"]];
    
    if ([whichView isEqualToString:@"gallery"])
        imgView.frame = CGRectMake(-3, -3, 135 , 135);
    else
        imgView.frame = CGRectMake(0, 12, 133, 103);
    
    imgView.tag = 99;
    [btn addSubview:imgView];
    
    
    NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:btn.tag];
    videoIndex = [NSString stringWithFormat:@"%d",btn.tag];
    
    if ([whichView isEqualToString:@"gallery"] || [whichView isEqualToString:@"videos"])
    {
        ImageDownloaderCompletionBlock completion =^(UIImage *image, NSError *error)
        {
            if (image)
            {
                homePhoto = image;
                bigPhoto.image = homePhoto;
                bigPhoto.contentMode = UIViewContentModeScaleAspectFit;
                
                [HUD show:YES];
                
                [self performSelectorOnMainThread:@selector(fetchFlickrPhoto) withObject:nil waitUntilDone:YES];
            }
            else
            {
                NSLog(@"%s: Error: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
            }
        };
        
        
        NSURL *URL = [NSURL URLWithString:[flickrPhoto objectForKey:bigimage]];
        ImageDownloader *downloader = [[ImageDownloader alloc] init];
        [downloader downloadImageAtURL:URL completion:completion];
        
        [[self downloaders] addObject:downloader];
    }
    
    if ([whichView isEqualToString:@"videos"] || [whichView isEqualToString:@"adverts"])
    {
        [self embedYouTube:[flickrPhoto objectForKey:@"youtube_url"] frame:bigPhotoFrame.frame];
    }
    
    if ([whichView isEqualToString:@"video uploads"] || [whichView isEqualToString:@"audio uploads"])
    {
        [self embedYouTube:[flickrPhoto objectForKey:@"url"] frame:bigPhotoFrame.frame];
    }
    
    [titleLabel setText:[flickrPhoto objectForKey:@"title"]];
    [noComments setText:[[flickrPhoto objectForKey:@"num_comments"] stringValue]];
    [noLikes setText:[[flickrPhoto objectForKey:@"likes"] stringValue]];
    
}


-(void)loadFirstVideo
{
    NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:[videoIndex intValue]];
    
    if ([whichView isEqualToString:@"videos"] || [whichView isEqualToString:@"adverts"])
    {
        if ( [flickrPhoto objectForKey:@"youtube_url"] == NULL)
             [self embedYouTube:[flickrPhoto objectForKey:@"video_url"] frame:bigPhotoFrame.frame];
        else
             [self embedYouTube:[flickrPhoto objectForKey:@"youtube_url"] frame:bigPhotoFrame.frame];
    }
    
    if ([whichView isEqualToString:@"video uploads"] || [whichView isEqualToString:@"audio uploads"] || [whichView isEqualToString:@"audios"])
    {
        [self embedYouTube:[flickrPhoto objectForKey:@"url"] frame:bigPhotoFrame.frame];
    }
    
    [titleLabel setText:[flickrPhoto objectForKey:@"title"]];
    [noComments setText:[[flickrPhoto objectForKey:@"num_comments"] stringValue]];
    [noLikes setText:[[flickrPhoto objectForKey:@"likes"] stringValue]];
    
    commentId = [flickrPhoto objectForKey:@"id"];
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = @"Loading ...";
    HUD.delegate = (id)self;
    [self.view addSubview:HUD];
    
    NSLog(@"This view is for  :: %@",whichView);
    
    [self performSelectorOnMainThread:@selector(fetchFlickrPhoto) withObject:nil waitUntilDone:YES];
    
}

-(void)loadImage
{
    NSString *urlString = [jsonResponse objectAtIndex:[videoIndex intValue]];
    NSArray* foo = [urlString componentsSeparatedByString: @"Ω"];
    titleLabel.text = [foo objectAtIndex:0];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/gallery/%@",[paths objectAtIndex:0],urlString];
    
    NSLog(@"html path  :: %@",path);
    bigPhoto.image = [UIImage imageWithContentsOfFile:path];
    bigPhoto.contentMode = UIViewContentModeScaleAspectFit;
}

-(void)playdownload
{
    NSString *urlString = [jsonResponse objectAtIndex:0];
    NSArray* foo = [urlString componentsSeparatedByString: @"Ω"];
    
    NSString* title = [foo objectAtIndex:0];
    titleLabel.text = title;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/videos/%@",[paths objectAtIndex:0],urlString];

    NSLog(@"html path  :: %@",path);
    videoView = [[UIWebView alloc] initWithFrame:bigPhotoFrame.frame];
    [videoView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:path]]];
    [self.view addSubview:videoView];
   
}

- (void)embedDownload:(NSString *)urlString frame:(CGRect)frame
{
    [videoView loadHTMLString:@"" baseURL:nil];
    
    NSString *html = [NSString stringWithFormat:@"<html><body><video controls=\"controls\" width=\"%f\" height=\"%f\" ><source src=\"%@\" type=\"video/mp4\" /></video></body></html>",frame.size.width,frame.size.height,urlString];
    
    NSLog(@"html path  :: %@",html);
    videoView = [[UIWebView alloc] initWithFrame:frame];
    [videoView loadHTMLString:html baseURL:nil];
    [self.view addSubview:videoView];
    
}


- (void)fetchFlickrPhoto
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSArray *photos = [flickr comments: whichView : @"comments" : commentId];

                       [self setComments:photos];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self.table reloadData];
                           [self like_comments];
                           [HUD hide:YES afterDelay:1];
                       });
                   });
    
}


-(void)like_comments
{
    
    NSLog(@"like_comments :::::");
    
    NSString *commentCount = [NSString stringWithFormat:@"%i",[comments count]];
    
    noComments.text = commentCount;
    
}


- (void)embedYouTube:(NSString *)urlString frame:(CGRect)frame
{
    [videoView loadHTMLString:@"" baseURL:nil];
    
    NSString *newUrlString = [urlString stringByReplacingOccurrencesOfString:@"watch?v=" withString:@"embed/"];
    
    NSString *html = [NSString stringWithFormat:@"<html><body><iframe class=\"youtube-player\" type=\"text/html\" width=\"%f\" height=\"%f\" src=\"%@?HD=1;rel=0;showinfo=0\" allowfullscreen frameborder=\"0\" rel=nofollow></iframe></body></html>",frame.size.width,frame.size.height,newUrlString];
    videoView = [[UIWebView alloc] initWithFrame:frame];
    [videoView loadHTMLString:html baseURL:nil];
    [self.view addSubview:videoView];
    
}


- (void)orientationChanged:(NSNotification *)object
{
    UIDeviceOrientation deviceOrientation=[[object object]orientation ];
    
    if (UIInterfaceOrientationIsPortrait(deviceOrientation))
    {
        commentsView.hidden = YES;
        bigPhotoFrame.frame = CGRectMake(72 + 10, 72 + 58, 620, 486);
    }
    else
    {
        commentsView.hidden = NO;
        bigPhotoFrame.frame = CGRectMake(10, 58, 620, 486);
    }
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation))
    {
        commentsView.hidden = YES;
        bigPhotoFrame.frame = CGRectMake(72 + 10, 72 + 58, 620, 486);
    }
    else
    {
        commentsView.hidden = NO;
        bigPhotoFrame.frame = CGRectMake(10, 58, 620, 486);
    }
    
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [comments count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 76;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CommentCell";
    CommentCell *cell = (CommentCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil )
    {
        NSArray *topObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        for (id obj in topObjects)
        {
            if ([obj isKindOfClass:[CommentCell class]])
            {
                cell = (CommentCell*)obj;
                break;
            }
        }
    }
    
    // Configure the cell...
    NSDictionary *comment = [comments objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = [comment objectForKey:@"posted_by"];
    cell.timeLabel.text = [comment objectForKey:@"creation_date"];
    cell.descLabel.text = [comment objectForKey:@"content"];
    
    return cell;
}


- (IBAction) textFieldDoneEditing:(id) sender
{
    
    [sender resignFirstResponder];
    
    NSLog(@"Text is :::::: %@", commentTextField.text);
    
    [self fetchFlickrComment];
    
}


- (void)fetchFlickrComment
{
    NSLog(@"Came here too :::::: %@", commentTextField.text);
    NSLog(@"posting to id :::::: %@", commentId);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSArray *photos = [flickr add_comments:whichView :@"add_comment" :commentId :userKey :commentTextField.text];
                       
                       //[self setComments:photos];
                       NSLog(@"comment %@",photos);
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                               [self fetchFlickrPhoto];
                           [HUD hide:YES afterDelay:1];                       });
                   });
    
}

-(void) total_likes: (NSDictionary *)likes
{
    NSLog(@"comments liked ::::::: osaosaosa %@ ", likes);
    
    NSString *commentCount = [[likes objectForKey:@"total_likes"] stringValue];
    
    noLikes.text = commentCount;
}

- (IBAction) likeTapped:(id) sender
{
    
    NSLog(@"just liked :::::: just liked");
    
    [self fetchFlickrLikes];
    
}

- (void)fetchFlickrLikes
{
    NSLog(@"Came here too :::::: %@", commentTextField.text);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSDictionary *photos = [flickr likes:whichView :@"like" :commentId :userKey];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self total_likes:photos];
                           [HUD hide:YES afterDelay:1];
                       });
                   });
    
}


-(void)facebookShare
{
    
    NSLog(@"%@ ::::: selectedcell", videoIndex);
    NSLog(@"%@ ::::: content", [self jsonResponse]);
    
    NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:[videoIndex intValue]];
    
    if ([whichView isEqualToString:@"videos"])
        thumbnail = @"youtube_url";
    else if ([whichView isEqualToString:@"gallery"])
        thumbnail = @"artist";
    
    NSDictionary* params = @{@"name": whichView,
                             @"caption": [flickrPhoto objectForKey:@"title"],
                             @"description": [flickrPhoto objectForKey:thumbnail],
                             @"link": @"http://star-nigeria.com/starmusic/",
                             @"picture":[flickrPhoto objectForKey:bigimage]};
    
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:params
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                  // handle response or error
                                              }];
    
    
}


-(void)twitterShare
{
    NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:[videoIndex intValue]];
    
    if ([whichView isEqualToString:@"videos"])
        thumbnail = @"youtube_url";
    else if ([whichView isEqualToString:@"gallery"])
        thumbnail = @"artist";
    
    TWTweetComposeViewController *twitter = [TWTweetComposeViewController new];
    
    [twitter setInitialText:[flickrPhoto objectForKey:@"title"]];
    [twitter addImage:homePhoto];
    
    NSURL *url = [NSURL URLWithString:[flickrPhoto objectForKey:thumbnail]];
    [twitter addURL:url];
    
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
    NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:[videoIndex intValue]];
    
    if ([whichView isEqualToString:@"videos"])
        thumbnail = @"youtube_url";
    else if ([whichView isEqualToString:@"gallery"])
        thumbnail = @"artist";
    
	MFMailComposeViewController *picker = [MFMailComposeViewController new];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:[flickrPhoto objectForKey:@"title"]];
	
    NSString *removeRN = [[flickrPhoto objectForKey:thumbnail] stringByReplacingOccurrencesOfString: @"\\r\\n" withString:@"\r\n"];
    NSString *bodyContent = [removeRN stringByReplacingOccurrencesOfString: @"&nbsp;" withString:@" "];
    
	[picker setMessageBody:bodyContent isHTML:YES];
    NSData *exportData = UIImageJPEGRepresentation(homePhoto ,1.0);
    [picker addAttachmentData:exportData mimeType:@"image/jpeg" fileName:@"Picture.jpeg"];
    
	[self presentModalViewController:picker animated:YES];
    
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    
	[self dismissViewControllerAnimated:YES completion:nil];
    
}


-(void)launchMailAppOnDevice
{
    NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:[videoIndex intValue]];
    
    if ([whichView isEqualToString:@"videos"])
        thumbnail = @"youtube_url";
    else if ([whichView isEqualToString:@"gallery"])
        thumbnail = @"artist";
    
    NSString *removeRN = [[flickrPhoto objectForKey:thumbnail] stringByReplacingOccurrencesOfString: @"\\r\\n" withString:@"\r\n"];
    NSString *bodyContent = [removeRN stringByReplacingOccurrencesOfString: @"&nbsp;" withString:@" "];
    
	NSString *urlString = [NSString stringWithFormat:@"mailto:osa@gmail.com?subject=%@&messagebody=%@",[flickrPhoto objectForKey:@"title"],bodyContent];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
}


- (void)viewDidUnload
{
    [HUD hide:YES];
    [HUD removeFromSuperview];
    HUD = nil;
    [super viewDidUnload];
}

@end
