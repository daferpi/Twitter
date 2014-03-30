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
        NSDictionary *dictionary = [[NSUserDefaults standardUserDefaults] objectForKey:@"current_user"];
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

- (User *)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    _data = dictionary;
    return self;
}

@end
