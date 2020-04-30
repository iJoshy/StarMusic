//
//  MasterViewController.h
//  mapper
//
//  Created by Tope on 09/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapModel.h"

@class MBProgressHUD;
@class BarsViewController;

@interface MapViewController : UIViewController <CLLocationManagerDelegate>
{
    BarsViewController *barTableController;
    UINavigationController * barNav;
}

@property (strong, nonatomic) CLLocationManager *locationManager;

@property (nonatomic, strong) IBOutlet UIView* tableViewFrame;

@property (nonatomic, strong) IBOutlet UILabel* locationListLabel;

@property (nonatomic, strong) IBOutlet UILabel* nameLabel;

@property (nonatomic, strong) IBOutlet UILabel* addrLabel;

@property (nonatomic, strong) IBOutlet UILabel* phoneLabel;

@property (nonatomic, strong) IBOutlet UIView* detailView;

@property (nonatomic, strong) IBOutlet MKMapView* mapView;

@property (nonatomic, strong) IBOutlet UIView* mapsContainerView;

@property (nonatomic, strong) IBOutlet UIView* listContainerView;

@property (nonatomic, strong) NSArray *jsonResponse;

@property (nonatomic, strong) NSString *whichView;

@property (nonatomic, strong) NSString *gotLocation;

@property (nonatomic, strong) MBProgressHUD *HUD;

@end