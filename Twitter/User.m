//
//  User.m
//  Twitter
//
//  Created by Tripta Gupta on 3/27/14.
//  Copyright (c) 2014 Tripta Gupta. All rights reserved.
//

#import "User.h"
#import "TwitterClient.h"

NSString * const UserDidLoginNotification = @"UserDidLoginNotification";
NSString * const UserDidLogoutNotification = @"UserDidLogoutNotification";

@implementation User

static User *currentUser = nil;

+ (User *)currentUser
{
    if (currentUser == nil) {
        NSMutableDictionary *dictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"current_user"];
        if (dictionary) {
            currentUser = [[User alloc] initWithDictionary:dictionary];
        }
    }
    return currentUser;
}

+ (void)setCurrentUser:(User *)user
{
    if (user) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSJSONSerialization dataWithJSONObject:user.data
                                                                                         options:NSJSONWritingPrettyPrinted
                                                                                           error:nil]
                                                  forKey:@"current_user"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"current_user"];
    }
    
     [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Set currentUser to user & login notification
    if (currentUser == nil && user != nil) {
        currentUser = user;
        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLoginNotification object:nil];
    }
    // Set currentUser to nil & logout notification
    else if (currentUser != nil && user == nil) {
        currentUser = user;
        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogoutNotification object:nil];
    }
}

- (User *)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    _data = dictionary;
    
    if ([dictionary isKindOfClass:[NSDictionary class]]){
        NSLog(@"dictionary is a real dictionary!!!");
        _name              = dictionary[@"name"];
        _profile_image_url = dictionary[@"profile_image_url"];
        _screen_name       = dictionary[@"screen_name"];
        _followerCount     = dictionary[@"followers_count"];
        _friendCount       = dictionary[@"friends_count"];
        _statusCount       = dictionary[@"statuses_count"];
    } else {
        NSLog(@"dictionary is really a block of data");
        NSDictionary *newDictionary = [NSJSONSerialization JSONObjectWithData:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        _name              = newDictionary[@"name"];
        _profile_image_url = newDictionary[@"profile_image_url"];
        _screen_name       = newDictionary[@"screen_name"];
        _followerCount     = newDictionary[@"followers_count"];
        _friendCount       = newDictionary[@"friends_count"];
        _statusCount       = newDictionary[@"statuses_count"];
    }
    
    // Save in case shit gets cray (it got crazy)
    //    if (![dictionary isKindOfClass:[NSDictionary class]]){
    //        NSLog(@"dictionary is really a data block, not a dictionary");
    //        dictionary = [NSJSONSerialization JSONObjectWithData:dictionary options:NSJSONWritingPrettyPrinted error:nil];
    //    }
    //        _name              = dictionary[@"name"];
    //        _profile_image_url = dictionary[@"profile_image_url"];
    //        _screen_name       = dictionary[@"screen_name"];
    
    return self;
}

@end
