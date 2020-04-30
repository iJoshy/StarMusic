//
//  PopoverDemoController.h
//  ocean
//
//  Created by Tope on 18/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@protocol PopoverDemoControllerDelegate <NSObject>
@required
- (void)selectMenu:(NSString *)menu;
@end

@interface PopoverDemoController : UITableViewController

@property (nonatomic, weak) id <PopoverDemoControllerDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSArray *listOfItems;

@end


