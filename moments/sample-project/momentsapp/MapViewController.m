//
//  MasterViewController.m
//  mapper
//
//  Created by Tope on 09/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MBProgressHUD.h"
#import "MapViewController.h"
#import "MapCell.h"
#import "AppDelegate.h"
#import "BarsViewController.h"
#import "Annotation.h"
#import "SimpleFlickrAPI.h"

@implementation MapViewController

@synthesize nameLabel, addrLabel, phoneLabel, detailView;

@synthesize listContainerView, tableViewFrame, HUD;

@synthesize mapView, mapsContainerView, jsonResponse, whichView, locationListLabel;


- (void)didMoveToParentViewController:(UIViewController *)parent
{
    // Position the view within the new parent
    [[parent view] addSubview:[self view]];
    
    CGRect newFrame = CGRectZero;
    
    UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
    
    if (UIInterfaceOrientationIsLandscape(deviceOrientation))
    {
        newFrame = CGRectMake(0, 30, 1024, 748);
    }
    else
    {
        newFrame = CGRectMake(0, 30, 1024, 748);
    }
    
    [[self view] setFrame:newFrame];
    [self.view setBackgroundColor:[UIColor clearColor]];
    
}

- (void)layoutForLandscape
{
    CGRect newFrame = CGRectMake(0, 30, 1024, 748);
    [[self view] setFrame:newFrame];
}

- (void)layoutForPortrait
{
    CGRect newFrame = CGRectMake(0, 30, 1024, 748);
    [[self view] setFrame:newFrame];
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


- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mapsContainerView.backgroundColor = [UIColor clearColor];
    listContainerView.backgroundColor = [UIColor clearColor];
    
    barTableController = [BarsViewController new];
    barTableController.view.backgroundColor = [UIColor clearColor];
    barTableController.tableView.opaque = NO;
    barTableController.tableView.backgroundView = nil;
    
    barNav = [[UINavigationController alloc] initWithRootViewController:barTableController];
    
    barNav.view.frame = listContainerView.bounds;
    [listContainerView addSubview:barNav.view];
    
    [self addChildViewController:barNav];
    [barNav didMoveToParentViewController:self];
    
    //[self selectBar: @"-0.126000": @"51.500000"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAllBars:) name:@"notify_allbars" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendCord2Map:) name:@"notify_mapview" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(slideDownTheFooter) name:@"hide_detail" object:nil];
    
    self.locationManager = [[CLLocationManager alloc] init];
    if ( [CLLocationManager locationServicesEnabled] ) {
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = 1000;
        [self.locationManager startUpdatingLocation];
    }
    
    [self slideDownTheFooter];
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = @"Loading ...";
    HUD.delegate = (id)self;
    [self.view addSubview:HUD];
    
    NSLog(@"This view is for  :: %@",whichView);
    
    [self performSelectorOnMainThread:@selector(fetchFlickrPhotoWithSearchString) withObject:nil waitUntilDone:YES];
    
}



- (void)fetchFlickrPhotoWithSearchString
{
    
    //NSLog(@" Starting- going to fetch images .....");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSArray *photos = [flickr barFinder:@"bars" : @"5"];
                       
                       [self setJsonResponse:photos];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self showNearestBars];
                           [HUD hide:YES afterDelay:1];
                       });
                   });
}


-(void)showNearestBars
{
    
    NSArray *cord = [self jsonResponse];
    
    int barCount = [cord count];
    
    if ( barCount > 0 )
    {
        NSLog(@"barCount ::::: %i",barCount);
        
        NSMutableArray* _stations = [[NSMutableArray alloc] initWithCapacity:barCount];
        
        for (int i=0; i < barCount; i++)
        {
            NSDictionary *eachbar = [cord objectAtIndex:i];
            
            NSString *longi = [eachbar objectForKey:@"longitude"];
            NSString *lati = [eachbar objectForKey:@"latitude"];
            
            float latitude = [lati doubleValue];
            float longitude = [longi doubleValue];
            
            Annotation* model = [[Annotation alloc] initWithLatitude:latitude andLongitude:longitude];
            [_stations addObject:model];
            
        }
        
        [mapView addAnnotations:_stations];
        
    }
    
}


- (void)showAllBars:(NSNotification *) obj
{
    
    NSLog(@"showAllBars:::::");
    
    NSArray *cord = (NSArray *) [obj object];
    
    int barCount = [cord count];
    
    if ( barCount > 0 )
    {
        NSLog(@"barCount ::::: %i",barCount);
        
        NSMutableArray* _stations = [[NSMutableArray alloc] initWithCapacity:barCount];
        
        for (int i=0; i < barCount; i++)
        {
            NSDictionary *eachbar = [cord objectAtIndex:i];
            
            NSString *longi = [eachbar objectForKey:@"longitude"];
            NSString *lati = [eachbar objectForKey:@"latitude"];
            
            float latitude = [lati doubleValue];
            float longitude = [longi doubleValue];
            
            Annotation* model = [[Annotation alloc] initWithLatitude:latitude andLongitude:longitude];
            [_stations addObject:model];
            
            if (i == 0)
            {
                MKCoordinateRegion region;
                
                region.span.latitudeDelta=1.0/9*0.5;
                region.span.longitudeDelta=1.0/9*0.5;
                
                region.center.latitude=latitude;
                region.center.longitude=longitude;
                
                [mapView setRegion:region animated:YES];
                [mapView regionThatFits:region];
            }
                
            
        }
        
        
        [mapView addAnnotations:_stations];
        
        
    }
    
     
}


- (void)sendCord2Map:(NSNotification *) obj
{
    
    NSLog(@"bar delegate called :::::");
    
    [self slideUpTheFooter];
    
     NSArray *cord = (NSArray *) [obj object];
     NSString *longi = [cord objectAtIndex:0];
     NSString *lati = [cord objectAtIndex:1];
     NSString *name = [cord objectAtIndex:2];
     NSString *addr = [cord objectAtIndex:3];
     NSString *phone = [cord objectAtIndex:4];
     
     nameLabel.text = name;
     addrLabel.text = addr;
     phoneLabel.text = phone;
    
    
    MKCoordinateRegion region;
    float latitude = [lati doubleValue];
    float longitude = [longi doubleValue];
    
    Annotation *annotation = [[Annotation alloc] initWithLatitude:latitude andLongitude:longitude];
    
    [mapView addAnnotation:annotation];
    
    region.span.latitudeDelta=1.0/69*0.5;
    region.span.longitudeDelta=1.0/69*0.5;
    
    region.center.latitude=latitude;
    region.center.longitude=longitude;
    
    [mapView setRegion:region animated:YES];
    [mapView regionThatFits:region];
    
}


- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    double miles = 12.0;
    double scalingFactor = ABS( cos(2 * M_PI * newLocation.coordinate.latitude /360.0) );
    NSLog(@"scaling factor ::: %f",scalingFactor);
    MKCoordinateSpan span;
    span.latitudeDelta = miles/219.0;
    span.longitudeDelta = miles/( scalingFactor*219.0 );
    MKCoordinateRegion region;
    region.span = span;
    region.center = newLocation.coordinate;
    [mapView setRegion:region animated:YES];
    mapView.showsUserLocation = YES;
    
}


- (void)slideUpTheFooter
{
    detailView.hidden = NO;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:.5];
    [detailView setFrame:CGRectMake(329, 607, 695, 144)];
    [UIView commitAnimations];

}

- (void)slideDownTheFooter
{
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0];
    [detailView setFrame:CGRectOffset([detailView frame], 0, detailView.frame.size.height)]; 
    [UIView commitAnimations];
    
    detailView.hidden = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
