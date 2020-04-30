//
//  MoreVideosViewController.m
//  momentsapp
//
//  Created by Joshua Balogun on 9/28/13.
//
//

#import "MoreVideosViewController.h"
#import "VideoDetailViewController.h"
#import "GridViewCell.h"
#import "ImageDownloader.h"
#import "AppDelegate.h"
#import "SimpleFlickrAPI.h"
#import "SVPullToRefresh.h"
#import "SVProgressHUD.h"
#import "KxMenu.h"
#import "ASIFormDataRequest.h"

@interface MoreVideosViewController ()

@end

@implementation MoreVideosViewController

@synthesize whichView, downloaders = _downloaders, jsonResponse, userKey, ctrl;
@synthesize thumbnail, imagePath, gridView, pageno, categoryID, imageSelected, searchBar;
@synthesize nameField, uploadVideoPath, audioView;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"landscapeBG.png"]];
    [self.view addSubview:imageView];
    [self.view sendSubviewToBack:imageView];

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
    
    gridView.backgroundColor = [UIColor clearColor];
	gridView.delegate = self;
	gridView.dataSource = self;
    
    NSLog(@"This view is for  :: %@",whichView);
    userKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"USERKEY"];
    NSLog(@"UserKey  :: %@",userKey);
    
    categoryID = @"0";
    jsonResponse = [NSMutableArray array];
    pageno = @"0";
    
    if([[[UIDevice currentDevice] systemVersion] integerValue] < 7)
    {
        //[searchBar setFrame:CGRectMake(0,0,320,44)];
        [gridView setFrame:CGRectMake(0, 0, 320, 421)];
        
        if ([whichView isEqualToString:@"my downloads"])
        {
            [gridView setFrame:CGRectMake(0, 35, 320, 421)];
            
            ctrl = [[PopoverSegment alloc] init];
            ctrl.titles = [NSArray arrayWithObjects:@"Videos", @"Images", nil];
            ctrl.delegate = self;
            
            ctrl.frame = CGRectMake(0.0, 0, 320.0f, 30.0f);
            [self.view addSubview:ctrl];
            
            [self fetchDownloadedContent];
        }
        
    }
    else
    {
        //[searchBar setFrame:CGRectMake(0,65,320,44)];
        [gridView setFrame:CGRectMake(0, 65, 320, 445)];
        
        if ([whichView isEqualToString:@"my downloads"])
        {
            [gridView setFrame:CGRectMake(0, 100, 320, 445)];
            
            ctrl = [[PopoverSegment alloc] init];
            ctrl.titles = [NSArray arrayWithObjects:@"Videos", @"Images", nil];
            ctrl.delegate = self;
            
            ctrl.frame = CGRectMake(0.0, 65.0, 320.0f, 30.0f);
            [self.view addSubview:ctrl];
            
            [self fetchDownloadedContent];
        }
        
    }
    
    [self.view addSubview:ctrl];
    
    UIBarButtonItem* backButton = [self createBackBarButtonWithImage:@"back.png"];
    [self.navigationItem setLeftBarButtonItem:backButton];
    
    
    UIImage *menuButtonImage = [UIImage imageNamed:@"photos_icon"];// set your image Name here
    UIButton *btnShare = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnShare setImage:menuButtonImage forState:UIControlStateNormal];
    btnShare.frame = CGRectMake(0, 0, menuButtonImage.size.width, menuButtonImage.size.height);
    UIBarButtonItem *menuBarButton = [[UIBarButtonItem alloc] initWithCustomView:btnShare];
    
    
    if ([whichView isEqualToString:@"video uploads"])
    {
        [btnShare addTarget:self action:@selector(uploadvideo) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.rightBarButtonItem = menuBarButton;
    }
    else if ([whichView isEqualToString:@"audio uploads"])
    {
        [btnShare addTarget:self action:@selector(uploadaudio) forControlEvents:UIControlEventTouchUpInside];
        
        self.navigationItem.rightBarButtonItem = menuBarButton;
    }
    
    [KxMenu setTitleFont:[UIFont systemFontOfSize:14]];
    
    
    
    if (![whichView isEqualToString:@"my downloads"])
    {
    
        [SVProgressHUD showWithStatus:@"Loading ..."];
        
        [self fetchFlickrPhotoWithSearchString];
    
    }
    
    __weak MoreVideosViewController *weakSelf = self;
    
    // setup infinite scrolling
    [self.gridView addInfiniteScrollingWithActionHandler:^{
        [weakSelf insertRowAtBottom];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refresh:) name:@"RefreshContent" object:nil];
    
}

