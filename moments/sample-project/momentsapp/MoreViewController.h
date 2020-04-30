//
//  MoreViewController.h
//  momentsapp
//
//  Created by Joshua Balogun on 9/27/13.
//
//

#import <UIKit/UIKit.h>
#import "MomentsViewController.h"
#import "VideosViewController.h"

@interface MoreViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) MomentsViewController *momentview;
@property (nonatomic, strong) VideosViewController *videoview;
@property (nonatomic, strong) NSString *selectIndex;
@property (nonatomic, strong) NSArray *listOfItems;
@property (nonatomic, strong) NSString *userKey;
@property (nonatomic, strong) NSString *whichView;

@end
