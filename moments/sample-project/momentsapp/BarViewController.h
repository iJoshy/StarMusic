//
//  BarViewController.h
//  momentsapp
//
//  Created by Joshua Balogun on 9/25/13.
//
//

#import <UIKit/UIKit.h>

@interface BarViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *jsonResponse;
@property (nonatomic, strong) NSMutableArray *downloaders;
@property (nonatomic, strong) NSString *whichView;
@property (nonatomic, strong) NSString *catergoryID;
@property (nonatomic, strong) NSString *userKey;
@property (nonatomic, strong) NSString *pageno;
@property (nonatomic, retain) NSDictionary* articles;
@property (nonatomic, strong) UIImage *imageSelected;
@property (nonatomic, strong) IBOutlet UITableView *tableview;

@end
