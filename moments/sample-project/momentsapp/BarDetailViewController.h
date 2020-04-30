//
//  BarDetailViewController.h
//  momentsapp
//
//  Created by Joshua Balogun on 9/27/13.
//
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface BarDetailViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

@property (nonatomic, strong) IBOutlet UILabel* locationLabel;

@property (nonatomic, strong) IBOutlet UILabel* distanceLabel;

@property (nonatomic, strong) IBOutlet MKMapView* mapView;

@property (nonatomic, strong) IBOutlet UIView* detailView;

@property (nonatomic, strong) NSDictionary *mapDetails;

@end
