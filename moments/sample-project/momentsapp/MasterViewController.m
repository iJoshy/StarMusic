//
//  MasterViewController.m
//  mapper
//
//  Created by Tope on 09/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MasterViewController.h"
#import "MasterCell.h"
#import "AppDelegate.h"
#import "SimpleFlickrAPI.h"
#import "ImageDownloader.h"
#import "MBProgressHUD.h"
#import "commentViewController.h"
#import "KxMenu.h"
#import "SVPullToRefresh.h"


@implementation MasterViewController

@synthesize titleLabel, articleImageView, articleWebView, dateLabel, scrollView, shadowView, sideGradientView, ctrl, refresh, catergoryID, segmentedItems;

@synthesize masterTableView, toolbar, share, userKey, toggleComment, HUD, commentView, commentId, newcomment, searchBar, selectedCell, title2Label;

@synthesize newsView, listView, jsonResponse, downloaders = _downloaders, whichView, commentButton, commentTextField, selectedImage, pageno, commentPopOver, commentTableView;


- (void)didMoveToParentViewController:(UIViewController *)parent
{
    // Position the view within the new parent
    [[parent view] addSubview:[self view]];
    
    CGRect newFrame = CGRectZero;
    
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    
    if (UIInterfaceOrientationIsLandscape(deviceOrientation))
    {
        newFrame = CGRectMake(0, 30, 1024, 748);
        
        toolbar.frame=CGRectMake(0, 19, 1024, 44);
        
        ctrl.frame = CGRectMake(340.0f, 5.0f, 340.0f, 30.0f);
        [toolbar addSubview:ctrl];
    }
    else
    {
        newFrame = CGRectMake(0, 30, 1024, 748);
        
        toolbar.frame=CGRectMake(0, 19, 768, 44);
        
        ctrl.frame = CGRectMake(180.0f, 5.0f, 340.0f, 30.0f);
        [toolbar addSubview:ctrl];
    }
    
    [[self view] setFrame:newFrame];
    [self.view setBackgroundColor:[UIColor clearColor]];
    
}

- (void)layoutForLandscape
{
    CGRect newFrame = CGRectMake(0, 30, 1024, 748);
    
    [[self view] setFrame:newFrame];
    toolbar.frame=CGRectMake(0, 19, 1024, 44);
    
    ctrl.frame = CGRectMake(340.0f, 5.0f, 340.0f, 30.0f);
    [toolbar addSubview:ctrl];
    
}

- (void)layoutForPortrait
{
    CGRect newFrame = CGRectMake(0, 30, 1024, 748);
    
    [[self view] setFrame:newFrame];
    toolbar.frame=CGRectMake(0, 19, 768, 44);
    
    ctrl.frame = CGRectMake(180.0f, 5.0f, 340.0f, 30.0f);
    [toolbar addSubview:ctrl];
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))
    {
        [self layoutForLandscape];
    }
    else
    {
        [self layoutForPortrait];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    if (UIInterfaceOrientationIsLandscape(deviceOrientation))
    {
        [self layoutForLandscape];
    }
    else
    {
        [self layoutForPortrait];
    }
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = @"Loading ...";
    HUD.delegate = (id)self;
    [self.view addSubview:HUD];
    
    //NSLog(@"This view is for  :: %@",whichView);
    
    [self performSelectorOnMainThread:@selector(fetchFlickrPhotoWithSearchString) withObject:nil waitUntilDone:YES];
    
}


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    UIImage *navBarImage = [[[AppDelegate instance] colorSwitcher] processImageWithName:@"ipad-menubar-left.png"];
    
    [self.navigationController.navigationBar setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsDefault];
    
    masterTableView.delegate = self;
    masterTableView.dataSource = self;
    masterTableView.backgroundColor = [UIColor clearColor];
    masterTableView.separatorColor = [UIColor clearColor];
    
    newsView.backgroundColor = [UIColor clearColor];
    listView.backgroundColor = [UIColor clearColor];
    
    [toolbar setBackgroundImage:[UIImage imageNamed:@"tab-bar.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    [articleWebView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"ipad-background.png"]]];
    
    
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    
    if ([whichView isEqualToString:@"news"])
    {
        ctrl = [PopoverSegment new];
        ctrl.titles = [NSArray arrayWithObjects:@"Breaking News", @"Foreign", @"Local", nil];
        ctrl.delegate = self;
        
        share.width = 0.0;
        
        UIImage *configImage = [UIImage imageNamed:@"share.png"];
        UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0,0, configImage.size.width, configImage                     .size.height)];
        [btn setBackgroundImage:configImage forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(shareStuff) forControlEvents:UIControlEventTouchUpInside];
        share.customView = btn;
        
        [KxMenu setTitleFont:[UIFont systemFontOfSize:14]];
        
    }
    else
    {
        [toolbarItems removeObjectAtIndex:3];
        [self.toolbar setItems:toolbarItems animated:NO];
    }
    
    
    catergoryID = @"0";
    jsonResponse = [NSMutableArray array];
    pageno = @"0";
    
    
    __weak MasterViewController *weakSelf = self;
    
    // setup infinite scrolling
    [self.masterTableView addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:@"RefreshContent" object:nil];
    
}

