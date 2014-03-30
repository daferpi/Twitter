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
        NSLog(@"Profile Image looks hot!");
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"Profile Image is so bad we ain't showin it: %@", error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)onFavorite:(id)sender {
    NSLog(@"Pressin' the Favorite Button");
    
    [[TwitterClient instance] favoriteWithTweetId:self.currentTweet.tweet_id success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"Favoriting works!");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Favoriting now working! Error: %@", error);
    }];
    
}

- (IBAction)onReply:(id)sender {
    NSLog(@"Reply to your dumb post");
    NSString *status = [NSString stringWithFormat:@"%@ ", self.currentTweet.twitter_handle];
    ComposeViewController *composeVC = [[ComposeViewController alloc] initWithNibName:@"ComposeViewController" andStatus:status  inReplyToTweetId:self.currentTweet.tweet_id bundle:nil];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController: composeVC];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (IBAction)onRetweet:(id)sender {
    NSLog(@"Retweeting you cat photos");
    [[TwitterClient instance] retweetWithTweetId:self.currentTweet.tweet_id success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"Look at that, Retweeting Works!");
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"No so fast pal. Retweeting is broken today Error: %@", error);
    }];
}

@end
