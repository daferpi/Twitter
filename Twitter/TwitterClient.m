//
//  TwitterClient.m
//  Twitter
//
//  Created by Tripta Gupta on 3/29/14.
//  Copyright (c) 2014 Tripta Gupta. All rights reserved.
//

#import "TwitterClient.h"

@implementation TwitterClient

// Singleton for Twitter Client
+ (TwitterClient *)instance
{
    static TwitterClient *instance = nil;
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        
    // Singleton of Twitter Client with keys and string for Twitter API
    instance = [[TwitterClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.twitter.com"]
                                          consumerKey:@"1mbRPtVqYmO6gS5FZpbvg"
                                       consumerSecret:@"ffrdIYENwgXNF9pZErWm5910PC544t4BDrV93NmN17Y"];
    });
    
    return instance;
}

//Required Authorization - login to twitter
- (void)login
{
    [self.requestSerializer removeAccessToken];
    
    // Fetches a request token with protocol handler to call back to. Returns a requestToken
    [self fetchRequestTokenWithPath:@"oauth/request_token"
                             method:@"POST"
                        callbackURL:[NSURL URLWithString:@"cptwitter://oauth"]
                              scope:nil
                            success:^(BDBOAuthToken *requestToken)
    {
        NSLog(@"Request Token Received");
        NSLog(@"Here is the token: %@", requestToken.token);
        
        // Creation of a string URL with the request token appended
        NSString *authURL = [NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.token];
        
        // Goes to the URL to authorize
        // Call back fires application:openURL:sourceApplication:annotation
        NSLog(@"Back to Twitter for authroization");
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:authURL]];
        
    } failure:^(NSError *error) {
        NSLog(@"Request token error: %@", [error description]);
    }];
}

// HomeTimeline API endpoint
- (AFHTTPRequestOperation *)homeTimeLineWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self GET:@"1.1/statuses/home_timeline.json" parameters:nil success:success failure:failure];
}

- (AFHTTPRequestOperation *)getUserWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    return [self GET:@"1.1/account/verify_credentials.json" parameters:nil success:success failure:failure];
}

- (void)homeTimelineWithCount:(int)count sinceId:(int)sinceId maxId:(int)maxId success:(void (^)(AFHTTPRequestOperation *operation, id response))success
                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{@"count": @(count)}];
    if (sinceId > 0) {
        [params setObject:@(sinceId) forKey:@"since_id"];
    }
    if (maxId > 0) {
        [params setObject:@(maxId) forKey:@"max_id"];
    }
    [self GET:@"1.1/statuses/home_timeline.json" parameters:params success:success failure:failure];
}

- (AFHTTPRequestOperation *)userTimelineWithScreenName:(NSString *)screenName success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    NSString *path = [NSString stringWithFormat:@"1.1/statuses/user_timeline.json?screen_name=%@", screenName];
    return [self GET:path parameters:nil success:success failure:failure];
}

- (void)updateStatus:(NSString *)status success:(void (^)(AFHTTPRequestOperation *operation, id response))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setObject:status forKey:@"status"];
    
    [self POST:@"https://api.twitter.com/1.1/statuses/update.json" parameters:params success:success failure:failure];
}

- (void)replyToTweetId:(NSString *)tweetId withStatus:(NSString *) status success:(void (^)(AFHTTPRequestOperation *operation, id response))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:status forKey:@"status"];
    [params setObject:tweetId forKey:@"in_reply_to_status_id"];
    [self POST:@"https://api.twitter.com/1.1/statuses/update.json" parameters:params success:success failure:failure];
}

- (void)favoriteWithTweetId:(NSString *)tweetId success:(void (^)(AFHTTPRequestOperation *operation, id response))success
                    failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:tweetId forKey:@"id"];
    [self POST:@"https://api.twitter.com/1.1/favorites/create.json" parameters:params success:success failure:failure];
}

- (void)retweetWithTweetId:(NSString *)tweetId success:(void (^)(AFHTTPRequestOperation *operation, id response))success
                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSString *path = [NSString stringWithFormat:@"https://api.twitter.com/1.1/statuses/retweet/%@.json", tweetId];
    [self POST:path parameters:nil success:success failure:failure];
}


//Tweets of Mentions

- (AFHTTPRequestOperation *) mentionsWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                         failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    return [self GET:@"1.1/statuses/mentions_timeline.json" parameters:nil success:success failure:failure];
}

- (void)searchTweetWithText:(NSString *)textToSearch success:(void (^)(AFHTTPRequestOperation *operation, id response))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:textToSearch forKey:@"q"];
    [self POST:@"https://api.twitter.com/1.1/search/tweets.json" parameters:params success:success failure:failure];
}


@end