- (void)insertRowAtBottom
{
    __weak MasterViewController *weakSelf = self;
    
    int pageNO = [pageno intValue] + 1;
    pageno = [NSString stringWithFormat:@"%i",pageNO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [SimpleFlickrAPI new];
                       
                       NSArray *photos = [flickr gridloader:whichView:catergoryID:pageno];
                       
                       NSMutableArray *downloaders = [[NSMutableArray alloc] initWithCapacity:[photos count]];
                       for (NSInteger index = 0; index < [photos count]; index++)
                       {
                           ImageDownloader *downloader = [ImageDownloader new];
                           [downloaders addObject:downloader];
                       }
                       
                       [self setDownloaders:downloaders];
                       
                       int64_t delayInSeconds = 2.0;
                       dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                       dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                                      {
                                          [weakSelf.jsonResponse addObjectsFromArray:photos];
                                          
                                          [weakSelf.masterTableView reloadData];
                                          
                                          [weakSelf.masterTableView.infiniteScrollingView stopAnimating];
                                          
                                      });
                   });
    
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
    
    [KxMenu showMenuInView:self.view fromRect:CGRectMake(60, 5, 100, 50) menuItems:menuItems];
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


#pragma mark - Flickr

- (void)selectedSegmentAtIndex:(NSInteger)index
{
    catergoryID = [NSString stringWithFormat:@"%i",index];
    NSLog(@"selected segment is ::: %i",index);
    
    [jsonResponse removeAllObjects];
    pageno = @"0";
    
    [HUD show:YES];
    
    //NSLog(@"This view is for  :: %@",whichView);
    
    [self performSelectorOnMainThread:@selector(fetchFlickrPhotoWithSearchString) withObject:nil waitUntilDone:YES];
}

- (void)fetchFlickrPhotoWithSearchString
{
    
    //NSLog(@" Starting- going to fetch images .....");
    int pageNO = [pageno intValue] + 1;
    pageno = [NSString stringWithFormat:@"%i",pageNO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [SimpleFlickrAPI new];
                       
                       NSArray *photos = [flickr gridloader:whichView:catergoryID:pageno];
                       
                       NSMutableArray *downloaders = [[NSMutableArray alloc] initWithCapacity:[photos count]];
                       for (NSInteger index = 0; index < [photos count]; index++)
                       {
                           ImageDownloader *downloader = [ImageDownloader new];
                           [downloaders addObject:downloader];
                       }
                       
                       [self setDownloaders:downloaders];
                       [jsonResponse addObjectsFromArray:photos];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           if ([jsonResponse count] > 0)
                           {
                               [[self masterTableView] reloadData];
                               [self loadLatestNews];
                           }
                           else
                           {
                               NSLog(@"::: No Search Results");
                               [self nocontent];
                           }
                           
                           [HUD hide:YES afterDelay:1];
                           
                       });
                   });
}

-(void)nocontent
{
    if(![whichView isEqualToString:@"my downloads"])
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Star Music" message:@"The requested content is unavailable at this time." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
        
        [alert show];
    }
}

