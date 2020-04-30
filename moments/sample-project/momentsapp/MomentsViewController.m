//
//  SecondViewController.m
//  momentsapp
//
//  Created by M.A.D on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "DetailThemeController.h"
#import "MomentsViewController.h"
#import "ImageDownloader.h"
#import "MomentsListCell.h"
#import "AppDelegate.h"
#import "SimpleFlickrAPI.h"
#import "SVPullToRefresh.h"
#import "SVProgressHUD.h"

@implementation MomentsViewController

@synthesize tableListView, articles, whichView, downloaders = _downloaders, jsonResponse, userKey;
@synthesize imageSelected, catergoryID, ctrl, pageno, searchBar;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"landscapeBG.png"]];
    [self.view addSubview:imageView];
    [self.view sendSubviewToBack:imageView];
    
    whichView = @"news";
    
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
    ctrl.titles = [NSArray arrayWithObjects:@"Breaking News", @"Foreign", @"Local", nil];
    ctrl.delegate = self;
    
    //tableview
    [tableListView setBackgroundColor:[UIColor clearColor]];
    [tableListView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableListView setDelegate:self];
    [tableListView setDataSource:self];
    
    
    if([[[UIDevice currentDevice] systemVersion] integerValue] < 7)
    {
        [searchBar setFrame:CGRectMake(0,0,320,44)];
        ctrl.frame = CGRectMake(1.0, 45.0, 320.0f, 30.0f);
        [tableListView setFrame:CGRectMake(0, 78, 320, 395)];
        UIEdgeInsets inset = UIEdgeInsetsMake(-5, 0, 0, 0);
        tableListView.contentInset = inset;
    }
    else
    {
        [searchBar setFrame:CGRectMake(0,65,320,44)];
        ctrl.frame = CGRectMake(1.0, 110.0, 320.0f, 30.0f);
        [tableListView setFrame:CGRectMake(0, 96, 320, 421)];
        UIEdgeInsets inset = UIEdgeInsetsMake(45, 0, 0, 0);
        tableListView.contentInset = inset;
    }
    
    [self.view addSubview:ctrl];
    [self.view addSubview:searchBar];
    
    NSLog(@"This view is for  :: %@",whichView);
    
    catergoryID = @"0";
    jsonResponse = [NSMutableArray array];
    pageno = @"0";
    
    [SVProgressHUD showWithStatus:@"Loading ..."];
    
    [self fetchFlickrPhotoWithSearchString];
    
    __weak MomentsViewController *weakSelf = self;
    
    // setup infinite scrolling
    [self.tableListView addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:@"RefreshContent" object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    userKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"USERKEY"];
    NSLog(@"UserKey  :: %@",userKey);
}

- (void)refresh:(NSNotification *) obj
{
    
    userKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"USERKEY"];
    NSLog(@"UserKey  :: %@",userKey);
    
    NSString *cord = (NSString *) [obj object];
    
    if ([cord isEqualToString:whichView])
    {
        NSLog(@"News refresh");
        catergoryID = @"0";
        jsonResponse = [NSMutableArray array];
        pageno = @"0";
        
        [SVProgressHUD showWithStatus:@"Loading ..."];
        
        [self fetchFlickrPhotoWithSearchString];
        
        __weak MomentsViewController *weakSelf = self;
        
        // setup infinite scrolling
        [self.tableListView addInfiniteScrollingWithActionHandler:^{
            [weakSelf insertRowAtBottom];
        }];
    }
}

- (void)insertRowAtBottom
{
    __weak MomentsViewController *weakSelf = self;
    
    int pageNO = [pageno intValue] + 1;
    pageno = [NSString stringWithFormat:@"%i",pageNO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSArray *photos = [flickr gridloader:whichView:catergoryID:pageno];
                       
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
                                          
                                          [weakSelf.tableListView reloadData];
                                          
                                          [weakSelf.tableListView.infiniteScrollingView stopAnimating];
                                          
                                      });
                   });
    
}


- (void)selectedSegmentAtIndex:(NSInteger)index
{
    pageno = @"0";
    catergoryID = [NSString stringWithFormat:@"%i",index];
    NSLog(@"selected segment is ::: %i",index);
    
    [jsonResponse removeAllObjects];
    
    [SVProgressHUD showWithStatus:@"Loading ..."];
    
    NSLog(@"This view is for  :: %@",whichView);
    [self fetchFlickrPhotoWithSearchString];
}

- (void)fetchFlickrPhotoWithSearchString
{
    
    //NSLog(@" Starting- going to fetch images .....");
    int pageNO = [pageno intValue] + 1;
    pageno = [NSString stringWithFormat:@"%i",pageNO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSArray *photos = [flickr gridloader:whichView:catergoryID:pageno];
                       
                       NSMutableArray *downloaders = [[NSMutableArray alloc] initWithCapacity:[photos count]];
                       for (NSInteger index = 0; index < [photos count]; index++)
                       {
                           ImageDownloader *downloader = [[ImageDownloader alloc] init];
                           [downloaders addObject:downloader];
                       }
                       
                       [self setDownloaders:downloaders];
                       [jsonResponse addObjectsFromArray:photos];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [[self tableListView] reloadData];
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
                               [[self tableListView] reloadData];
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


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
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
    NSLog(@"length of row :: count  :: %i",count);
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"MomentsListCell";
    
    MomentsListCell *cell = (MomentsListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
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


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [SVProgressHUD showWithStatus:@"Loading ..."];
    
    NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:indexPath.row];
    
    ImageDownloaderCompletionBlock completion =^(UIImage *image, NSError *error)
    {
        if (image)
        {
            imageSelected = image;
            [self performSegueWithIdentifier:@"newsDetailSegue" sender:self];
        }
        else
        {
            NSLog(@"%s: Error: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
        }
        
    };
    
    
    NSURL *URL = [NSURL URLWithString:[flickrPhoto objectForKey:@"image_path"]];
    ImageDownloader *downloader = [[ImageDownloader alloc] init];
    [downloader downloadImageAtURL:URL completion:completion];
    
    [[self downloaders] addObject:downloader];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    DetailThemeController* detail = segue.destinationViewController;
    
    NSIndexPath *indexPath = [tableListView indexPathForSelectedRow];
    
    NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:indexPath.row];
    
    Model* model = [Model new];
    [model setTitle:[flickrPhoto objectForKey:@"title"]];
    [model setContent:[flickrPhoto objectForKey:@"content"]];
    [model setDate:[self getDateFromString:[flickrPhoto objectForKey:@"pubDate"]]];
    [model setImage:imageSelected];
    
    [detail setUserKey:userKey];
    [detail setWhichView:whichView];
    [detail setModel:model];
    [detail setImagePath:[flickrPhoto objectForKey:@"image_path"]];
    [detail setNoComments:[[flickrPhoto objectForKey:@"num_comments"] stringValue] ];
    [detail setNoLikes:[[flickrPhoto objectForKey:@"likes"] stringValue] ];
    [detail setCommentID:[flickrPhoto objectForKey:@"id"]];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