-(void) uploadvideo
{
    NSLog(@"uploading  ::::");
    NSArray *menuItems =
    @[
      
      [KxMenuItem menuItem:@"   Capture   "
                     image:nil
                    target:self
                    action:@selector(pushMenuItem:)],
      
      [KxMenuItem menuItem:@"   Choose Existing   "
                     image:nil
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


-(void) uploadaudio
{
    NSLog(@"uploading  ::::");
    
     NSArray *menuItems =
     @[
     
     [KxMenuItem menuItem:@"  Capture   "
     image:nil
     target:self
     action:@selector(record:)],
     
     [KxMenuItem menuItem:@"   Choose Existing   "
     image:nil
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
    
    UIImagePickerControllerSourceType sourceType;
    
    KxMenuItem *textfield= (KxMenuItem*)sender;
    if([textfield.title isEqualToString:@"  Record Video   "] )
    {
        NSLog(@"camera");
        sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else if([textfield.title isEqualToString:@"   Choose Existing   "] )
    {
        NSLog(@"gallery");
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePicker.sourceType = sourceType;
    imagePicker.mediaTypes = [NSArray arrayWithObject:@"public.movie"];
    imagePicker.delegate = self;
    
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
        self.imagePickerController = imagePicker;
        
        [self presentViewController:self.imagePickerController animated:YES completion:nil];
    }
    else
    {
        self.imagePickerController = imagePicker;
        imagePicker.allowsEditing = YES;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }
    
}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    uploadVideoPath = info;
    
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
    
    [SVProgressHUD showWithStatus:@"Uploading ..."];
	
	// myProgressTask uses the HUD instance to update progress
    [self performSelectorOnMainThread:@selector(myProgressTask) withObject:nil waitUntilDone:YES];
}

- (void)myProgressTask
{
	sentSize = 0;
    
    NSURL *serverURL = [NSURL URLWithString:@"http://208.109.186.98/starcmssite/api/videos/upload"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:serverURL];
    
    NSURL *urlvideo = [uploadVideoPath objectForKey:UIImagePickerControllerMediaURL];
    NSString *videoPath = [urlvideo path];
    NSLog(@"urlString=%@",videoPath);
    NSData *vidoeData = [NSData dataWithContentsOfURL:urlvideo];
    totalSize= (float)vidoeData.length;
    
    [request setRequestMethod:@"POST"];
    [request setPostValue:userKey forKey:@"key"];
    [request setPostValue:nameField.text forKey:@"title"];
    [request addData:vidoeData withFileName:@"mp4" andContentType:(@"video/*") forKey:@"video"];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshContent" object:whichView];
    
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


- (void)refresh:(NSNotification *) obj
{
    
    NSString *cord = (NSString *) [obj object];
    
    if ([cord isEqualToString:whichView])
    {
        NSLog(@"%@ refresh", whichView);
        categoryID = @"0";
        jsonResponse = [NSMutableArray array];
        pageno = @"0";
        
        [SVProgressHUD showWithStatus:@"Loading ..."];
        
        [self fetchFlickrPhotoWithSearchString];
        
        __weak MoreVideosViewController *weakSelf = self;
        
        // setup infinite scrolling
        [self.gridView addInfiniteScrollingWithActionHandler:^{
            [weakSelf insertRowAtBottom];
        }];
    }
    
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


- (void)insertRowAtBottom
{
    __weak MoreVideosViewController *weakSelf = self;
    
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
    
    if ([whichView isEqualToString:@"my downloads"])
    {
        [self fetchDownloadedContent];
    }
    else
    {
        [SVProgressHUD showWithStatus:@"Loading ..."];
        
        NSLog(@"This view is for  :: %@",whichView);
        [self fetchFlickrPhotoWithSearchString];
    }

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
    
    
    if ( [whichView isEqualToString:@"audio uploads"] || [whichView isEqualToString:@"audios"] )
        [cell setImage:[UIImage imageNamed:@"Play_Button.png"]];
    else if ( [whichView isEqualToString:@"video uploads"] )
        [cell setImage:[UIImage imageNamed:@"v-placeholder.png"]];
    
    
    if ( [whichView isEqualToString:@"my downloads"] )
    {
        
        NSString *urlString = [[self jsonResponse] objectAtIndex:index];
        NSArray* foo = [urlString componentsSeparatedByString: @"Ω"];
        [cell setLabel:[foo objectAtIndex:0]];
        
        if ([categoryID  isEqualToString:@"0"])
        {
            [cell setImage:[UIImage imageNamed:@"v-placeholder.png"]];
        }
        else
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *path = [NSString stringWithFormat:@"%@/gallery/%@",[paths objectAtIndex:0],urlString];
            cell.image = [UIImage imageWithContentsOfFile:path];
            cell.contentMode = UIViewContentModeScaleAspectFit;
        }
        
        return cell;
    }
    
    ImageDownloaderCompletionBlock completion =^(UIImage *image, NSError *error)
    {
        if (image)
        {
            [cell setImage:image];
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
    
    [self performSegueWithIdentifier:@"moreVideoSegue" sender:self];
    
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    VideoDetailViewController* detail = segue.destinationViewController;
    
    int index = [gridView indexOfSelectedItem];
    
    NSString *url = @"";
    if ([whichView isEqualToString:@"adverts"])
    {
        url = @"youtube_url";
    }
    
    if ([whichView isEqualToString:@"video uploads"] || [whichView isEqualToString:@"audio uploads"] || [whichView isEqualToString:@"audios"])
    {
        url = @"url";
    }
    
    if ([whichView isEqualToString:@"my downloads"])
    {
        Model* model = [Model new];
        [model setContent:[jsonResponse objectAtIndex:0]];
        
        [detail setUserKey:userKey];
        [detail setWhichView:whichView];
        [detail setModel:model];
        [detail setCategoryID:categoryID];
    }
    else
    {
        
        NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:index];
        
        Model* model = [Model new];
        [model setTitle:[flickrPhoto objectForKey:@"title"]];
        [model setContent:[flickrPhoto objectForKey:url]];
        [model setDate:[self getDateFromString:[flickrPhoto objectForKey:@"pubDate"]]];
        [model setImage:imageSelected];
        
        [detail setUserKey:userKey];
        [detail setWhichView:whichView];
        [detail setModel:model];
        [detail setNoComments:[[flickrPhoto objectForKey:@"num_comments"] stringValue] ];
        [detail setNoLikes:[[flickrPhoto objectForKey:@"likes"] stringValue] ];
        [detail setCommentID:[flickrPhoto objectForKey:@"id"]];
    
    }
    
    
}


-(void) record:(id)sender
{
    NSLog(@"::::: greate ::::record");
    
    if (audioView == nil)
    {
        //Create the ColorPickerViewController.
        audioView = [AudioViewController new];
        audioView.userkey = userKey;
        
        [self.navigationController pushViewController:audioView animated:NO];
    }
    else
    {
        audioView.userkey = userKey;
        
        [self.navigationController pushViewController:audioView animated:NO];
    }
    
}


-(void)fetchDownloadedContent
{
    
    [jsonResponse addObjectsFromArray:[self ls]];
    
    [[self gridView] reloadData];
}

- (NSArray *)ls
{
    NSString* category = @"";
    if ([categoryID isEqualToString:@"0"])
        category = @"videos";
    else
        category = @"gallery";
    
    NSError *err;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@/%@",[paths objectAtIndex:0], category];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&err];
    
    NSLog(@"%@", documentsDirectory);
    NSLog(@"%@", directoryContent);
    
    return directoryContent;
}


@end


