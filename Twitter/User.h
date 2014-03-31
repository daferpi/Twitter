//
//  User.h
//  Twitter
//
//  Created by Tripta Gupta on 3/27/14.
//  Copyright (c) 2014 Tripta Gupta. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const UserDidLoginNotification;
extern NSString *const UserDidLogoutNotification;

@interface User : NSObject

+ (User *)currentUser;
+ (void)setCurrentUser:(User *)user;
- (User *)initWithDictionary:(NSDictionary*)dictionary;

@property (nonatomic, strong) NSDictionary *data;
@property (nonatomic, strong) NSString *profile_image_url;
@property (nonatomic, strong) NSString *screen_name;
@property (nonatomic, strong) NSString *name;

@end
