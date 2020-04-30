//
//  SecondViewController.h
//  momentsapp
//
//  Created by M.A.D on 3/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopoverSegment.h"

@interface MomentsViewController : UIViewController<UITableViewDelegate, PopoverSegmentDelegate,UITableViewDataSource, UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray *jsonResponse;
@property (nonatomic, strong) NSMutableArray *downloaders;
@property (nonatomic, strong) NSString *whichView;
@property (nonatomic, strong) NSString *catergoryID;
@property (nonatomic, strong) NSString *userKey;
@property (nonatomic, strong) NSString *pageno;
@property (nonatomic, strong) IBOutlet UITableView* tableListView;
@property (nonatomic, retain) NSDictionary* articles;
@property (nonatomic, strong) UIImage *imageSelected;
@property (nonatomic, strong) IBOutlet PopoverSegment *ctrl;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

-(NSDate*)getDateFromString:(NSString*)dateString;

@end
