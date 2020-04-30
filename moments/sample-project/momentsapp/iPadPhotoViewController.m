//
//  PhotosViewController.m
//  momentsapp
//
//  Created by M.A.D on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "iPadPhotoViewController.h"
#import "iPadGridViewCell.h"
#import "SimpleFlickrAPI.h"
#import "ImageDownloader.h"
#import "MasterViewController.h"
#import "HomeiPadViewController.h"
#import "KxMenu.h"
#import "ASIFormDataRequest.h"

@implementation iPadPhotoViewController

@synthesize HUD = _HUD, refresh, catergoryID, share, uploadVideoPath, nameField, searchBar;
@synthesize jsonResponse = _jsonResponse, videoIndex = _videoIndex, celltitle = _celltitle;
@synthesize downloaders = _downloaders, image = _image, userKey, ctrl, pageno;
@synthesize whichView = _whichView, thumbnail = _thumbnail, toolbar, loadJsonResponse;
@synthesize imageSelected = _imageSelected, detailSegue = _detailSegue, audioView, audioPopOver;


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
        
        ctrl.frame = CGRectMake(300.0f, 5.0f, 420.0f, 30.0f);
        [toolbar addSubview:ctrl];
    }
    else
    {
        newFrame = CGRectMake(0, 30, 748, 1024);
        
        toolbar.frame=CGRectMake(0, 19, 768, 44);
        
        ctrl.frame = CGRectMake(140.0f, 5.0f, 420.0f, 30.0f);
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
    
    ctrl.frame = CGRectMake(300.0f, 5.0f, 420.0f, 30.0f);
    [toolbar addSubview:ctrl];
    
}

