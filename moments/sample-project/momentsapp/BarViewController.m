//
//  BarViewController.m
//  momentsapp
//
//  Created by Joshua Balogun on 9/25/13.
//
//

#import "BarViewController.h"
#import "BarListViewController.h"
#import "SimpleFlickrAPI.h"
#import "SVPullToRefresh.h"
#import "SVProgressHUD.h"
#import "MasterCell.h"

@interface BarViewController ()

@end

@implementation BarViewController

@synthesize tableview, whichView, userKey;

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
    labelTitle.text = [@"Bar Finder" capitalizedString];
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.textColor = [UIColor whiteColor];
    labelTitle.font = [UIFont fontWithName:@"Avenir-Black" size:19];
    [labelTitle sizeToFit];
    self.navigationItem.titleView = labelTitle;
    
    // Add padding to the top of the table view
    UIEdgeInsets inset = UIEdgeInsetsMake(5, 0, 0, 0);
    tableview.contentInset = inset;
    
    [SVProgressHUD showWithStatus:@"Loading ..."];
    [self fetchFlickrMap];
    
}

- (void)fetchFlickrMap
{
    
    //NSLog(@" Starting- going to fetch images .....");
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSArray *photos = [flickr photosWithSearchString:@"locations"];
                       
                       [self setJsonResponse:photos];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self.tableview reloadData];
                           [SVProgressHUD dismiss];
                       });
                   });
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self jsonResponse] count];
}

- (UIImage *)cellBackgroundForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowCount = [self tableView:[self tableview] numberOfRowsInSection:0];
    NSInteger rowIndex = indexPath.row;
    UIImage *background = nil;
    
    if (rowIndex == 0) {
        background = [UIImage imageNamed:@"cell_top.png"];
    } else if (rowIndex == rowCount - 1) {
        background = [UIImage imageNamed:@"cell_bottom.png"];
    } else {
        background = [UIImage imageNamed:@"cell_middle.png"];
    }
    
    return background;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:indexPath.row];
    
    UILabel *recipeNameLabel = (UILabel *)[cell viewWithTag:333];
    recipeNameLabel.text = [flickrPhoto objectForKey:@"location"];
    
    UIImageView *recipeImageView = (UIImageView *)[cell viewWithTag:444];
    recipeImageView.image = [UIImage imageNamed:@"point.png"];
    
    // Assign our own background image for the cell
    UIImage *background = [self cellBackgroundForRowAtIndexPath:indexPath];
    
    UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:background];
    cellBackgroundView.image = background;
    cell.backgroundView = cellBackgroundView;
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;

}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [cell setBackgroundColor:[UIColor clearColor]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped :::::");
    
    [self performSegueWithIdentifier:@"barListSegue" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    BarListViewController *nextList = segue.destinationViewController;
    NSIndexPath *index = [self.tableview indexPathForSelectedRow];
    
    NSDictionary *flickrPhoto = [[self jsonResponse] objectAtIndex:index.row];
    nextList.whichView =  [flickrPhoto objectForKey:@"location"];
    nextList.locationid =  [flickrPhoto objectForKey:@"id"];

    
}

@end

