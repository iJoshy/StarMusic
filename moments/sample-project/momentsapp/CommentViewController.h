//
//  CommentViewController.h
//  momentsapp
//
//  Created by Joshua Balogun on 9/20/13.
//
//

#import <UIKit/UIKit.h>

@class MBProgressHUD;

@interface CommentViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *jsonResponse;
@property (nonatomic, strong) NSString *whichView;
@property (nonatomic, strong) NSString *commentId;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property (nonatomic, strong) NSString *userKey;
@property (nonatomic, strong) NSString *titlelabel;
@property (nonatomic, strong) NSString *noComments;
@property (nonatomic, strong) NSString *noLikes;
@property (nonatomic, strong) IBOutlet UILabel *noComment;
@property (nonatomic, strong) IBOutlet UILabel *noLike;
@property (nonatomic, strong) IBOutlet UITableView *table;
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UITextField *commentTextField;

@end
