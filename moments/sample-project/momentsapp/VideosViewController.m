//
//  VideosViewController.m
//  momentsapp
//
//  Created by M.A.D on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VideosViewController.h"
#import "VideoDetailViewController.h"
#import "GridViewCell.h"
#import "ImageDownloader.h"
#import "AppDelegate.h"
#import "SimpleFlickrAPI.h"
#import "SVPullToRefresh.h"
#import "SVProgressHUD.h"
#import "ASIFormDataRequest.h"

@interface VideosViewController ()

@end

@implementation VideosViewController

@synthesize whichView, downloaders = _downloaders, jsonResponse, userKey, ctrl;
@synthesize thumbnail, imagePath, gridView, pageno, categoryID, imageSelected, searchBar;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"landscapeBG.png"]];
    [self.view addSubview:imageView];
    [self.view sendSubviewToBack:imageView];
    
    whichView = @"videos";
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    labelTitle.text = [whichView capitalizedString];
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.textColor = [UIColor whiteColor];
    labelTitle.font = [UIFont fontWithName:@"Avenir-Black" size:19];
    [labelTitle sizeToFit];
    self.navigationItem.titleView = labelTitle;
    
    //serachbar
    searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    UIImage *backgroundImage = [UIImage imageNamed:@"searchbar"];
    [[UISearchBar appearance] setBackgroundImage:backgroundImage];
    
    //segment controlls
    ctrl = [[PopoverSegment alloc] init];
    ctrl.titles = [NSArray arrayWithObjects:@"New Release", @"Top 20", @"Stars", @"Downloads", nil];
    ctrl.delegate = self;
    
    //tableview
    gridView.backgroundColor = [UIColor clearColor];
	gridView.delegate = self;
	gridView.dataSource = self;
    
    if([[[UIDevice currentDevice] systemVersion] integerValue] < 7)
    {
        [searchBar setFrame:CGRectMake(0,0,320,44)];
        ctrl.frame = CGRectMake(1.0, 45.0, 320.0f, 30.0f);
        [gridView setFrame:CGRectMake(0, 61, 320, 401)];
    }
    else
    {
        [searchBar setFrame:CGRectMake(0,65,320,44)];
        ctrl.frame = CGRectMake(1.0, 110.0, 320.0f, 30.0f);
        [gridView setFrame:CGRectMake(0, 126, 320, 401)];
    }
    
    [self.view addSubview:ctrl];
    [self.view addSubview:searchBar];
    
    NSLog(@"This view is for  :: %@",whichView);
    userKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"USERKEY"];
    NSLog(@"UserKey  :: %@",userKey);
    
    categoryID = @"0";
    jsonResponse = [NSMutableArray array];
    pageno = @"0";
    
    [SVProgressHUD showWithStatus:@"Loading ..."];
    
    [self fetchFlickrPhotoWithSearchString];
    
    __weak VideosViewController *weakSelf = self;
    
    // setup infinite scrolling
    [self.gridView addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:@"RefreshContent" object:nil];
    
}

- (void)refresh:(NSNotification *) obj
{
    
    NSString *cord = (NSString *) [obj object];
    
    if ([cord isEqualToString:whichView])
    {
        NSLog(@"Videos refresh");
        categoryID = @"0";
        jsonResponse = [NSMutableArray array];
        pageno = @"0";
        
        [SVProgressHUD showWithStatus:@"Loading ..."];
        
        [self fetchFlickrPhotoWithSearchString];
        
        __weak VideosViewController *weakSelf = self;
        
        // setup infinite scrolling
        [self.gridView addInfiniteScrollingWithActionHandler:^{
            [weakSelf insertRowAtBottom];
        }];
    }
    
}


- (void)insertRowAtBottom
{
    __weak VideosViewController *weakSelf = self;
    
    int pageNO = [pageno intValue] + 1;
    pageno = [NSString stringWithFormat:@"%i",pageNO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSArray *photos = [flickr gridloader:whichView:categoryID:pageno];
                       
                       NSMutableArray *downloaders = [[NSMutableArray alloc] initWithCapacity:[photos count]];
                       for (NSInteger index = 0; index < [photos count]; index++)
                       {
                           ImageDownloader *downloader = [[ImageDownloader alloc] init];
                           [downloaders addObject:downloader];
                       }
                       
                       [self setDownloaders:downloaders];
                       
                       int64_t delayInSeconds = 2.0;
                       dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                       dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                                      {
                                          [weakSelf.jsonResponse addObjectsFromArray:photos];
                                          
                                          [weakSelf.gridView reloadData];
                                          
                                          [weakSelf.gridView.infiniteScrollingView stopAnimating];
                                          
                                      });
                   });
    
}


