//
//  BarListViewController.m
//  momentsapp
//
//  Created by Joshua Balogun on 9/25/13.
//
//

#import <QuartzCore/QuartzCore.h>
#import "BarListViewController.h"
#import "BarDetailViewController.h"
#import "BarListCell.h"
#import "Model.h"
#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "SimpleFlickrAPI.h"

@interface BarListViewController ()

@end

@implementation BarListViewController

@synthesize models, jsonResponse, locationid, whichView, tableview;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.parentViewController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"landscapeBG.png"]];
    
    [tableview setDelegate:self];
    [tableview setDataSource:self];
    
    [tableview setBackgroundColor:[UIColor clearColor]];
    [tableview setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableview setFrame:CGRectMake(0, 33, 320, 450)];
    
    //title
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    labelTitle.text = [whichView capitalizedString];
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.textColor = [UIColor whiteColor];
    labelTitle.font = [UIFont fontWithName:@"Avenir-Black" size:19];
    [labelTitle sizeToFit];
    self.navigationItem.titleView = labelTitle;
    
    // Add padding to the top of the table view
    UIEdgeInsets inset = UIEdgeInsetsMake(5, 0, 0, 0);
    tableview.contentInset = inset;
    
    
    UIBarButtonItem* backButton = [self createBackBarButtonWithImage:@"back.png"];
    [self.navigationItem setLeftBarButtonItem:backButton];
    
    [SVProgressHUD showWithStatus:@"Loading ..."];
    [self fetchFlickrMap];
    
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
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)fetchFlickrMap
{
    
    //NSLog(@" Starting- going to fetch images .....");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSArray *photos = [flickr barFinder:@"bars" :locationid];
                       
                       [self setJsonResponse:photos];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self.tableview reloadData];
                           [SVProgressHUD dismiss];
                       });
                   });
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"BarListCell";
    
    BarListCell *cell =  (BarListCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:indexPath.row];
    
    [cell.titleLabel setText:[flickrPhoto objectForKey:@"name"]];
    [cell.locationLabel  setText:[flickrPhoto objectForKey:@"address"]];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [[self jsonResponse] count];
    NSLog(@"length of row :: count  :: %i",count);
    return count;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"barDetailSegue" sender:self];
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    BarDetailViewController *nextList = segue.destinationViewController;
    NSIndexPath *index = [self.tableview indexPathForSelectedRow];
    
    nextList.mapDetails = [[self jsonResponse] objectAtIndex:index.row];
    
}

@end
