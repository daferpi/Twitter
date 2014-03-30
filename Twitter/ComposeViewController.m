//
//  ComposeViewController.m
//  Twitter
//
//  Created by Tripta Gupta on 3/27/14.
//  Copyright (c) 2014 Tripta Gupta. All rights reserved.
//

#import "ComposeViewController.h"
#import "User.h"
#import <UIImageView+AFNetworking.h>
#import "TwitterClient.h"

@interface ComposeViewController ()

@end

@implementation ComposeViewController

-(id)initWithNibName:(NSString *)nibNameOrNil andStatus:(NSString *)status bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.current_status = status;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil andStatus:(NSString *)status inReplyToTweetId:(NSString *)tweetId bundle:(NSBundle *)nibBundleOrNil
{
    self = [self initWithNibName:nibNameOrNil andStatus:status bundle:nibBundleOrNil];
    if (self) {
        self.in_reply_to_status_id = tweetId;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(onCancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonSystemItemDone target:self action:@selector(onDoneButton)];
    self.editing = YES;
    
//    if (self.current_status.length == 0) {
//        self.statusTextView.placeholder = @"What's happening?";
//    }
//    else {
//        self.statusTextView.text = self.current_status;
//    }
    
//    [self.profileImageView setImageWithURL:[NSURL URLWithString: [[User currentUser] profile_image_url]]];
//    self.screenNameLabel.text = [[User currentUser] screen_name];
//    self.nameLabel.text = [[User currentUser] name];
//    
//    [self.statusTextView becomeFirstResponder];
}

- (void)onCancelButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//- (void)onDoneButton
//{
//    NSLog(@"onDoneButton");
//    
//    if (self.in_reply_to_status_id.length > 0) {
//        NSLog(@"Reply Starting");
//        [[TwitterClient instance] replyToTweetId:self.in_reply_to_status_id withStatus:self.statusTextView.text success:^(AFHTTPRequestOperation *operation, id response) {
//            NSLog(@"Reply Success!");
//            [self dismissViewControllerAnimated:YES completion:nil];
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"Reply Error! Error: %@", error);
//        }];
//    }
//    else {
//        NSLog(@"Update Status Starting");
//        [[TwitterClient instance] updateStatus:self.statusTextView.text success:^(AFHTTPRequestOperation *operation, id response) {
//            NSLog(@"Update Status Success!");
//            [self dismissViewControllerAnimated:YES completion:nil];
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"Update Status Error! Error: %@", error);
//        }];
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
