

#import "GridViewController.h"
#import "GridViewCell.h"

#import "DataLoader.h"


@implementation GridViewController

@synthesize gridView, services;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.gridView = [[AQGridView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    self.gridView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	self.gridView.autoresizesSubviews = YES;
	self.gridView.delegate = self;
	self.gridView.dataSource = self;
    
    [self.view addSubview:gridView];
    
    self.services = [DataLoader loadSampleData];
    
    self.title = @"Services";
    
    UIImage * backgroundPattern = [UIImage imageNamed:@"bg-app.png"];
    
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:backgroundPattern]];
    
    [self.gridView reloadData];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL) shouldAutorotateToInterfaceOrientation: (UIInterfaceOrientation) interfaceOrientation
{
    return YES;
}

- (void) viewDidUnload
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    self.gridView = nil;
    
}



#pragma mark -
#pragma mark Grid View Data Source

- (NSUInteger) numberOfItemsInGridView: (AQGridView *) aGridView
{
    return ( [services count] );
}

- (AQGridViewCell *) gridView: (AQGridView *) aGridView cellForItemAtIndex: (NSUInteger) index
{
    static NSString * PlainCellIdentifier = @"PlainCellIdentifier";
    

    GridViewCell * cell = (GridViewCell *)[aGridView dequeueReusableCellWithIdentifier:@"PlainCellIdentifier"];
    
    if ( cell == nil )
    {
        cell = [[GridViewCell alloc] initWithFrame: CGRectMake(0.0, 0.0, 160, 123)
                                                 reuseIdentifier: PlainCellIdentifier];
        
        cell.selectionGlowColor = [UIColor whiteColor];
    }
    
    Model* service = [services objectAtIndex:index];
    
    [cell setImage:service.image];
    [cell setCaption:service.name];

    return cell;
   
}


- (CGSize) portraitGridCellSizeForGridView: (AQGridView *) aGridView
{
    return ( CGSizeMake(160.0, 123) );
}

- (void) gridView: (AQGridView *) gridView didSelectItemAtIndex: (NSUInteger) index
{
    [self performSegueWithIdentifier:@"detail" sender:self];
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DetailThemeController* detailController = segue.destinationViewController;
    
    detailController.model = [services objectAtIndex:gridView.indexOfSelectedItem];
}



#pragma mark -
#pragma mark Grid View Delegate

// nothing here yet

@end
