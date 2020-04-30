//
//  MoreViewController.m
//  momentsapp
//
//  Created by Joshua Balogun on 9/27/13.
//
//

#import "MoreViewController.h"
#import "MoreListViewController.h"
#import "DBSignupViewController.h"
#import "AboutViewController.h"

@interface MoreViewController ()

@end

@implementation MoreViewController

@synthesize tableView, videoview, momentview, selectIndex;
@synthesize whichView, userKey;

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
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    labelTitle.text = [@"More" capitalizedString];
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.textColor = [UIColor whiteColor];
    labelTitle.font = [UIFont fontWithName:@"Avenir-Black" size:19];
    [labelTitle sizeToFit];
    self.navigationItem.titleView = labelTitle;
    
    tableView.rowHeight = 50;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.autoresizesSubviews = YES;
    
    if([[[UIDevice currentDevice] systemVersion] integerValue] < 7)
    {
        [tableView setFrame:CGRectMake(0, 20, 320, 450)];
        UIEdgeInsets inset = UIEdgeInsetsMake(-5, 0, 0, 0);
        tableView.contentInset = inset;
    }
    else
    {
        [tableView setFrame:CGRectMake(0, 0, 320, 450)];
        UIEdgeInsets inset = UIEdgeInsetsMake(-30, 0, 0, 0);
        tableView.contentInset = inset;
    }
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.parentViewController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"landscapeBG.png"]];
    
    self.view = tableView;
    
    _listOfItems = [[NSArray alloc] initWithObjects:@"Blogs", @"Events", @"Contests", @"Audios", @"My Downloads", @"Video Uploads",  @"Audio Uploads", @"Star Stories", @"My Profile", @"About", nil];
    
    [super viewDidLoad];
    
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
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    NSString *cellValue = [_listOfItems objectAtIndex:indexPath.row];
    cell.textLabel.text = cellValue;
    //cell.textLabel.font=[UIFont systemFontOfSize:16.0];
    
    return cell;
}


#pragma mark - Table view delegate

- (NSIndexPath *)tableView :(UITableView *)theTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return indexPath;
    
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *menu = [_listOfItems objectAtIndex:indexPath.row];
    selectIndex = [NSString stringWithFormat:@"%i" ,indexPath.row];
    
    NSLog(@"selected: %@", menu);
    
    
    // Change title
    menu = [menu isEqualToString:@"Star Stories"] ? @"Adverts": menu;
    
    // Call in the child screen
    if ([menu isEqualToString:@"Adverts"] || [menu isEqualToString:@"My Downloads"] || [menu isEqualToString:@"Video Uploads"] || [menu isEqualToString:@"Audio Uploads"] || [menu isEqualToString:@"Audios"])
    {
        NSLog(@"Present view ::: %@", menu);
        
        [self performSegueWithIdentifier:@"moreVideoSegue" sender:self];
        
    }
    else if ([menu isEqualToString:@"Blogs"] || [menu isEqualToString:@"Events"] || [menu isEqualToString:@"Contests"])
    {
        NSLog(@"Present view ::: %@", menu);
        
        [self performSegueWithIdentifier:@"moreListSegue" sender:self];
        
    }
    else if ([menu isEqualToString:@"My Profile"])
    {
        DBSignupViewController *dbView = [DBSignupViewController new];
        [self.navigationController pushViewController:dbView animated:YES];
    }
    else if ([menu isEqualToString:@"About"])
    {
        AboutViewController *backView = [AboutViewController new];
        [self.navigationController pushViewController:backView animated:YES];
    }
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    NSString *menu = [_listOfItems objectAtIndex:[selectIndex intValue]];
    menu = [menu isEqualToString:@"Star Stories"] ? @"Adverts": menu;
    
    NSLog(@"selected: %@", menu);
    
    if([segue.identifier isEqualToString:@"moreListSegue"])
    {
        MoreListViewController *accVC = [segue destinationViewController];
        accVC.whichView = [menu lowercaseString];
        accVC.userKey = userKey;
    }
    else if([segue.identifier isEqualToString:@"moreVideoSegue"])
    {
        MoreListViewController *accVC = [segue destinationViewController];
        accVC.whichView = [menu lowercaseString];
        accVC.userKey = userKey;
    }
    
}

@end

