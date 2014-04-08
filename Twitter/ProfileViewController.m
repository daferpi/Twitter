//
//  ProfileViewController.m
//  Twitter
//
//  Created by Tripta Gupta on 4/3/14.
//  Copyright (c) 2014 Tripta Gupta. All rights reserved.
//

#import "ProfileViewController.h"
#import <UIImageView+AFNetworking.h>
#import "User.h"
#import "TweetCell.h"
#import "TwitterClient.h"
#import "Tweet.h"

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *userProfileImage;
@property (weak, nonatomic) IBOutlet UIImageView *userProfileBackgroundImage;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *twitterHandleLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *tweets;

@end

@implementation ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
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
    
  
    
    self.navigationItem.title = @"Profile";
    
    // Adding Buttons to Navigation Bar
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancelButton)];
    
    [self setupUser];
    
    [self addTweets];
}

- (void)addTweets
{
    [[TwitterClient instance] userTimelineWithScreenName:self.user.screen_name success:^(AFHTTPRequestOperation *operation, id response) {
        self.tweets = [Tweet tweetsWithArray:response];
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.tableView reloadData];
    }];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"TweetCell";
    TweetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    Tweet *tweet = [self.tweets objectAtIndex:indexPath.row];
    
    cell.statusLabel.text = tweet.tweet_text;
    cell.nameLabel.text = tweet.name;
    cell.twitterHandleLabel.text = tweet.twitter_handle;
    cell.timeStampLabel.text = tweet.relative_timestamp;
    
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

- (void)setUser:(User *)user {
    NSLog(@"ProfileViewController:setUser %@",user);
    _user = user;
    [self setupUser];
}

- (void)setupUser
{
    if (!self.user) {
        self.user = [User currentUser];
    }
    
    self.usernameLabel.text = self.user.name;
    self.twitterHandleLabel.text = self.user.screen_name;
//  old/wrong way:  [self.userProfileImage setImageWithURL:self.user.profile_image_url];
    [self.userProfileImage setImageWithURL:[NSURL URLWithString:self.user.profile_image_url]];
    self.tweetCountLabel.text = [NSString stringWithFormat:@"%@",self.user.statusCount];
    self.followersCountLabel.text = [NSString stringWithFormat:@"%@",self.user.followerCount];
    self.followingCountLabel.text = [NSString stringWithFormat:@"%@",self.user.friendCount];
    [self.userProfileBackgroundImage setImageWithURL:[NSURL URLWithString:self.user.profileBackgroundImageURL]];
}

- (void)onCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end