- (void)layoutForPortrait
{
    CGRect newFrame = CGRectMake(0, 30, 748, 1024);
    
    [[self view] setFrame:newFrame];
    toolbar.frame=CGRectMake(0, 19, 768, 44);
    
    ctrl.frame = CGRectMake(140.0f, 5.0f, 420.0f, 30.0f);
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
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
                       
    _gridView.backgroundColor = [UIColor clearColor];
    
	_gridView.delegate = self;
	_gridView.dataSource = self;
    
    [toolbar setBackgroundImage:[UIImage imageNamed:@"tab-bar.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    userKey = [[NSUserDefaults standardUserDefaults] stringForKey:@"USERKEY"];
    NSLog(@"UserKey  :: %@",userKey);
    
    NSMutableArray *toolbarItems = [self.toolbar.items mutableCopy];
    catergoryID = @"0";
    _detailSegue = @"detailViewSegue";
    
    
    if ([_whichView isEqualToString:@"videos"])
    {
        ctrl = [[PopoverSegment alloc] init];
        ctrl.titles = [NSArray arrayWithObjects:@"New Release", @"Top 20 Hits", @"Star Videos", @"Free Downloads", nil];
        ctrl.delegate = self;
        
        [toolbarItems removeObjectAtIndex:3];
        [self.toolbar setItems:toolbarItems animated:NO];
        
        _thumbnail = @"youtube_thumbnail";
        _image = @"youtube_image";
        _celltitle = @"title";
        
    }
    else if ([_whichView isEqualToString:@"gallery"])
    {
        ctrl = [[PopoverSegment alloc] init];
        ctrl.titles = [NSArray arrayWithObjects:@"New Release", @"Top Favorites", @"Star Gallery", nil];
        ctrl.delegate = self;
        
        [toolbarItems removeObjectAtIndex:3];
        [self.toolbar setItems:toolbarItems animated:NO];
        
        _thumbnail = @"thumb_path";
        _image = @"image_path";
        _celltitle = @"title";
        
    }
    else if ([_whichView isEqualToString:@"adverts"])
    {
        [toolbarItems removeObjectAtIndex:3];
        [self.toolbar setItems:toolbarItems animated:NO];
        
        _thumbnail = @"youtube_thumbnail";
        _image = @"youtube_image";
        _celltitle = @"title";
        
    }
    else if ([_whichView isEqualToString:@"my downloads"])
    {
        ctrl = [[PopoverSegment alloc] init];
        ctrl.titles = [NSArray arrayWithObjects:@"Videos", @"Images", nil];
        ctrl.delegate = self;
        
        [toolbarItems removeObjectAtIndex:3];
        [self.toolbar setItems:toolbarItems animated:NO];
        
        [self fetchDownloadedContent];
    }
    else if ([_whichView isEqualToString:@"video uploads"])
    {
        [share setAction:@selector(uploadvideo)];
        [KxMenu setTitleFont:[UIFont systemFontOfSize:14]];
        _celltitle = @"title";
    }
    else if ([_whichView isEqualToString:@"audio uploads"])
    {
        [share setAction:@selector(uploadaudio)];
        [KxMenu setTitleFont:[UIFont systemFontOfSize:14]];
        _celltitle = @"title";
    }
    else if ([_whichView isEqualToString:@"audios"])
    {
        [toolbarItems removeObjectAtIndex:3];
        [self.toolbar setItems:toolbarItems animated:NO];
        
        _celltitle = @"title";
    }
    
    
    if (![_whichView isEqualToString:@"my downloads"])
    {
    
        if (_jsonResponse == nil || _jsonResponse.count == 0)
        {
            pageno = @"1";
            
            _HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            _HUD.mode = MBProgressHUDModeIndeterminate;
            _HUD.labelText = @"Loading ...";
            _HUD.delegate = self;
            [self.view addSubview:_HUD];
            
            [self performSelectorOnMainThread:@selector(fetchFlickrPhotoWithSearchString) withObject:nil waitUntilDone:YES];
            
        }
        else
        {
            NSLog(@"_jsonResponse has things");
            [self.gridView reloadData];
        }
        
        NSLog(@"This view is for  :: %@",_whichView);
        NSLog(@"pageno :::::: %@",pageno);
        NSLog(@"Gallery Main Page ::::: viewDidLoad :::: %i", [self.jsonResponse count]);
        
    }
    
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
    
    [KxMenu showMenuInView:self.view fromRect:CGRectMake(60, 5, 100, 50) menuItems:menuItems];
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
    
    [KxMenu showMenuInView:self.view fromRect:CGRectMake(60, 5, 100, 50) menuItems:menuItems];
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
        
        UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:self.imagePickerController];
        [popover presentPopoverFromRect:CGRectMake(60, 5, 100, 50) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        self.popOver = popover;
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
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setDelegate:self];
    [alert setTitle:@"Give a title to this recording\n\n"];
    [alert setMessage:@" "];
    [alert addButtonWithTitle:@"OK"];
    [alert addButtonWithTitle:@"Cancel"];
    
    nameField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 31.0)];
    [nameField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
    [nameField setBorderStyle:UITextBorderStyleRoundedRect];
    [nameField setBackgroundColor:[UIColor whiteColor]];
    [nameField setTextAlignment:NSTextAlignmentLeft];
    [nameField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [nameField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [nameField setKeyboardAppearance:UIKeyboardAppearanceAlert];
    [nameField becomeFirstResponder];
    
    [alert setTag:88];
    [alert addSubview:nameField];
    [alert show];
    
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //NSLog(@"button pressed -> %i",buttonIndex);
    
    if (buttonIndex == 0)
    {
        //NSLog(@"password -> %@",password);
        if (alertView.tag == 88 )
        {
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
    else if (buttonIndex == 1)
    {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
    
}

-(void)startUploading
{
    
    [_HUD show:YES];
	
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
    _HUD.progress=settoprogress;
    NSLog(@"%f",settoprogress);
}

- (void) requestFinished:(ASIHTTPRequest *)request
{
    //NSString *responseString = [request responseString];
    NSLog(@"Response %d : %@", request.responseStatusCode, [request responseString]);
    
    //NSData *responseData = [request responseData];
    [_HUD hide:YES afterDelay:1];
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setDelegate:self];
    [alert setTitle:@"Star Music"];
    [alert setMessage:@"File transfer Successfully."];
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
    [_HUD hide:YES afterDelay:1];
    
    NSError *error = [request error];
    NSLog(@"%@", error);
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    [alert setDelegate:self];
    [alert setTitle:@"Error"];
    [alert setMessage:@"Could not process at this time. check internet settings or try again later."];
    [alert addButtonWithTitle:@"OK"];
    [alert setTag:93];
    [alert show];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft || interfaceOrientation==UIInterfaceOrientationLandscapeRight)
    {
        toolbar.frame=CGRectMake(0, 19, 1024, 44);
        ctrl.frame = CGRectMake(300.0f, 5.0f, 420.0f, 30.0f);
        [toolbar addSubview:ctrl];
        
    }
    else
    {
        toolbar.frame=CGRectMake(0, 19, 768, 44);
        ctrl.frame = CGRectMake(140.0f, 5.0f, 420.0f, 30.0f);
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

- (IBAction)btnPressed:(id)sender
{
    
    [sender setBackgroundImage:[UIImage imageNamed:@"pink_high_new.png"]
                      forState:UIControlStateNormal];
}


- (void)selectedSegmentAtIndex:(NSInteger)index
{
    catergoryID = [NSString stringWithFormat:@"%i",index];
    NSLog(@"selected segment is ::: %i",index);
    
    if ([_whichView isEqualToString:@"my downloads"])
    {
        [self fetchDownloadedContent];
    }
    else
    {
        [_HUD show:YES];
        
        [self performSelectorOnMainThread:@selector(fetchFlickrPhotoWithSearchString) withObject:nil waitUntilDone:YES];
    }
    
}

- (void)fetchFlickrPhotoWithSearchString
{
    
    //NSLog(@" Starting- going to fetch images .....");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
    {
        SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
        
        NSArray *photos = [flickr gridloader:_whichView:catergoryID:pageno];
        
        //NSLog(@"fetchFlickrPhotoWithSearchString  :::: %@", photos );
        
        NSMutableArray *downloaders = [[NSMutableArray alloc] initWithCapacity:[photos count]];
        for (NSInteger index = 0; index < [photos count]; index++)
        {
            ImageDownloader *downloader = [[ImageDownloader alloc] init];     
            [downloaders addObject:downloader];
        }
        
        [self setDownloaders:downloaders]; 
        [self setJsonResponse:photos];
        //NSLog(@"First Content : %@",_jsonResponse);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([_jsonResponse count] > 0)
            {
                [[self gridView] reloadData];
            }
            else
            {
                NSLog(@"::: No Search Results");
                [self nocontent];
            }
            
            [_HUD hide:YES afterDelay:1];
        });
    });
}

-(void)nocontent
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Star Music" message:@"The requested content is unavailable at this time." delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles: nil];
    
    [alert show];
}

- (IBAction) refreshTapped:(id) sender
{
    
    [self.gridView reloadData];
    
}

#pragma mark Grid View Data Source

- (NSUInteger) numberOfItemsInGridView: (AQGridView *) aGridView
{
    
    int rowNo = [self.jsonResponse count];
    NSLog(@"Gallery view :::  numberOfItemsInGridView ::: %i", rowNo);
    
    if (rowNo == 0)
        return 0;
    
    if( rowNo % 20 == 0 )
    {
        return rowNo + 1;
    }
    else
    {
        return rowNo;
    }
    
}


- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) aGridView
{
    return ( CGSizeMake(150, 180) );
}


