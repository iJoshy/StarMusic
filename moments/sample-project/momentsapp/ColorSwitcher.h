//
//  ColourSwitcher.h
//  blogplex
//
//  Created by Tope on 21/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ColorSwitcher : NSObject

-(id)initWithScheme:(NSString*)scheme;

@property (nonatomic, retain) UIColor* tintColorForButton;

@property (nonatomic, retain) NSMutableDictionary* processedImages;

@property (nonatomic, retain) NSMutableDictionary* modifiedImages;

@property (nonatomic, assign) float hue;

@property (nonatomic, assign) float saturation;

-(UIImage*)processImageWithName:(NSString*)imageName;

-(UIImage*)getImageWithName:(NSString*)imageName;

-(UIImage*)processImage:(UIImage*)originalImage withKey:(NSString*)key;

@property (nonatomic, retain) UIColor *textColor;


@end
