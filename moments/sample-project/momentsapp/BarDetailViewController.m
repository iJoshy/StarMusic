//
//  BarDetailViewController.m
//  momentsapp
//
//  Created by Joshua Balogun on 9/27/13.
//
//

#import "BarDetailViewController.h"
#import "Annotation.h"
#import "AppDelegate.h"


@implementation BarDetailViewController

@synthesize titleLabel, distanceLabel, locationLabel, mapDetails, mapView, detailView;

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

- (void)viewDidLoad
{
    
    if([[[UIDevice currentDevice] systemVersion] integerValue] >= 7)
    {
        [mapView setFrame:CGRectMake(0, 65, 320, 370)];
        [detailView setFrame:CGRectMake(0, 430, 320, 25)];
    }
    
    UIBarButtonItem* backButton = [self createBackBarButtonWithImage:@"back.png"];
    [self.navigationItem setLeftBarButtonItem:backButton];
    
    [locationLabel setTextColor:[[AppDelegate instance].colorSwitcher textColor]];
    
    NSString *slatitude = [mapDetails objectForKey:@"latitude"];
    NSString *slongitude = [mapDetails objectForKey:@"longitude"];
    NSString *name = [mapDetails objectForKey:@"name"];
    NSString *address = [mapDetails objectForKey:@"address"];
    NSString *telephone = [mapDetails objectForKey:@"telephone"];
    
    titleLabel.text = name;
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    labelTitle.text = [name capitalizedString];
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.textColor = [UIColor whiteColor];
    labelTitle.font = [UIFont fontWithName:@"Avenir-Black" size:19];
    [labelTitle sizeToFit];
    self.navigationItem.titleView = labelTitle;
    
    distanceLabel.text = address;
    locationLabel.text = telephone;
    
    MKCoordinateRegion region;
    
    float latitude = [slatitude doubleValue];
    float longitude = [slongitude doubleValue];
    
    Annotation *annotation = [[Annotation alloc] initWithLatitude:latitude andLongitude:longitude];
    
    [mapView addAnnotation:annotation];
    
    region.span.latitudeDelta=1.0/69*0.5;
    region.span.longitudeDelta=1.0/69*0.5;
    
    region.center.latitude=latitude;
    region.center.longitude=longitude;
    
    [mapView setRegion:region animated:YES];
    [mapView regionThatFits:region];
    
    //[mapView setMapType:MKMapTypeStandard];
    [mapView setMapType:MKMapTypeHybrid];
    //[mapView setMapType:MKMapTypeSatellite];
    
    [super viewDidLoad];
    
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
    //[self dismissViewControllerAnimated:YES completion:nil];
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

@end