- (void)loadLatestNews
{
    
    NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:0];
    
    selectedCell = @"0";
    commentId = [flickrPhoto objectForKey:@"id"];
    [titleLabel setText:[flickrPhoto objectForKey:@"title"]];
    [title2Label setText:[flickrPhoto objectForKey:@"title"]];
    [articleWebView loadHTMLString:[self addCSSTo:[flickrPhoto objectForKey:@"content"]] baseURL:nil];
    
    ImageDownloaderCompletionBlock completion =^(UIImage *image, NSError *error)
    {
        if (image)
        {
            [articleImageView setImage:image];
            articleImageView.contentMode = UIViewContentModeScaleAspectFit;
            selectedImage = image;
        }
        else
        {
            NSLog(@"%s: Error: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
        }
    };
    
    
    NSURL *URL = [NSURL URLWithString:[flickrPhoto objectForKey:@"image_path"]];
    ImageDownloader *downloader = [ImageDownloader new];
    [downloader downloadImageAtURL:URL completion:completion];
    
    [[self downloaders] addObject:downloader];
    
    NSDateFormatter *format = [NSDateFormatter new];
    [format setDateFormat:@"EEE, dd MMMM yyyy"];
    [dateLabel setText:[format stringFromDate:[self getDateFromString:[flickrPhoto objectForKey:@"pubDate"]]]];
    
    
    articleWebView.delegate = self;
    
    shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowView.layer.shadowOffset = CGSizeMake(0, 0);
    shadowView.layer.shadowOpacity = 0.4;
    shadowView.layer.shadowRadius = 4;
    shadowView.layer.masksToBounds = NO;
    
    [articleImageView setClipsToBounds:YES];
    
}

- (IBAction) refreshTapped:(id) sender
{
    __weak MasterViewController *weakSelf = self;
    
    [weakSelf.masterTableView reloadData];
}

- (void)refresh:(NSNotification *) obj
{
    
    userKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"USERKEY"];
    NSLog(@"UserKey  :: %@",userKey);
    
    
    NSString *cord = (NSString *) [obj object];
    
    if ([cord isEqualToString:whichView])
    {
        NSLog(@"%@ refresh", whichView);
        
        catergoryID = @"0";
        [jsonResponse removeAllObjects];
        pageno = @"0";
        
        [HUD show:YES];
        
        //NSLog(@"This view is for  :: %@",whichView);
        
        [self performSelectorOnMainThread:@selector(fetchFlickrPhotoWithSearchString) withObject:nil waitUntilDone:YES];
        
    }
    
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft || interfaceOrientation==UIInterfaceOrientationLandscapeRight)
    {
        toolbar.frame = CGRectMake(0, 19, 1024, 44);
        ctrl.frame = CGRectMake(340.0f, 5.0f, 340.0f, 30.0f);
        [toolbar addSubview:ctrl];
        
    }
    else
    {
        toolbar.frame = CGRectMake(0, 19, 768, 44);
        ctrl.frame = CGRectMake(180.0f, 5.0f, 340.0f, 30.0f);
        [toolbar addSubview:ctrl];
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

#pragma mark - Table view data source


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 81;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [[self jsonResponse] count];
    
    return count;
}

/*
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView* headerView = [[[NSBundle mainBundle] loadNibNamed:@"ListHeaderView" owner:nil options:nil] objectAtIndex:0];
    
    UILabel* newsTitleLabel = (UILabel*)[headerView viewWithTag:1];
    
    [newsTitleLabel setText:[segmentedItems objectAtIndex:[catergoryID intValue]]];
    
    return headerView;
}
*/

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"MasterCell";
    
    MasterCell *cell = (MasterCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:indexPath.row];
    
    
    [cell.titleLabel setText:[flickrPhoto objectForKey:@"title"]];
    
    NSString *content = [flickrPhoto objectForKey:@"content"];
    NSString *removeRN = [content stringByReplacingOccurrencesOfString: @"\\r\\n" withString:@""];
    NSString *bodyContent = [removeRN stringByReplacingOccurrencesOfString: @"&nbsp;" withString:@" "];
    
    [cell.excerptLabel setText:bodyContent];
    [cell.dateLabel setText:[self getDay:[flickrPhoto objectForKey:@"pubDate"]]];
    [cell.dayLabel setText:[self getDayString:[flickrPhoto objectForKey:@"pubDate"]]];
    
    UIImage* img = [[[AppDelegate instance] colorSwitcher] processImageWithName:@"list-item.png"];
    [cell.bgImageView setImage:img];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
    
}


- (NSDate*)getDateFromString:(NSString*)dateString
{
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en"]];
    
    return [df dateFromString:dateString];
}

