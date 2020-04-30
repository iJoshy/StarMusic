/*
 * ImageDemoGridViewCell.m
 * Classes
 * 
 * Created by Jim Dovey on 17/4/2010.
 * 
 * Copyright (c) 2010 Jim Dovey
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 
 * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 * 
 * Neither the name of the project's author nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#import "GridViewCell.h"

@implementation GridViewCell

- (id) initWithFrame: (CGRect) frame reuseIdentifier: (NSString *) aReuseIdentifier
{
    self = [super initWithFrame: frame reuseIdentifier: aReuseIdentifier];
    if ( self == nil )
        return ( nil );
    
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"GridViewCell" owner:nil options:nil];
    
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
