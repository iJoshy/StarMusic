//
//  MomentsListCell.m
//  momentsapp
//
//  Created by Joshua Balogun on 9/3/13.
//
//

#import "MomentsListCell.h"

@implementation MomentsListCell

@synthesize titleLabel, excerptLabel, dayLabel, dateLabel, bgImageView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
