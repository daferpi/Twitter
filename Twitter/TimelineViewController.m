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
#import "MenuViewController.h"

@interface TimelineViewController () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *tweets;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UIRefreshControl *searchRefresControl;
@property (strong, nonatomic) UIRefreshControl *paginationRefresControl;
@property (assign, nonatomic) BOOL showMentions;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) NSMutableArray *filterTweets;
@property (assign, nonatomic) BOOL isPaginationWorking;

//- (void)onSignOutButton;
- (void)reload;

@end

@implementation TimelineViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Twitter";
        
        self.showMentions = NO;
        //[self reload];

    }
    return self;
}

- (id)initWithShowMentions:(BOOL)showMentions
{
    self = [super init];
    if (self) {
        self.title = @"Mentions";
        self.showMentions = showMentions;
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
    
    //Refresh Control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshView) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    //searchRefresControl Control
    self.searchRefresControl = [[UIRefreshControl alloc] init];
    [self.searchRefresControl addTarget:self action:@selector(sendSearchRequest:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.searchRefresControl];
    
    //searchRefresControl Control
    self.paginationRefresControl = [[UIRefreshControl alloc] init];
    [self.paginationRefresControl addTarget:self action:@selector(loadMoreSince:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.paginationRefresControl];
    
    self.filterTweets = [[NSMutableArray alloc] init];

    
    self.isPaginationWorking = NO;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.definesPresentationContext = YES;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.searchController.searchBar.delegate = self;
    
    [self.searchController.searchBar sizeToFit];
    
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.searchController.isActive && ![self.searchController.searchBar.text  isEqual: @""]) {
        return self.filterTweets.count;
    }
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"TweetCell";
    TweetCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    Tweet *tweet;
    
    if (self.searchController.isActive && ![self.searchController.searchBar.text  isEqual: @""]) {
        tweet = [self.filterTweets objectAtIndex:indexPath.row];
    } else {
        tweet = [self.tweets objectAtIndex:indexPath.row];
    }
    
    // Setting cell data from Tweet object
    //cell.statusLabel.text = tweet.tweet_text;
    cell.nameLabel.text = tweet.name;
    cell.twitterHandleLabel.text = tweet.twitter_handle;
    cell.timeStampLabel.text = tweet.relative_timestamp;
    
    
    cell.statusLabel.lineBreakMode = NSLineBreakByWordWrapping;
    cell.statusLabel.numberOfLines = 0;
    cell.statusLabel.font = [UIFont fontWithName:@"MorrisRoman-Black" size:15];
    
    CGFloat heightOffset = 55;
    UIFont *cellFont = cell.statusLabel.font;
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize labelSize = [tweet.tweet_text sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    cell.statusLabel.frame = CGRectMake(cell.statusLabel.frame.origin.x, cell.statusLabel.frame.origin.y, labelSize.width, labelSize.height + heightOffset);
    cell.statusLabel.text = tweet.tweet_text;
    
    
    //tap on profile for ProfileViewController
    UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileOnTap:)];
    
    cell.profileImageView.tag = indexPath.row;
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
    UIFont *fontText = [UIFont fontWithName:@"MorrisRoman-Black" size:15];
    CGRect rect = [text boundingRectWithSize:CGSizeMake(235, CGFLOAT_MAX)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:fontText}
                                     context:nil];
    
    CGFloat heightOffset = 55;
    return rect.size.height + heightOffset;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected row %d", indexPath.row);
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    Tweet *tweet;
    
    if (self.searchController.isActive && ![self.searchController.searchBar.text  isEqual: @""]) {
        tweet = [self.filterTweets objectAtIndex:indexPath.row];
    } else {
        tweet = [self.tweets objectAtIndex:indexPath.row];
    }
    
    if (tweet) {
        TweetViewController *tvc = [[TweetViewController alloc] initWithNibName:@"TweetViewController" andModel:tweet bundle:nil];
        
        //UINavigationController *navigationVC = [[UINavigationController alloc] init];
        //[self presentViewController:navigationVC animated:YES completion:nil];
        [self.navigationController pushViewController:tvc animated:YES];
    } else {
        NSLog(@"None tweet selected");
    }
    
    
}

