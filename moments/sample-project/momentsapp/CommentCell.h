//
//  CommentCell.h
//  momentsapp
//
//  Created by M.A.D on 3/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel       *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel       *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel       *descLabel;

@end
