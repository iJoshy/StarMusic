//
//  MomentsListCell.h
//  momentsapp
//
//  Created by Joshua Balogun on 9/3/13.
//
//

#import <UIKit/UIKit.h>

@interface MomentsListCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* titleLabel;

@property (nonatomic, strong) IBOutlet UILabel* excerptLabel;

@property (nonatomic, strong) IBOutlet UILabel* dayLabel;

@property (nonatomic, strong) IBOutlet UILabel* dateLabel;

@property (nonatomic, strong) IBOutlet UIImageView* bgImageView;

@end