- (void)selectedSegmentAtIndex:(NSInteger)index
{
    pageno = @"0";
    
    categoryID = [NSString stringWithFormat:@"%i",index];
    NSLog(@"selected segment is ::: %i",index);
    
    [jsonResponse removeAllObjects];
    
    [SVProgressHUD showWithStatus:@"Loading ..."];
    
    NSLog(@"This view is for  :: %@",whichView);
    [self fetchFlickrPhotoWithSearchString];
}


- (void)fetchFlickrPhotoWithSearchString
{
    
    int pageNO = [pageno intValue] + 1;
    pageno = [NSString stringWithFormat:@"%i",pageNO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSArray *photos = [flickr gridloader:whichView:categoryID:pageno];
                       
                       NSMutableArray *downloaders = [[NSMutableArray alloc] initWithCapacity:[photos count]];
                       for (NSInteger index = 0; index < [photos count]; index++)
                       {
                           ImageDownloader *downloader = [[ImageDownloader alloc] init];
                           [downloaders addObject:downloader];
                       }
                       
                       [self setDownloaders:downloaders];
                       [jsonResponse addObjectsFromArray:photos];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [[self gridView] reloadData];
                           [SVProgressHUD dismiss];
                       });
                   });
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
    
    [aSearchBar resignFirstResponder];
    
    [jsonResponse removeAllObjects];
    
    [SVProgressHUD showWithStatus:@"Loading ..."];
    
    NSLog(@"This view is for  :: %@",whichView);
    [self fetchWithSearchString];
    
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
                               [[self gridView] reloadData];
                           }
                           else
                           {
                               NSLog(@"::: No Search Results");
                               [self nocontent];
                               [self selectedSegmentAtIndex:0];
                           }
                           
                           [SVProgressHUD dismiss];
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


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -
#pragma mark Grid View Data Source


- (NSUInteger) numberOfItemsInGridView: (AQGridView *) aGridView
{
    NSInteger count = [[self jsonResponse] count];
    return count;
}


- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) aGridView
{
    return ( CGSizeMake(70, 90) );
}

- (AQGridViewCell *) gridView: (AQGridView *) aGridView cellForItemAtIndex: (NSUInteger) index
{
    static NSString * CellIdentifier = @"GridViewCell";
    
    GridViewCell * cell = (GridViewCell *)[aGridView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[GridViewCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 59, 59) reuseIdentifier: CellIdentifier];
    }
    
    if ( [whichView isEqualToString:@"video uploads"] )
        [cell setImage:[UIImage imageNamed:@"v-placeholder.png"]];
    else if ( [whichView isEqualToString:@"audio uploads"] )
        [cell setImage:[UIImage imageNamed:@"Play_Button.png"]];
    
    
    if ( [whichView isEqualToString:@"videos"] && [categoryID isEqualToString:@"3"] )
    {
        cell = [[GridViewCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 70, 90) reuseIdentifier: CellIdentifier];
        
        UIButton *dButton = [[UIButton alloc] initWithFrame:CGRectMake(54, 69, 21, 21)];
        [dButton setBackgroundImage:[UIImage imageNamed:@"download.png"] forState:UIControlStateNormal];
        [dButton addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
        [dButton setTag:index];
        [cell.contentView addSubview:dButton];
        
        [cell setImage:[UIImage imageNamed:@"v-placeholder.png"]];
    }
    
    
    ImageDownloaderCompletionBlock completion =^(UIImage *image, NSError *error)
    {
        if (image)
        {
            [cell setImage:image];
            imageSelected = image;
            cell.contentMode = UIViewContentModeScaleAspectFit;
        }
        else
        {
            [cell setImage:[UIImage imageNamed:@"nopic.png"]];
            
        }
    };
    
    NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:index];
    NSURL *URL = [NSURL URLWithString:[flickrPhoto objectForKey:@"youtube_thumbnail"]];
    ImageDownloader *downloader = [[ImageDownloader alloc] init];
    [downloader downloadImageAtURL:URL completion:completion];
    
    [cell setLabel:[flickrPhoto objectForKey:@"title"]];


    
    return cell;
    
}


