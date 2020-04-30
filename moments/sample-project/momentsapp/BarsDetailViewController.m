//
//  BarsDetailViewController.m
//  momentsapp
//
//  Created by Joshua Balogun on 8/24/13.
//
//

#import <QuartzCore/QuartzCore.h>
#import "MapViewController.h"
#import "BarsDetailViewController.h"
#import "AppDelegate.h"
#import "SimpleFlickrAPI.h"
#import "MBProgressHUD.h"

@implementation BarsDetailViewController

@synthesize titleLabel, locationLabel, HUD, locationid, tableView;
@synthesize jsonResponse, whichView, locationListLabel;



#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"back-location.png"] forBarMetrics:UIBarMetricsDefault];
    
    tableView = [[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.opaque = NO;
    tableView.backgroundView = nil;
    tableView.rowHeight = 50;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.autoresizesSubviews = YES;
    
    self.view = tableView;
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    HUD.labelText = @"Loading ...";
    [self.view addSubview:HUD];
    
    //NSLog(@"This view is for  :: %@",whichView);
    //NSLog(@"This view is for ID :: %@",locationid);
    
    [HUD showWhileExecuting:@selector(fetchFlickrPhotoWithSearchString) onTarget:self withObject:nil animated:YES];

    self.navigationItem.backBarButtonItem.title = @"Back";
    self.navigationItem.title = whichView;
    
}


#pragma mark - Flickr

- (void)fetchFlickrPhotoWithSearchString
{
    
    //NSLog(@" Starting- going to fetch images .....");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSArray *photos = [flickr barFinder:@"bars" :locationid];
                       
                       [self setJsonResponse:photos];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           //[[self masterTableView] reloadData];
                           [self.tableView reloadData];
                           [HUD removeFromSuperview];
                           HUD = nil;
                           [[NSNotificationCenter defaultCenter] postNotificationName:@"notify_allbars" object:photos];
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
    cell.textLabel.text =  [flickrPhoto objectForKey:@"name"];
    
    return cell;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [[self jsonResponse] count];
    return count;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:indexPath.row];
    NSString *slatitude = [flickrPhoto objectForKey:@"latitude"];
    NSString *slongitude = [flickrPhoto objectForKey:@"longitude"];
    NSString *name = [flickrPhoto objectForKey:@"name"];
    NSString *address = [flickrPhoto objectForKey:@"address"];
    NSString *telephone = [flickrPhoto objectForKey:@"telephone"];
    
    NSArray* cordObj = [NSArray arrayWithObjects: slongitude, slatitude, name, address, telephone, nil];
    
    //NSLog(@"Latitude :::::%@",slatitude);
    //NSLog(@"Longitude :::::%@",slongitude);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"notify_mapview" object:cordObj];
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"hide_detail" object:nil];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
}

@end