- (AQGridViewCell *) gridView: (AQGridView *) aGridView cellForItemAtIndex: (NSUInteger) index
{
    static NSString * CellIdentifier = @"iPadGridViewCell";
    
    iPadGridViewCell * cell = (iPadGridViewCell *)[aGridView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if( index != [self.jsonResponse count] )
    {
        if (cell == nil)
        {
            cell = [[iPadGridViewCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 139, 139) reuseIdentifier: CellIdentifier];
        }
        
        
        if ( [_whichView isEqualToString:@"audio uploads"] || [_whichView isEqualToString:@"audios"] )
            [cell setImage:[UIImage imageNamed:@"Play_Button.png"]];
        else if ( [_whichView isEqualToString:@"video uploads"] )
            [cell setImage:[UIImage imageNamed:@"v-placeholder.png"]];
            
        
        if ( [_whichView isEqualToString:@"videos"] && [catergoryID isEqualToString:@"3"] )
        {
            cell = [[iPadGridViewCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 165, 165) reuseIdentifier: CellIdentifier];
            
            UIButton *dButton = [[UIButton alloc] initWithFrame:CGRectMake(102, 138, 32, 32)];
            [dButton setBackgroundImage:[UIImage imageNamed:@"download.png"] forState:UIControlStateNormal];
            [dButton addTarget:self action:@selector(download:) forControlEvents:UIControlEventTouchUpInside];
            [dButton  setTag:index];
            [cell.contentView addSubview:dButton];
            
            [cell setImage:[UIImage imageNamed:@"v-placeholder.png"]];
        }
        
        if ( [_whichView isEqualToString:@"my downloads"] )
        {
            
            NSString *urlString = [[self jsonResponse] objectAtIndex:index];
            NSArray* foo = [urlString componentsSeparatedByString: @"Ω"];
            [cell setLabel:[foo objectAtIndex:0]];
            
            if ([catergoryID  isEqualToString:@"0"])
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
                //NSLog(@"%s:Image Loading Error: %@ for image %i", __PRETTY_FUNCTION__, [error localizedDescription], index);
            }
        };
        
        NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:index];
        NSURL *URL = [NSURL URLWithString:[flickrPhoto objectForKey:_thumbnail]];
        ImageDownloader *downloader = [[ImageDownloader alloc] init];
        [downloader downloadImageAtURL:URL completion:completion];
        [cell setLabel:[flickrPhoto objectForKey:_celltitle]];
    
    }
    else
    {
        
        if (cell == nil)
        {
            cell = [[iPadGridViewCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 139, 139) reuseIdentifier: CellIdentifier];
        }
        
        [cell setImage:nil];
        [cell setLabel:@""];
        
        [cell setImage:[UIImage imageNamed:@"loadmore.png"]];
        cell.contentMode = UIViewContentModeScaleAspectFit;
        
    }
    
    return cell;
    
}


