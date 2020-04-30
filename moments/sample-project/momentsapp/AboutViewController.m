//
//  AboutViewController.m
//  momentsapp
//
//  Created by Joshua Balogun on 9/7/13.
//
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    CGSize size = CGSizeMake(280, 80); // size of view in popover
    self.contentSizeForViewInPopover = size;
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"landscapeBG.png"]]];
    
    UIBarButtonItem* backButton = [self createBackBarButtonWithImage:@"back.png"];
    [self.navigationItem setLeftBarButtonItem:backButton];
    
    UIImageView *imgView = [[UIImageView alloc] init];
    imgView.image = [UIImage imageNamed:@"star_logo.png"];
    imgView.contentMode = UIViewContentModeCenter;
    
    
    UILabel *headingLabel = [[UILabel alloc] init];
    headingLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0];
    headingLabel.backgroundColor = [UIColor clearColor];
    headingLabel.textColor = [UIColor whiteColor];
    headingLabel.text = @"Version 2.0";
    
    
    UILabel *headingLabel2 = [[UILabel alloc] init];
    headingLabel2.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:12.0];
    headingLabel2.backgroundColor = [UIColor clearColor];
    headingLabel2.textColor = [UIColor whiteColor];
    headingLabel2.text = @"Powered by 70th Precinct";
    
    
    NSString *deviceType = [UIDevice currentDevice].model;
    NSLog(@"deviceType :::::: %@",deviceType);
    
    if ([deviceType isEqualToString:@"iPhone"] || [deviceType isEqualToString:@"iPhone Simulator"])
    {
        [imgView setFrame:CGRectMake(37, 100, 260, 128)];
        [headingLabel setFrame:CGRectMake(120, 200, 180, 30)];
        [headingLabel2 setFrame:CGRectMake(100, 230, 180, 30)];
    }
    else
    {
        [imgView setFrame:CGRectMake(10, 20, 260, 128)];
        [headingLabel setFrame:CGRectMake(90, 130, 180, 30)];
        [headingLabel2 setFrame:CGRectMake(70, 160, 180, 30)];
    }
    
    [self.view addSubview:imgView];
    [self.view addSubview:headingLabel];
    [self.view addSubview:headingLabel2];
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    labelTitle.text = [@"About" capitalizedString];
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.textColor = [UIColor whiteColor];
    labelTitle.font = [UIFont fontWithName:@"Avenir-Black" size:19];
    [labelTitle sizeToFit];
    self.navigationItem.titleView = labelTitle;
    
}

-(UIBarButtonItem*)createBackBarButtonWithImage:(NSString*)imageName
{
    UIImage* buttonImage = [UIImage imageNamed:imageName];
    
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [button setImage:buttonImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    
    UIView* buttonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [buttonView addSubview:button];
    
    UIBarButtonItem* barButton = [[UIBarButtonItem alloc] initWithCustomView:buttonView];
    
    return barButton;
}

-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
