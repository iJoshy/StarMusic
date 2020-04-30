//
//  PopoverDemoController.m
//  ocean
//
//  Created by Tope on 18/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PopoverDemoController.h"
#import "AboutViewController.h"
#import "DBSignupViewController.h"

@implementation PopoverDemoController

@synthesize tableView;

-(id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style] ;
    
    if(self)
    {
        _listOfItems = [[NSArray alloc] initWithObjects:@"Videos", @"News", @"Gallery", @"Blogs", @"Events", @"Contests", @"Audios", @"Star Stories", @"Bar Finder", @"My Downloads", @"Video Uploads",  @"Audio Uploads", @"My Profile", @"About", nil];//@"Settings", nil];
        
        //Make row selections persist.
        self.clearsSelectionOnViewWillAppear = NO;
        
        self.contentSizeForViewInPopover = CGSizeMake(280, 420);
        
    }
    
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*
    UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"landscapeBG.png"]];
    [self.view addSubview:imageView];
    [self.view sendSubviewToBack:imageView];
     */
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_listOfItems count];
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
        
    }
    
    NSString *cellValue = [_listOfItems objectAtIndex:indexPath.row];
    cell.textLabel.text = cellValue;
    cell.textLabel.font=[UIFont systemFontOfSize:16.0];
    
    /*
    if(indexPath.row == 13)
    {
        CALayer* shadow = [self createShadowWithFrame:CGRectMake(0, 44, 280, 5)];
        
        [cell.layer addSublayer:shadow];
    }
    */
    
    return cell;
}

-(CALayer *)createShadowWithFrame:(CGRect)frame
{
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = frame;
    
    
    UIColor* lightColor = [[UIColor blackColor] colorWithAlphaComponent:0.0];
    UIColor* darkColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    
    gradient.colors = [NSArray arrayWithObjects:(id)darkColor.CGColor, (id)lightColor.CGColor, nil];
    
    return gradient;
}

#pragma mark - Table view delegate

- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath;
    
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *selectedCountry = nil;
    
    selectedCountry = [_listOfItems objectAtIndex:indexPath.row];
    
    NSLog(@"selected: %@", selectedCountry);
    
    if ([selectedCountry isEqualToString:@"My Profile"])
    {
        DBSignupViewController *dbView = [DBSignupViewController new];
        [self.navigationController pushViewController:dbView animated:YES];
    }
    else if ([selectedCountry isEqualToString:@"About"])
    {
        AboutViewController *backView = [AboutViewController new];
        [self.navigationController pushViewController:backView animated:YES];
    }
    else 
    {
        if(_delegate != nil)
        {
            [_delegate selectMenu:selectedCountry];
        }
    }
    
}

@end
