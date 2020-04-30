//
//  iPadGridViewCell.h
//  momentsapp
//
//  Created by Joshua Balogun on 8/2/13.
//
//


#import <Foundation/Foundation.h>
#import "AQGridViewCell.h"

@interface iPadGridViewCell : AQGridViewCell
{
    IBOutlet UIButton * _dbutton;
    IBOutlet UIImageView * _imageView;
    IBOutlet UILabel * _labelView;
}

@property (nonatomic, retain) UIImage * image;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) UIImage * buttonImage;

@end