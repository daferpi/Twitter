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
                                       consumerSecret:@"ffrdIYENwgXNF9pZErWm5910PC544t4BDrV93NmN17Y" ];
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

@end
