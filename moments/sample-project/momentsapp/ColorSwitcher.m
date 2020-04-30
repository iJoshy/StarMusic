//
//  ColourSwitcher.m
//  blogplex
//
//  Created by Tope on 21/02/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ColorSwitcher.h"

@implementation ColorSwitcher

@synthesize tintColorForButton;

@synthesize hue, saturation, processedImages, modifiedImages, textColor;

-(id)initWithScheme:(NSString*)scheme
{
    self = [super init];
    
    if(self)
    {
        self.processedImages = [NSMutableDictionary dictionary];
        self.modifiedImages = [NSMutableDictionary dictionary];
        
        [processedImages setObject:[UIImage imageNamed:@"menubar.png"] forKey:@"menubar"];
        [processedImages setObject:[UIImage imageNamed:@"slider-fill.png"] forKey:@"slider-fill"];
        [processedImages setObject:[UIImage imageNamed:@"tabbar.png"] forKey:@"tabbar"];
        [processedImages setObject:[UIImage imageNamed:@"ipad-menubar-left.png"] forKey:@"ipad-menubar-left"];
        [processedImages setObject:[UIImage imageNamed:@"ipad-menubar-right.png"] forKey:@"ipad-menubar-right"];
        [processedImages setObject:[UIImage imageNamed:@"ipad-tabbar-left.png"] forKey:@"ipad-tabbar-left"];
        [processedImages setObject:[UIImage imageNamed:@"ipad-tabbar-right.png"] forKey:@"ipad-tabbar-right"];
        [processedImages setObject:[UIImage imageNamed:@"back.png"] forKey:@"back"];
        [processedImages setObject:[UIImage imageNamed:@"bar-button.png"] forKey:@"bar-button"];
        
        if([scheme isEqualToString:@"red"])
        {         
            hue = 0;
            saturation = 1;
            self.tintColorForButton = [UIColor colorWithRed:134.0/255 green:34.0/255 blue:28.0/255 alpha:1.0];
        }
        else if([scheme isEqualToString:@"blue"])
        {
            hue = -2.714432;
            saturation = 1;
            self.tintColorForButton = [UIColor colorWithRed:56.0/255 green:93.0/255 blue:143.0/255 alpha:1.0];;
        }
        else if([scheme isEqualToString:@"brown"])
        {
            hue = 0.713114;
            saturation = 0.760714;
            self.tintColorForButton = [UIColor colorWithRed:106.0/255 green:65.0/255 blue:12.0/255 alpha:1.0];
        }
        else if([scheme isEqualToString:@"green"])
        {   
            hue = 3.14;
            saturation = 0.760714;
            self.tintColorForButton = [UIColor colorWithRed:109.0/255 green:137.0/255 blue:34.0/255 alpha:1.0];
        }
        
    }
    
    return self;
}


-(UIImage*)processImageWithName:(NSString*)imageName
{
    UIImage* existingImage = [processedImages objectForKey:imageName];
    
    if(existingImage)
    {
        return existingImage;
    }
    
    UIImage* originalImage = [UIImage imageNamed:imageName];
    CIImage *beginImage = [CIImage imageWithData:UIImagePNGRepresentation(originalImage)];
    
    CIFilter* hueFilter = [CIFilter filterWithName:@"CIHueAdjust" keysAndValues:kCIInputImageKey, beginImage, @"inputAngle", [NSNumber numberWithFloat:hue], nil];
    
    CIImage *outputImage = [hueFilter outputImage];
    
    
    CIFilter* saturationFilter = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, outputImage, @"inputSaturation", [NSNumber numberWithFloat:saturation], nil];
    
    outputImage = [saturationFilter outputImage];

    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    UIImage *processed;
    if ( [[[UIDevice currentDevice] systemVersion] intValue] >= 4 && [[UIScreen mainScreen] scale] == 2.0 )
    {
        processed = [UIImage imageWithCGImage:cgimg scale:2.0 orientation:UIImageOrientationUp]; 
    }
    else
    {
        processed = [UIImage imageWithCGImage:cgimg]; 
    }
    
    CGImageRelease(cgimg);
    
    [processedImages setObject:processed forKey:imageName];

    return processed;
}


-(UIImage*)processImage:(UIImage*)originalImage withKey:(NSString*)key
{
    
    UIImage* existingImage = [modifiedImages objectForKey:key];
    
    if(existingImage)
    {
        return existingImage;
    }
    else if (hue == 0 && saturation == 1)
    {
        return originalImage;
    }
    
    
    CIImage *beginImage = [CIImage imageWithData:UIImagePNGRepresentation(originalImage)];
    
    CIContext* context = [CIContext contextWithOptions:nil];
    
    CIFilter* hueFilter = [CIFilter filterWithName:@"CIHueAdjust" keysAndValues:kCIInputImageKey, beginImage, @"inputAngle", [NSNumber numberWithFloat:hue], nil];
    
    CIImage *outputImage = [hueFilter outputImage];
    
    CIFilter* saturationFilter = [CIFilter filterWithName:@"CIColorControls" keysAndValues:kCIInputImageKey, outputImage, @"inputSaturation", [NSNumber numberWithFloat:saturation], nil];
    
    outputImage = [saturationFilter outputImage];
    
    
    CGImageRef cgimg = [context createCGImage:outputImage fromRect:[outputImage extent]];
    
    
    UIImage *processed;
    if ( [[[UIDevice currentDevice] systemVersion] intValue] >= 4 && [[UIScreen mainScreen] scale] == 2.0 )
    {
        processed = [UIImage imageWithCGImage:cgimg scale:2.0 orientation:UIImageOrientationUp];
    }
    else
    {
        processed = [UIImage imageWithCGImage:cgimg];
    }
    
    CGImageRelease(cgimg);
    
    [modifiedImages setObject:processed forKey:key];
    
    return processed;
    
}



-(UIImage*)getImageWithName:(NSString*)imageName
{
    UIImage* image = [processedImages objectForKey:imageName];
    
    return [self processImage:image withKey:imageName];
}


@end