- (NSString*)getDay:(NSString *)sentDate
{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *components = [cal components:(NSDayCalendarUnit) fromDate:[self getDateFromString:sentDate]];
    
    [components setCalendar:cal];
    
    int day = [components day];
    
    NSString *dayString = [NSString stringWithFormat:@"%d", day];
    
    return [self padStringWithZero:dayString];
}


- (NSString*)getDayString:(NSString *)sentDate
{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    
    NSDateComponents *components = [cal components:(NSWeekdayCalendarUnit) fromDate:[self getDateFromString:sentDate]];
    [components setCalendar:cal];
    
    int day = [components weekday];
    
    NSDateFormatter *df = [NSDateFormatter new];
    
    NSString *dayName = [[df shortStandaloneWeekdaySymbols] objectAtIndex:(day-1)];
    
    dayName = [dayName uppercaseString];
    
    return dayName;
}

- (NSString *)padStringWithZero:(NSString *)str
{
    if([str length] == 1)
    {
        str = [NSString stringWithFormat:@"0%@", str];
    }
    
    return str;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [HUD show:YES];
    
    NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:indexPath.row];
    commentId = [flickrPhoto objectForKey:@"id"];
    [titleLabel setText:[flickrPhoto objectForKey:@"title"]];
    [title2Label setText:[flickrPhoto objectForKey:@"title"]];
    selectedCell = [NSString stringWithFormat:@"%i",indexPath.row];
    
    //NSLog(@"%@ ::::: selectedcell", selectedCell);
    
    NSString *content = [flickrPhoto objectForKey:@"content"];
    NSString *removeRN = [content stringByReplacingOccurrencesOfString: @"\\r\\n" withString:@"\n"];
    NSString *bodyContent = [removeRN stringByReplacingOccurrencesOfString: @"&nbsp;" withString:@" "];
    
    [articleWebView loadHTMLString:[self addCSSTo:bodyContent] baseURL:nil];
    
    
    ImageDownloaderCompletionBlock completion =^(UIImage *image, NSError *error)
    {
        if (image)
        {
            [articleImageView setImage:image];
            articleImageView.contentMode = UIViewContentModeScaleAspectFit;
            selectedImage = image;
            
            [HUD hide:YES afterDelay:1];
        }
        else
        {
            NSLog(@"%s: Error: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
        }
        
    };
    
    
    NSURL *URL = [NSURL URLWithString:[flickrPhoto objectForKey:@"image_path"]];
    ImageDownloader *downloader = [ImageDownloader new];
    [downloader downloadImageAtURL:URL completion:completion];
    
    [[self downloaders] addObject:downloader];
    
    
    
    NSDateFormatter *format = [NSDateFormatter new];
    [format setDateFormat:@"EEE, dd MMMM yyyy"];
    [dateLabel setText:[format stringFromDate:[self getDateFromString:[flickrPhoto objectForKey:@"pubDate"]]]];
    
    
    articleWebView.delegate = self;
    
    shadowView.layer.shadowColor = [UIColor blackColor].CGColor;
    shadowView.layer.shadowOffset = CGSizeMake(0, 0);
    shadowView.layer.shadowOpacity = 0.4;
    shadowView.layer.shadowRadius = 4;
    shadowView.layer.masksToBounds = NO;
    
    [articleImageView setClipsToBounds:YES];
    
}

- (NSString*)addCSSTo:(NSString*)content
{
    NSString *removeRN = [content stringByReplacingOccurrencesOfString: @"\\r\\n" withString:@"\r\n"];
    NSString *bodyContent = [removeRN stringByReplacingOccurrencesOfString: @"&nbsp;" withString:@" "];
    
    NSString* webContent = [NSString stringWithFormat:@"<html> \n"
                            "<head> \n"
                            "<style type=\"text/css\"> \n"
                            "body {text-shadow: 0px 1px 0px #fff; color:#4a4a4a; font-family: \"%@\"; font-size: %@;}\n"
                            "</style> \n"
                            "</head> \n"
                            "<body>%@</body> \n"
                            "</html>", @"helvetica", [NSNumber numberWithInt:16], bodyContent
                            ];
    return webContent;
}

