//
//  BarsDetailViewController.h
//  momentsapp
//
//  Created by Joshua Balogun on 8/24/13.
//
//

#import <UIKit/UIKit.h>

@class MBProgressHUD;

@interface BarsDetailViewController : UITableViewController

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

@property (nonatomic, strong) IBOutlet UILabel* locationListLabel;

@property (nonatomic, strong) IBOutlet UILabel* locationLabel;

@property (nonatomic, strong) IBOutlet UIView* mapsContainerView;

@property (nonatomic, strong) IBOutlet UIView* listContainerView;

@property (nonatomic, strong) NSArray *jsonResponse;

@property (nonatomic, strong) NSString *whichView;

@property (nonatomic, strong) NSString *locationid;

@property (nonatomic, strong) MBProgressHUD *HUD;

@end
