//
//  PhotosViewController.h
//  momentsapp
//
//  Created by M.A.D on 3/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AQGridView.h"
#import "PopoverSegment.h"

@interface PhotosViewController : UIViewController<AQGridViewDelegate, AQGridViewDataSource, UISearchBarDelegate, PopoverSegmentDelegate>
{
    IBOutlet AQGridView * gridView;
}

@property (nonatomic, strong) AQGridView * gridView;
@property (nonatomic, strong) NSMutableArray *jsonResponse;
@property (nonatomic, strong) NSMutableArray *downloaders;
@property (nonatomic, strong) NSString *whichView;
@property (nonatomic, strong) NSString *userKey;
@property (nonatomic, strong) NSString *pageno;
@property (nonatomic, strong) NSString *thumbnail;
@property (nonatomic, strong) NSString *imagePath;
@property (nonatomic, strong) NSString *categoryID;
@property (nonatomic, strong) UIImage *imageSelected;
@property (nonatomic, strong) IBOutlet PopoverSegment *ctrl;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;

@end
