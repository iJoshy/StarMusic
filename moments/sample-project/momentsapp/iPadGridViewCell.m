//
//  iPadGridViewCell.m
//  momentsapp
//
//  Created by Joshua Balogun on 8/2/13.
//
//

#import "iPadGridViewCell.h"

@interface iPadGridViewCell ()

@end

@implementation iPadGridViewCell

- (id) initWithFrame: (CGRect) frame reuseIdentifier: (NSString *) aReuseIdentifier
{
    
    self = [super initWithFrame: frame reuseIdentifier: aReuseIdentifier];
    if ( self == nil )
        return ( nil );
    
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"iPadGridViewCell" owner:nil options:nil];
    
    UIView* mainView = [views objectAtIndex:0];
    _imageView = (UIImageView*)[mainView viewWithTag:1];
    
    [self.contentView addSubview:mainView];
    
    UILabel* mainLabel = [views objectAtIndex:0];
    _labelView = (UILabel*)[mainLabel viewWithTag:2];
    
     [self.contentView addSubview:mainLabel];
    
    UIButton* dButton = [views objectAtIndex:0];
    _dbutton = (UIButton*)[dButton viewWithTag:3];
    
    [self.contentView addSubview:dButton];
    
    return ( self );
    
}

- (CALayer *) glowSelectionLayer
{
    return ( _imageView.layer );
}


- (UIImage *) image
{
    return ( _imageView.image );
}

- (void) setImage: (UIImage *) anImage
{
    _imageView.image = anImage;
    [self setNeedsLayout];
}

- (NSString *) label
{
    return ( _labelView.text );
}

- (void) setLabel: (NSString *) aLabel
{
    _labelView.text = aLabel;
}

- (UIImage *) butonImage
{
    return ( _dbutton.currentBackgroundImage );
}

- (void) setButtonImage: (UIImage *) anImage
{
    [_dbutton setBackgroundImage:anImage forState:UIControlStateNormal];
    [self setNeedsLayout];
}

@end

