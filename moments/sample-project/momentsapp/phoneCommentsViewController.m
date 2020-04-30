//
//  phoneCommentsViewController.m
//  momentsapp
//
//  Created by Joshua Balogun on 9/30/13.
//
//

#import <QuartzCore/QuartzCore.h>
#import "phoneCommentsViewController.h"
#import "MasterViewController.h"
#import "AppDelegate.h"
#import "SimpleFlickrAPI.h"
#import "SVProgressHUD.h"
#import "CommentCell.h"

@implementation phoneCommentsViewController

@synthesize userKey, table, noComment, noComments, noLikes, titleLabel, commentView;
@synthesize jsonResponse, whichView,  commentId, noLike, commentTextField, titlelabel;


#pragma mark - View lifecycle
-(void)viewWillAppear:(BOOL)animated
{
    commentView.backgroundColor = [UIColor clearColor];
    self.view.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2];
    self.view.opaque = NO;
    
    if([[[UIDevice currentDevice] systemVersion] integerValue] < 7)
    {
        [commentView setFrame:CGRectMake(0, 0, 320, 405)];
    }
    else
    {
        [commentView setFrame:CGRectMake(0, 75, 320, 456)];
    }
    
    UIImageView *imageView=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"landscapeBG.png"]];
    
    imageView.frame = self.view.bounds;
    imageView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    [self.view addSubview:imageView];
    [self.view sendSubviewToBack:imageView];
    
    UILabel *labelTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    labelTitle.text = [whichView capitalizedString];
    labelTitle.backgroundColor = [UIColor clearColor];
    labelTitle.textColor = [UIColor whiteColor];
    labelTitle.font = [UIFont fontWithName:@"Avenir-Black" size:19];
    [labelTitle sizeToFit];
    self.navigationItem.titleView = labelTitle;
    
    table.delegate = self;
    table.dataSource = self;
    
    noComment.text = noComments;
    noLike.text = noLikes;
    titleLabel.text = titlelabel;
    
    UIBarButtonItem* backButton = [self createBackBarButtonWithImage:@"back.png"];
    [self.navigationItem setLeftBarButtonItem:backButton];
    
    [SVProgressHUD showWithStatus:@"Loading ..."];
    
    NSLog(@"comment ");
    NSLog(@"comment whichView ::::: %@",whichView);
    NSLog(@"comment commentId ::::: %@",commentId);
    NSLog(@"comment userKey ::::: %@",userKey);
    
    [self fetchFlickrPhoto];
    
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


- (void)fetchFlickrPhoto
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSArray *photos = [flickr comments: whichView : @"comments" : commentId];
                       
                       NSLog(@"fetchFlickrPhoto ::::: of :::: comment ::::: photos ::: %@",photos);
                       
                       [self setJsonResponse:photos];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self totalcomment];
                           [self.table reloadData];
                           [SVProgressHUD dismiss];
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
    
    [SVProgressHUD showWithStatus:@"Posting ..."];
    
    [self fetchFlickrComment];
    
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
                           [SVProgressHUD dismiss];
                       });
                   });
    
}


- (IBAction) likeTapped:(id) sender
{
    
    //NSLog(@"just liked :::::: just liked");
    
    [SVProgressHUD showWithStatus:@"Posting ..."];
    
    [self fetchFlickrLikes];
    
}

- (void)fetchFlickrLikes
{
    NSLog(@"Came here too :::::: %@", commentTextField.text);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                   {
                       SimpleFlickrAPI *flickr = [[SimpleFlickrAPI alloc] init];
                       
                       NSDictionary *photos = [flickr likes:whichView :@"like" :commentId :userKey];
                       NSLog(@"photos :::::: %@", photos);
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self total_likes:photos];
                           [SVProgressHUD dismiss];
                       });
                   });
    
}

-(void) total_likes: (NSDictionary *)likes
{
    NSLog(@"comments liked ::::::: osaosaosa %@ ", likes);
    
    NSString *commentCount = [[likes objectForKey:@"total_likes"] stringValue];
    
    noLike.text = commentCount;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshContent" object:whichView];
    
}

@end