- (NSDate*)getDateFromString:(NSString*)dateString
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
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
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
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


- (void) gridView: (AQGridView *) gridView didSelectItemAtIndex: (NSUInteger) index
{
    NSLog(@"didSelectItemAtIndex");
    [SVProgressHUD showWithStatus:@"Loading ..."];
    
    [self performSegueWithIdentifier:@"videosDetailSegue" sender:self];
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
   
    VideoDetailViewController* detail = segue.destinationViewController;
    
    int index = [gridView indexOfSelectedItem];
    
    NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:index];
    
    Model* model = [Model new];
    [model setTitle:[flickrPhoto objectForKey:@"title"]];
    [model setContent:[flickrPhoto objectForKey:@"youtube_url"]];
    [model setDate:[self getDateFromString:[flickrPhoto objectForKey:@"pubDate"]]];
    [model setImage:imageSelected];
    
    [detail setUserKey:userKey];
    [detail setWhichView:whichView];
    [detail setModel:model];
    [detail setImagePath:[flickrPhoto objectForKey:@"youtube_image"]];
    [detail setNoComments:[[flickrPhoto objectForKey:@"num_comments"] stringValue]];
    [detail setNoLikes:[[flickrPhoto objectForKey:@"likes"] stringValue] ];
    [detail setCommentID:[flickrPhoto objectForKey:@"id"]];
    
}


-(void)download:(id)sender
{
    NSLog(@"downloading :::::");
    
    UIButton *button = (UIButton *)sender;
    NSString *index = [NSString stringWithFormat:@"%d",button.tag];
    [[NSUserDefaults standardUserDefaults] setObject:index forKey:@"INDEX"];
    
    UIActionSheet *actionSheetShare = [[UIActionSheet alloc] initWithTitle:nil
                                                                  delegate:self
                                                         cancelButtonTitle:nil
                                                    destructiveButtonTitle:NSLocalizedString(@"Download Video", @"")
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
    
    [SVProgressHUD showWithStatus:@"Downloading ..."];
    
    // myProgressTask uses the HUD instance to update progress
    [self myDownloadTask];
    
}

-(void)myDownloadTask
{
    NSString* index = [[NSUserDefaults standardUserDefaults] stringForKey:@"INDEX"];
    NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:[index intValue]];
    NSString *urlString = [flickrPhoto objectForKey:@"video_url"];
    NSString *title = [flickrPhoto objectForKey:@"title"];
    
    NSArray* foo = [urlString componentsSeparatedByString: @"/"];
    NSString* filename = [foo lastObject];
    
    //NSLog(@"Downloading begins ::: %@",filename);
    
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *appSupportDir = [fm URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask];
    NSURL* dirPath = [[appSupportDir objectAtIndex:0] URLByAppendingPathComponent:whichView];
    
    NSError*  theError = nil; //error setting
    if (![fm createDirectoryAtURL:dirPath withIntermediateDirectories:YES attributes:nil error:&theError])
    {
        NSLog(@"not created");
    }
    
    sentSize = 0;
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *file = [NSString stringWithFormat:@"%@/%@/%@Ω%@", documentsDirectory, whichView, title, filename];
    
    //NSLog(@"Downloading begins ::: %@",file);
    
    [request setDownloadDestinationPath:file];
    [request setDelegate:self];
    [request startAsynchronous];
    
}

- (void)request:(ASIHTTPRequest *)request didSendBytes:(long long)bytes
{
    float settoprogress;
    
    sentSize+=bytes;
    settoprogress=(sentSize/totalSize);
    NSLog(@"%f",settoprogress);
}

- (void) requestFinished:(ASIHTTPRequest *)request
{
    //NSString *responseString = [request responseString];
    NSLog(@"Response %d : %@", request.responseStatusCode, [request responseString]);
    
    //NSData *responseData = [request responseData];
    [SVProgressHUD dismiss];
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setDelegate:self];
    [alert setTitle:@"Star Music"];
    [alert setMessage:@"File Successfully Uploaded."];
    [alert addButtonWithTitle:@"OK"];
    [alert setTag:93];
    [alert show];
    
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


@end

