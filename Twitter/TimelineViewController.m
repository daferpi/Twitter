//
//  TimelineViewController.m
//  Twitter
//
//  Created by Tripta Gupta on 3/27/14.
//  Copyright (c) 2014 Tripta Gupta. All rights reserved.
//

#import "TimelineViewController.h"
#import "TweetCell.h"
#import "ComposeViewController.h"
#import "TweetViewController.h"
#import <UIImageView+AFNetworking.h>
#import "User.h"
#import "TwitterClient.h"
#import "ProfileViewController.h"

@interface TimelineViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *tweets;
@property (strong, nonatomic) UIRefreshControl *refreshControl;

- (void)onSignOutButton;
- (void)reload;

@end

@implementation TimelineViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Twitter";
        
        [self reload];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UINib *customNib = [UINib nibWithNibName:@"TweetCell" bundle:nil];
    [self.tableView registerNib:customNib forCellReuseIdentifier:@"TweetCell"];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Sign Out" style:UIBarButtonItemStyleDone target:self action:@selector(onSignOutButton)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(onComposeButton)];
    
    //Refresh Control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"TweetCell";
    TweetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    Tweet *tweet = [self.tweets objectAtIndex:indexPath.row];
    
    cell.statusLabel.text = tweet.tweet_text;
    cell.nameLabel.text = tweet.name;
    cell.twitterHandleLabel.text = tweet.twitter_handle;
    cell.timeStampLabel.text = tweet.relative_timestamp;
    
    //tap on profile for ProfileViewController
    UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileOnTap:)];
    cell.profileImageView.image = indexPath.row;
    [cell.profileImageView setUserInteractionEnabled:YES];
    [tapgesture setDelegate:self];
    [cell.profileImageView addGestureRecognizer:tapgesture];
    
    [cell.profileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:tweet.profile_image_url]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        cell.profileImageView.image = image;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"%@", error);
    }];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Tweet *tweet = self.tweets[indexPath.row];
    
    NSString *text = tweet.tweet_text;
    UIFont *fontText = [UIFont systemFontOfSize:15.0];
    CGRect rect = [text boundingRectWithSize:CGSizeMake(235, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:fontText}
                                     context:nil];
    
    CGFloat heightOffset = 45;
    return rect.size.height + heightOffset;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    Tweet *tweet = self.tweets[indexPath.row];

    TweetViewController *tvc = [[TweetViewController alloc] initWithNibName:@"TweetViewController" andModel:tweet bundle:nil];
    [self.navigationController pushViewController:tvc animated:YES];
}

#pragma mark - Private methods

- (void)onSignOutButton
{
    [User setCurrentUser:nil];
}

- (void)reload
{
    [[TwitterClient instance] homeTimelineWithCount:20 sinceId:0 maxId:0 success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"%@", response);
        self.tweets = [Tweet tweetsWithArray:response];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"!");
    }];
}

- (void)onComposeButton
{
    NSLog(@"Compose Button Clicked");
    ComposeViewController *composeVC = [[ComposeViewController alloc] init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController: composeVC];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)refreshView
{
    NSLog(@"refreshing view");
    [[TwitterClient instance] homeTimelineWithCount:20 sinceId:0 maxId:0 success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"%@", response);
        self.tweets = [Tweet tweetsWithArray:response];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"!");
    }];
    [self.refreshControl endRefreshing];
}

- (void)profileOnTap:(UIGestureRecognizer *)tap
{
    Tweet *tweet = [self.
    NSLog(@"profile tapped");
    ProfileViewController *pvc = [[ProfileViewController alloc] init];
    pvc.user = tweet.user;
    [self.navigationController pushViewController:pvc animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