- (void) gridView: (AQGridView *) gridView didSelectItemAtIndex: (NSUInteger) index
{
    _videoIndex = [NSString stringWithFormat:@"%i", index];
    //NSLog(@"didSelectItemAtIndex ::: index ::: %@",_videoIndex);
    
    if ( index == [self.jsonResponse count] )
    {
        NSLog(@"Normal cell selected with == 20 results, Add more");
        //  Add more
        [_HUD show:YES];
        [self performSelectorOnMainThread:@selector(loadMore) withObject:nil waitUntilDone:YES];
    }
    else
    {
        NSLog(@"Normal cell selected with < 20 results");
        //  Add here your normal didSelectRowAtIndexPath code
        [self didSelectItemAtIndex:index];
    }

}


- (void)loadMore
{
    
    //NSLog(@" Starting- going to fetch images .....");
    loadJsonResponse = [[NSMutableArray alloc] init];
    [loadJsonResponse addObjectsFromArray:self.jsonResponse];

    int pageNO = [pageno intValue] + 1;
    pageno = [NSString stringWithFormat:@"%i",pageNO];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSArray *photos = [flickr gridloader:_whichView:catergoryID:pageno];
                       
                       NSMutableArray *downloaders = [[NSMutableArray alloc] initWithCapacity:[photos count]];
                       for (NSInteger index = 0; index < [photos count]; index++)
                       {
                           ImageDownloader *downloader = [[ImageDownloader alloc] init];
                           [downloaders addObject:downloader];
                       }
                       
                       [self setDownloaders:downloaders];
                       [loadJsonResponse addObjectsFromArray:photos];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self leaveHere];
                           [_HUD hide:YES afterDelay:1];
                       });
                   });
}

-(void) leaveHere
{
    NSArray *newContent = [loadJsonResponse copy];
     NSLog(@"New Content : %@",loadJsonResponse);
    
    NSArray *cordObj = [NSArray arrayWithObjects: _whichView, pageno, newContent, nil];

    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadGridview" object:cordObj];
    
}

-(void) didSelectItemAtIndex: (NSUInteger) index
{
    
    [_HUD show:YES];
    
    if ([_whichView isEqualToString:@"gallery"] || [_whichView isEqualToString:@"videos"])
    {
        
        ImageDownloaderCompletionBlock completion =^(UIImage *image, NSError *error)
        {
            if (image)
            {
                _imageSelected = image;
                
                [self performSegueWithIdentifier:_detailSegue sender:self];
                
                [_HUD hide:YES afterDelay:1];
            }
            else
            {
                NSLog(@"%s: Error: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
            }
        };
        
        
        NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:index];
        NSURL *URL = [NSURL URLWithString:[flickrPhoto objectForKey:_image]];
        ImageDownloader *downloader = [[ImageDownloader alloc] init];
        [downloader downloadImageAtURL:URL completion:completion];
        
        [[self downloaders] addObject:downloader];
        
    }
    else
    {
        
        [self performSegueWithIdentifier:_detailSegue sender:self];
        
    }
    
}


-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:_detailSegue])
    {
        HomeiPadViewController *accVC = [segue destinationViewController];
        accVC.homePhoto = _imageSelected;
        accVC.userKey = userKey;
        accVC.whichView = _whichView;
        accVC.catergoryID = catergoryID;
        accVC.thumbnail = _thumbnail;
        accVC.jsonResponse = self.jsonResponse;
        accVC.bigimage = _image;
        accVC.videoIndex = _videoIndex;
    }
    
    
    [_HUD hide:YES];
    [_HUD removeFromSuperview];
    _HUD = nil;
    
}

