//
//  MoreListViewController.h
//  momentsapp
//
//  Created by Joshua Balogun on 9/28/13.
//

#import <UIKit/UIKit.h>
#import "PopoverSegment.h"

@interface MoreListViewController : UIViewController<UITableViewDelegate, PopoverSegmentDelegate,UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray *jsonResponse;
@property (nonatomic, strong) NSMutableArray *downloaders;
@property (nonatomic, strong) NSString *whichView;
@property (nonatomic, strong) NSString *catergoryID;
@property (nonatomic, strong) NSString *userKey;
@property (nonatomic, strong) NSString *pageno;
@property (nonatomic, strong) IBOutlet UITableView* tableListView;
@property (nonatomic, retain) NSDictionary* articles;
@property (nonatomic, strong) UIImage *imageSelected;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

-(NSDate*)getDateFromString:(NSString*)dateString;

@end