#pragma mark - Private methods

- (void)reload
{
    if (self.showMentions) {
        // Getting mentions from API
        [[TwitterClient instance] mentionsWithSuccess:^(AFHTTPRequestOperation *operation, id response) {
            NSLog(@"You've been mentioned by people: %@", response);
            
            // Initializing tweet model with array of json
            self.tweets = [Tweet tweetsWithArray:response];
            [self setTitle:@"Mentions"];
            
            [self.tableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"No one loves you enough to mention you!");
        }];
    } else {
        // Getting last 20 tweets from home timeline API
        [[TwitterClient instance] homeTimelineWithCount:20 sinceId:0 maxId:0 success:^(AFHTTPRequestOperation *operation, id response) {
            NSLog(@"You've go the best json I've ever seen: %@", response);
            
            // Initializing tweet model with array of json
            self.tweets = [Tweet tweetsWithArray:response];
            [self setTitle:@"Home"];
            
            [self.tableView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"You've been very bad. No tweets for you!");
        }];
    }
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


- (void)loadMoreSince:(int)sinceId
{
    NSLog(@"loadMoreSince view");
    /*self.isPaginationWorking = YES;
    [[TwitterClient instance] homeTimelineWithCount:20 sinceId:sinceId maxId:0 success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"%@", response);
        [self.tweets addObjectsFromArray:[Tweet tweetsWithArray:response]];
        [self.tableView reloadData];
        self.isPaginationWorking = NO;
        [self.paginationRefresControl endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        self.isPaginationWorking = NO;
        NSLog(@"Error in loadMoreSince!");
        [self.paginationRefresControl endRefreshing];
    }];*/
}


- (void) performSearch:(NSString *) stringToSearch {
    if (stringToSearch.length >= 2) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
        [self performSelector:@selector(sendSearchRequest:) withObject:stringToSearch afterDelay:0.3f];
    }
}

- (void) sendSearchRequest:(NSString *) stringToSearch {
    
    NSLog(@"sendSearchRequest");
    [[TwitterClient instance] searchTweetWithText:stringToSearch success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"%@", response);
        
        NSArray *results = [(NSDictionary *)response objectForKey:@"statuses"];
        
        NSLog(@"%@", results);
        
        if (results.count) {
            
            [self.filterTweets addObjectsFromArray:[Tweet tweetsWithArray:results]];
            [self.tableView reloadData];
        }
        
        [self.searchRefresControl endRefreshing];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@" error in sendSearchRequest!");
        [self.searchRefresControl endRefreshing];
    }];
}

- (void)profileOnTap:(UIGestureRecognizer *)tap
{
    NSLog(@"Tap that");
    Tweet *tweet = [self.tweets objectAtIndex:tap.view.tag];
    
    ProfileViewController *pvc = [[ProfileViewController alloc] init];
    pvc.user = tweet.user;
    
    UINavigationController *navigationVC = [[UINavigationController alloc] initWithRootViewController: pvc];
    [self presentViewController:navigationVC animated:YES completion:nil];
    //[self.navigationController pushViewController:navigationVC animated:YES];
}



- (void)setTitle:(NSString *)title
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = label;
    label.text = NSLocalizedString(title, @"");
    [label sizeToFit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - infinite scroll
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat actualPosition = scrollView.contentOffset.y;
    CGFloat contentHeight = scrollView.contentSize.height - self.tableView.frame.size.height;
    if (actualPosition >= contentHeight && self.isPaginationWorking == NO) {
        Tweet *tweet = [self.tweets lastObject ];
        int sinceID = [tweet.tweet_id intValue];
        [self loadMoreSince:sinceID];
    }
}

#pragma mark - UISearchResult Delegate methods
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    
    [self performSearch:searchString];
    
}

#pragma mark - UISearchBar delegate methods
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self updateSearchResultsForSearchController:self.searchController];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
   [self performSearch:searchText];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.filterTweets removeAllObjects];
    [self reload];
    
}

@end
