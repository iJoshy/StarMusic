//
//  MoreVideosViewController.h
//  momentsapp
//
//  Created by Joshua Balogun on 9/28/13.
//
//

#import <UIKit/UIKit.h>
#import "AQGridView.h"
#import "PopoverSegment.h"
#import "ASIHTTPRequestDelegate.h"
#import "ASIProgressDelegate.h"
#import "AudioViewController.h"

@interface MoreVideosViewController : UIViewController<AQGridViewDelegate, AQGridViewDataSource, UIActionSheetDelegate, UISearchBarDelegate, PopoverSegmentDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ASIHTTPRequestDelegate, ASIProgressDelegate>
{
    IBOutlet AQGridView * gridView;
    float totalSize;
    float sentSize;
}

@property (nonatomic, strong) AQGridView * gridView;
@property (nonatomic, strong) AudioViewController *audioView;
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
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UITextField *nameField;
@property (nonatomic, strong) NSDictionary *uploadVideoPath;

@end

