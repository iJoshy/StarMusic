//
//  CommentViewController.m
//  momentsapp
//
//  Created by Joshua Balogun on 9/20/13.
//
//

#import <QuartzCore/QuartzCore.h>

#import "CommentViewController.h"
#import "MasterViewController.h"
#import "AppDelegate.h"
#import "SimpleFlickrAPI.h"
#import "MBProgressHUD.h"
#import "CommentCell.h"

@implementation CommentViewController

@synthesize HUD, userKey, table, noComment, noComments, noLikes, titleLabel;
@synthesize jsonResponse, whichView,  commentId, noLike, commentTextField, titlelabel;



#pragma mark - View lifecycle
-(void)viewWillAppear:(BOOL)animated
{
    
    self.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    self.view.opaque = NO;
    
    UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"landscapeBG.png"]];
    
    imageView.frame = self.view.bounds;
    imageView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.view addSubview:imageView];
    [self.view sendSubviewToBack:imageView];
    
    table.delegate = self;
    table.dataSource = self;
    
    noComment.text = noComments;
    noLike.text = noLikes;
    titleLabel.text = titlelabel;
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.mode = MBProgressHUDModeIndeterminate;
    HUD.labelText = @"Loading ...";
    HUD.delegate = (id)self;
    [self.view addSubview:HUD];
    
    //NSLog(@"This view is for  :: %@",whichView);
    
    [self performSelectorOnMainThread:@selector(fetchFlickrPhoto) withObject:nil waitUntilDone:YES];
    
}


- (void)fetchFlickrPhoto
{
    /*
    NSLog(@"fetchFlickrPhoto ::::: of :::: comment ");
    NSLog(@"fetchFlickrPhoto ::::: of :::: comment whichView ::::: %@",whichView);
    NSLog(@"fetchFlickrPhoto ::::: of :::: comment commentId ::::: %@",commentId);
    NSLog(@"fetchFlickrPhoto ::::: of :::: comment userKey ::::: %@",userKey);
    */
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSArray *photos = [flickr comments: whichView : @"comments" : commentId];
                       
                       NSLog(@"fetchFlickrPhoto ::::: of :::: comment ::::: photos ::: %@",photos);
                       
                       [self setJsonResponse:photos];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self totalcomment];
                           [self.table reloadData];
                           [HUD hide:YES afterDelay:1];
                       });
                   });
    
}

-(void)totalcomment
{
    
    //NSLog(@"like_comments :::::");
    
    NSString *commentCount = [NSString stringWithFormat:@"%i",[jsonResponse count]];
    
    noComment.text = commentCount;
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdentifier = @"CommentCell";
    CommentCell *cell = (CommentCell*)[atableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if ( cell == nil )
    {
        NSArray *topObjects = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        for (id obj in topObjects)
        {
            if ([obj isKindOfClass:[CommentCell class]])
            {
                cell = (CommentCell*)obj;
                break;
            }
        }
    }
    
    // Configure the cell...
    NSDictionary *comment = [jsonResponse objectAtIndex:indexPath.row];
    
    cell.titleLabel.text = [comment objectForKey:@"posted_by"];
    cell.timeLabel.text = [comment objectForKey:@"creation_date"];
    cell.descLabel.text = [comment objectForKey:@"content"];
    
    return cell;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 83;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = [[self jsonResponse] count];
    return count;
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Tapped :::::");
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    
}


- (IBAction) textFieldDoneEditing:(id) sender
{
    
    [sender resignFirstResponder];
    
    [HUD show:YES];
    
    [self performSelectorOnMainThread:@selector(fetchFlickrComment) withObject:nil waitUntilDone:YES];
    
}


- (void)fetchFlickrComment
{
    NSString *newcomment = commentTextField.text;
    commentTextField.text = @"";
    //NSLog(@"Came here too :::::: %@", newcomment);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSArray *photos = [flickr add_comments: whichView : @"add_comment" : commentId : userKey : newcomment];
                       
                       //[self setComments:photos];
                       NSLog(@"photos ::: %@",photos);
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self fetchFlickrPhoto];
                           [HUD hide:YES afterDelay:1];
                       });
                   });
    
}


- (IBAction) likeTapped:(id) sender
{
    
    //NSLog(@"just liked :::::: just liked");
    
    [HUD show:YES];
    
    [self performSelectorOnMainThread:@selector(fetchFlickrLikes) withObject:nil waitUntilDone:YES];
    
}

- (void)fetchFlickrLikes
{
    //NSLog(@"Came here too :::::: %@", commentTextField.text);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSDictionary *photos = [flickr likes:whichView :@"like" :commentId :userKey];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self total_likes:photos];
                           [HUD hide:YES afterDelay:1];
                       });
                   });
    
}

-(void) total_likes: (NSDictionary *)likes
{
    //NSLog(@"comments liked ::::::: osaosaosa %@ ", likes);
    
    NSString *commentCount = [[likes objectForKey:@"total_likes"] stringValue];
    
    noLike.text = commentCount;
}



@end


