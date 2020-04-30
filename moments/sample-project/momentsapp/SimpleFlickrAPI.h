//
//  SimpleFlickrAPI.h
//  PhotoWheel
//
//  Created by Kirby Turner on 10/2/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SimpleFlickrAPI : NSObject

// Returns a set of photos matching the search string.

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *dob;
@property (nonatomic, strong) NSString *pageno;
@property (nonatomic, strong) NSString *locationid;
@property (nonatomic, strong) NSString *menufeature;

- (NSArray *)photosWithSearchString:(NSString *)feature;
- (NSDictionary *)loginProcess:(NSArray *)menuFeature;
- (NSDictionary *)signinProcess:(NSArray *)menuFeature;
- (NSArray *)barFinder:(NSString *)menuFeature :(NSString *)menuid ;
- (NSArray *)comments:(NSString *)menuFeature :(NSString *)menuType :(NSString *)menuid;
- (NSArray *)add_comments:(NSString *)menuFeature :(NSString *)menuType :(NSString *)menuid :(NSString *)key :(NSString *)content;
- (NSDictionary *)likes:(NSString *)menuFeature :(NSString *)menuType :(NSString *)menuid :(NSString *)key;
- (NSArray *)gridloader:(NSString *)menuFeature :(NSString *)menuid :(NSString *)pagecount;
- (NSDictionary *)profile:(NSString *)menuFeature :(NSString *)menuType :(NSString *)menuid;
- (NSDictionary *)fblogin:(NSString *)emailadd;
- (NSDictionary *)updateprofile:(NSArray *)menuFeature;
- (NSDictionary *)forgotpassword:(NSArray *)menuFeature;

@end