-(IBAction)commentPressed:(id)sender
{
    
    [self performSegueWithIdentifier:@"commentSegue" sender:self];
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:[selectedCell intValue]];
    
    if ([[segue identifier] isEqualToString:@"commentSegue"])
    {
        
        CommentViewController *commentVC = [segue destinationViewController];
        commentVC.userKey = userKey;
        commentVC.whichView = whichView;
        commentVC.commentId = commentId;
        commentVC.noComments = [[flickrPhoto objectForKey:@"num_comments"] stringValue];
        commentVC.noLikes = [[flickrPhoto objectForKey:@"likes"] stringValue];
        commentVC.titlelabel = [flickrPhoto objectForKey:@"title"];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
    
    [aSearchBar resignFirstResponder];
    
    [jsonResponse removeAllObjects];
    
    [HUD show:YES];
    
    [self performSelectorOnMainThread:@selector(fetchWithSearchString) withObject:nil waitUntilDone:YES];
    
}

- (void)fetchWithSearchString
{
    //NSLog(@" Starting- going to fetch images .....");
    NSString *searchString = searchBar.text;
    searchBar.text = @"";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [SimpleFlickrAPI new];
                       
                       NSArray *photos = [flickr comments:whichView: @"search" :searchString];
                       
                       NSMutableArray *downloaders = [[NSMutableArray alloc] initWithCapacity:[photos count]];
                       for (NSInteger index = 0; index < [photos count]; index++)
                       {
                           ImageDownloader *downloader = [ImageDownloader new];
                           [downloaders addObject:downloader];
                       }
                       
                       [self setDownloaders:downloaders];
                       [jsonResponse addObjectsFromArray:photos];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           if ([jsonResponse count] > 0)
                           {
                               [[self masterTableView] reloadData];
                               [self loadLatestNews];
                           }
                           else
                           {
                               NSLog(@"::: No Search Results");
                               [self nocontent];
                               [self selectedSegmentAtIndex:0];
                           }
                           
                           [HUD hide:YES afterDelay:1];
                       });
                   });
    
}

-(void)facebookShare
{
    
    //NSLog(@"%@ ::::: selectedcell", selectedCell);
    
    NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:[selectedCell intValue]];
    
    NSString *removeRN = [[flickrPhoto objectForKey:@"content"] stringByReplacingOccurrencesOfString: @"\\r\\n" withString:@"\r\n"];
    NSString *bodyContent = [removeRN stringByReplacingOccurrencesOfString: @"&nbsp;" withString:@" "];
    
    NSDictionary* params = @{@"name": [flickrPhoto objectForKey:@"category"],
                             @"caption": [flickrPhoto objectForKey:@"title"],
                             @"description": bodyContent,
                             @"link": @"http://star-nigeria.com/starmusic/",
                             @"picture":[flickrPhoto objectForKey:@"thumb_path"]};
    
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:params
                                              handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
                                                  // handle response or error
                                              }];
    
    
}


-(void)twitterShare
{
    NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:[selectedCell intValue]];
    
    TWTweetComposeViewController *twitter = [TWTweetComposeViewController new];
    
    [twitter setInitialText:[flickrPhoto objectForKey:@"title"]];
    [twitter addImage:selectedImage];
    
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
    NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:[selectedCell intValue]];
    
	MFMailComposeViewController *picker = [MFMailComposeViewController new];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:[flickrPhoto objectForKey:@"title"]];
	
    NSString *removeRN = [[flickrPhoto objectForKey:@"content"] stringByReplacingOccurrencesOfString: @"\\r\\n" withString:@"\r\n"];
    NSString *bodyContent = [removeRN stringByReplacingOccurrencesOfString: @"&nbsp;" withString:@" "];
    
	[picker setMessageBody:bodyContent isHTML:NO];
	 NSData *exportData = UIImageJPEGRepresentation(selectedImage ,1.0);
    [picker addAttachmentData:exportData mimeType:@"image/jpeg" fileName:@"Picture.jpeg"];
    
	[self presentModalViewController:picker animated:YES];
    
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    
	[self dismissViewControllerAnimated:YES completion:nil];
    
}


-(void)launchMailAppOnDevice
{
    NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:[selectedCell intValue]];
    
    NSString *removeRN = [[flickrPhoto objectForKey:@"content"] stringByReplacingOccurrencesOfString: @"\\r\\n" withString:@"\r\n"];
    NSString *bodyContent = [removeRN stringByReplacingOccurrencesOfString: @"&nbsp;" withString:@" "];
    
	NSString *urlString = [NSString stringWithFormat:@"mailto:osa@gmail.com?subject=%@&messagebody=%@",[flickrPhoto objectForKey:@"title"],bodyContent];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


@end
