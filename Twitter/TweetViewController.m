//
//  TweetViewController.m
//  Twitter
//
//  Created by Tripta Gupta on 3/27/14.
//  Copyright (c) 2014 Tripta Gupta. All rights reserved.
//

#import "TweetViewController.h"
#import "Tweet.h"
#import <UIImageView+AFNetworking.h>
#import "TwitterClient.h"
#import "ComposeViewController.h"

@interface TweetViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (nonatomic, weak) Tweet *currentTweet;

- (IBAction)onReply:(id)sender;
- (IBAction)onRetweet:(id)sender;
- (IBAction)onFavorite:(id)sender;

@end

@implementation TweetViewController

@synthesize currentTweet;

- (id)initWithNibName:(NSString *)nibNameOrNil andModel:(Tweet *)tweet bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.currentTweet = tweet;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tweetStatusLabel.text = currentTweet.tweet_text;
    self.nameLabel.text = currentTweet.name;
    self.userNameLabel.text = currentTweet.twitter_handle;
    self.timestampLabel.text = currentTweet.timestamp;
    
    [self.profileImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:currentTweet.profile_image_url]] placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        self.profileImageView.image = image;
        NSLog(@"Profile Image");
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"Profile Image failure: %@", error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)onFavorite:(id)sender {
    NSLog(@"Favorite Button");
    
    [[TwitterClient instance] favoriteWithTweetId:self.currentTweet.tweet_id success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"Favoriting success");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Favoriting failure: Error: %@", error);
    }];
}

- (IBAction)onReply:(id)sender {
    NSLog(@"Reply to post");
    NSString *status = [NSString stringWithFormat:@"%@ ", self.currentTweet.twitter_handle];
    ComposeViewController *composeVC = [[ComposeViewController alloc] initWithNibName:@"ComposeViewController" andStatus:status  inReplyToTweetId:self.currentTweet.tweet_id bundle:nil];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController: composeVC];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (IBAction)onRetweet:(id)sender {
    NSLog(@"Retweeting");
    [[TwitterClient instance] retweetWithTweetId:self.currentTweet.tweet_id success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"Retweeting success!");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Retweeting error: %@", error);
    }];
}

@end