-(void) record:(id)sender
{
    NSLog(@"::::: greate ::::record");
    
    if (audioView == nil)
    {
        //Create the ColorPickerViewController.
        audioView = [AudioViewController new];
        audioView.userkey = userKey;
        
        //Set this VC as the delegate.
        //_menuPicker.delegate = self;
    }
    
    if (audioPopOver == nil)
    {
        //The color picker popover is not showing. Show it.
        UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:audioView];
        navCtrl.navigationBar.topItem.title = @"Audio Console";
        
        audioPopOver = [[UIPopoverController alloc] initWithContentViewController:navCtrl];
        [audioPopOver presentPopoverFromBarButtonItem:share permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        [audioPopOver setPopoverContentSize:CGSizeMake(320,320)];
        
    }
    else
    {
        //The color picker popover is showing. Hide it.
        [audioPopOver dismissPopoverAnimated:YES];
        audioPopOver = nil;
    }
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)aSearchBar
{
    
    /*
     If the user finishes editing text in the search bar by, for example: tapping away rather than selecting from the recents list, then just dismiss the popover, but only if its confirm UIActionSheet is not open (UIActionSheets can take away first responder from the search bar when first opened).
     */
    
    [aSearchBar resignFirstResponder];
    
    [loadJsonResponse removeAllObjects];
    
    [_HUD show:YES];
    
    [self performSelectorOnMainThread:@selector(fetchWithSearchString) withObject:nil waitUntilDone:YES];
    
}

- (void)fetchWithSearchString
{
    //NSLog(@" Starting- going to fetch images .....");
    NSString *searchString = searchBar.text;
    searchBar.text = @"";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSArray *photos = [flickr comments:_whichView: @"search" :searchString];
                       
                       NSMutableArray *downloaders = [[NSMutableArray alloc] initWithCapacity:[photos count]];
                       for (NSInteger index = 0; index < [photos count]; index++)
                       {
                           ImageDownloader *downloader = [[ImageDownloader alloc] init];
                           [downloaders addObject:downloader];
                       }
                       
                       [self setDownloaders:downloaders];
                       [loadJsonResponse addObjectsFromArray:photos];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           if ([loadJsonResponse count] > 0)
                           {
                               [[self gridView] reloadData];
                           }
                           else
                           {
                               NSLog(@"::: No Search Results");
                               [self nocontent];
                               [self selectedSegmentAtIndex:0];
                           }
                           
                           [_HUD hide:YES afterDelay:1];
                       });
                   });
    
}

-(void)download:(id)sender
{

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
    
    [_HUD show:YES];
    
    // myProgressTask uses the HUD instance to update progress
    [self performSelectorOnMainThread:@selector(myDownloadTask) withObject:nil waitUntilDone:YES];
    
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
    NSURL* dirPath = [[appSupportDir objectAtIndex:0] URLByAppendingPathComponent:_whichView];
    
    NSError*  theError = nil; //error setting
    if (![fm createDirectoryAtURL:dirPath withIntermediateDirectories:YES attributes:nil error:&theError])
    {
        NSLog(@"not created");
    }
    
    sentSize = 0;
    
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *file = [NSString stringWithFormat:@"%@/%@/%@Ω%@", documentsDirectory, _whichView, title, filename];
    
    //NSLog(@"Downloading begins ::: %@",file);
    
    [request setDownloadDestinationPath:file];
    [request setDelegate:self];
    [request startAsynchronous];
    
}

-(void)fetchDownloadedContent
{
    [self setJsonResponse:[self ls]];
    
    [[self gridView] reloadData];
}

- (NSArray *)ls
{
    NSString* category = @"";
    if ([catergoryID isEqualToString:@"0"])
        category = @"videos";
    else
        category = @"gallery";
    
    NSError *err;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [NSString stringWithFormat:@"%@/%@",[paths objectAtIndex:0], category];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&err];
    
    NSLog(@"documentsDirectory ::: %@", documentsDirectory);
    NSLog(@"directoryContent ::: %@", directoryContent);
    
    return directoryContent;
}

- (void)viewDidUnload
{
    
    [self setGridView:nil];
    [self setHUD:nil];

    [super viewDidUnload];
}

@end
