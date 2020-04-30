//
//  BarsViewController.m
//  moments
//
//  Created by Tope on 09/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "BarsViewController.h"
#import "BarsDetailViewController.h"
#import "AppDelegate.h"
#import "SimpleFlickrAPI.h"
#import "MBProgressHUD.h"

@implementation BarsViewController

@synthesize titleLabel, locationLabel, HUD, tableView;
@synthesize jsonResponse, whichView, locationListLabel;



#pragma mark - View lifecycle

- (void)viewDidLoad
{

    [super viewDidLoad];
    
    tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStyleGrouped];
    tableView.rowHeight = 50;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.autoresizesSubviews = YES;
    
    self.view = tableView;
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = @"Loading ...";
    HUD.delegate = (id)self;
    [self.view addSubview:HUD];
    
    NSLog(@"This view is for  :: %@",whichView);
    
    [self performSelectorOnMainThread:@selector(fetchFlickrPhotoWithSearchString) withObject:nil waitUntilDone:YES];
    
    NSLog(@"This view is for  :: %@",whichView);
   
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"refresh-location.png"] forBarMetrics:UIBarMetricsDefault];
    
}


#pragma mark - Flickr

- (void)fetchFlickrPhotoWithSearchString
{
    
    //NSLog(@" Starting- going to fetch images .....");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSArray *photos = [flickr photosWithSearchString:@"locations"];
                       
                       [self setJsonResponse:photos];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           //[[self masterTableView] reloadData];
                           [self.tableView reloadData];
                           [HUD hide:YES afterDelay:1];
                       });
                   });
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString* cellIdentifier = @"cellIdentifier";
    UITableViewCell *cell = [atableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if(cell == nil)
    {
        cell = (UITableViewCell*) [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:indexPath.row];
    cell.textLabel.text =  [flickrPhoto objectForKey:@"location"];
    
    return cell;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 53;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [[self jsonResponse] count];
    return count;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped :::::");
    
    BarsDetailViewController *nextList = [BarsDetailViewController new];
    
    NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:indexPath.row];
    nextList.whichView =  [flickrPhoto objectForKey:@"location"];
    nextList.locationid =  [flickrPhoto objectForKey:@"id"];
     
    [self.navigationController pushViewController:nextList animated:YES];
    
}



@end

