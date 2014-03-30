//
//  TwitterClient.h
//  Twitter
//
//  Created by Tripta Gupta on 3/29/14.
//  Copyright (c) 2014 Tripta Gupta. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"

@interface TwitterClient : BDBOAuth1RequestOperationManager

+ (TwitterClient *)instance;

- (void)login;

//User

- (AFHTTPRequestOperation *)homeTimeLineWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (AFHTTPRequestOperation *)getUserWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

//Status API

@end
