//
//  BarListViewController.h
//  momentsapp
//
//  Created by Joshua Balogun on 9/25/13.
//
//

#import <UIKit/UIKit.h>

@interface BarListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, retain) NSArray* models;
@property (nonatomic, strong) NSArray *jsonResponse;
@property (nonatomic, strong) NSString *locationid;
@property (nonatomic, strong) NSString *whichView;
@property (nonatomic, strong) IBOutlet UITableView *tableview;

@end
