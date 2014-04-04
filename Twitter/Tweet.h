//
//  Tweet.h
//  Twitter
//
//  Created by Tripta Gupta on 3/27/14.
//  Copyright (c) 2014 Tripta Gupta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Tweet : NSObject

@property (nonatomic, strong) NSString *tweet_id;
@property (nonatomic, strong) NSString *in_reply_to_status_id;
@property (nonatomic, strong) NSString *tweet_text;
@property (nonatomic, strong) NSString *timestamp;
@property (nonatomic, strong) NSString *profile_image_url;
@property (nonatomic, strong) NSString *twitter_handle;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *relative_timestamp;
@property (nonatomic, strong) NSNumber *favoriteCount;
@property (nonatomic, strong) NSNumber *retweetCount;
@property (strong,nonatomic) User *user;

- (id)initWithDictionary:(NSDictionary *)dictionary;

+ (NSMutableArray *)tweetsWithArray:(NSArray *)array;

@end
