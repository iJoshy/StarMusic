//
//  BarsViewController.h
//  momentsapp
//
//  Created by Joshua Balogun on 8/23/13.
//
//

#import <UIKit/UIKit.h>

@class MBProgressHUD;

@interface BarsViewController : UITableViewController

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

@property (nonatomic, strong) IBOutlet UILabel* locationListLabel;

@property (nonatomic, strong) IBOutlet UILabel* locationLabel;

@property (nonatomic, strong) IBOutlet UIView* mapsContainerView;

@property (nonatomic, strong) IBOutlet UIView* listContainerView;

@property (nonatomic, strong) NSArray *jsonResponse;

@property (nonatomic, strong) NSString *whichView;

@property (nonatomic, strong) MBProgressHUD *HUD;

@end
