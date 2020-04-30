
//
//  SimpleFlickrAPI.m
//  PhotoWheel
//
//  Created by Kirby Turner on 10/2/11.
//  Copyright (c) 2011 White Peak Software Inc. All rights reserved.
//

#import "SimpleFlickrAPI.h"
#import <Foundation/NSJSONSerialization.h>

#define flickrBaseURL @"http://208.109.186.98/starcmssite/api/"
#define flickrClient @"ios"

@interface SimpleFlickrAPI ()
- (id)flickrJSONSWithParameters:(NSString *)feature;
@end

@implementation SimpleFlickrAPI

@synthesize username, password, email, phone, dob, locationid, menufeature, pageno;

- (NSArray *)photosWithSearchString:(NSString *)menuFeature
{
    NSDictionary *json = [self flickrJSONSWithParameters:menuFeature];
    NSArray *photos = [json objectForKey:menuFeature];
    return photos;
}

- (NSArray *)barFinder:(NSString *)menuFeature :(NSString *)menuid
{
    /*
    NSLog(@"barFinder ::: menuFeature ::: %@",menuFeature);
    NSLog(@"barFinder ::: menuid ::: %@",menuid);
    */
    
    locationid = menuid;
    
    menuFeature = [menuFeature isEqualToString:@"video uploads"] ? @"get_uploads": menuFeature;
    menuFeature = [menuFeature isEqualToString:@"audio uploads"] ? @"uploads": menuFeature;
    
    NSDictionary *json = [self flickrJSONSWithParameters:menuFeature];
    
    menuFeature = [menuFeature isEqualToString:@"uploads"] ? @"audio_uploads": menuFeature;
    menuFeature = [menuFeature isEqualToString:@"get_uploads"] ? @"video_uploads": menuFeature;
    menuFeature = [menuFeature isEqualToString:@"adverts"] ? @"brand-adverts": menuFeature;
    
    NSArray *photos = [json objectForKey:menuFeature];
    return photos;
}

- (NSArray *)gridloader:(NSString *)menuFeature :(NSString *)menuid :(NSString *)pagecount
{
    /*
    NSLog(@"gridloader ::: menuFeature ::: %@",menuFeature);
    NSLog(@"gridloader ::: menuid ::: %@",menuid);
    NSLog(@"gridloader ::: pagecount ::: %@",pagecount);
    */
    
    pageno = pagecount;
    locationid = menuid;
    
    menuFeature = [menuFeature isEqualToString:@"video uploads"] ? @"get_uploads": menuFeature;
    menuFeature = [menuFeature isEqualToString:@"audio uploads"] ? @"uploads": menuFeature;
    
    NSDictionary *json = [self flickrJSONSWithParameters:menuFeature];
    
    menuFeature = [menuFeature isEqualToString:@"uploads"] ? @"audio_uploads": menuFeature;
    menuFeature = [menuFeature isEqualToString:@"get_uploads"] ? @"video_uploads": menuFeature;
    menuFeature = [menuFeature isEqualToString:@"adverts"] ? @"brand-adverts": menuFeature;
    NSArray *photos = [json objectForKey:menuFeature];
    
    return photos;
}

- (NSArray *)comments:(NSString *)menuFeature :(NSString *)menuType :(NSString *)menuid
{
    
    NSLog(@"Inside comments :::: ");
    NSLog(@"menuFeature ::: %@",menuFeature);
    NSLog(@"menuType ::::: %@", menuType);
    NSLog(@"menuid :::: %@",menuid);
    
    locationid = menuid;
    menufeature = menuFeature;
    
    NSLog(@"Inside comments :::: ");
    NSLog(@"locationid ::: %@",locationid);
    NSLog(@"menufeature :::: %@",menufeature);
    NSLog(@"menuType ::::: %@", menuType);
    
    NSDictionary *json = [self flickrJSONSWithParameters:menuType];
    NSArray *photos = [menuType isEqualToString:@"comments"] ? [json objectForKey:menuType] : [json objectForKey:menuFeature];
    
    //NSLog(@"Leaving SimpleFlickApi ::: comments :::: %@", photos);
    
    return photos;
}

- (NSDictionary *)profile:(NSString *)menuFeature :(NSString *)menuType :(NSString *)menuid
{
    /*
    NSLog(@"Inside SimpleFlickApi ::: comments :::: ");
    NSLog(@"menuFeature ::: %@",menuFeature);
    NSLog(@"menuType ::::: %@", menuType);
    NSLog(@"menuid :::: %@",menuid);
    */
    
    locationid = menuid;
    pageno = menuType;
    
    NSDictionary *json = [self flickrJSONSWithParameters:menuFeature];
    NSDictionary *photos = [json objectForKey:menuFeature];
    
    //NSLog(@"Leaving SimpleFlickApi ::: comments :::: %@", photos);
    
    return photos;
}


- (NSArray *)add_comments:(NSString *)menuFeature :(NSString *)menuType :(NSString *)menuid :(NSString *)key :(NSString *)content
{
    
    NSLog(@"Inside SimpleFlickApi ::: comments :::: ");
    NSLog(@"menuFeature ::: %@",menuFeature);
    NSLog(@"menutype ::: %@",menuType);
    NSLog(@"menuid ::::: %@", menuid);
    NSLog(@"key :::: %@",key);
    NSLog(@"content :::: %@",content);
    

    menufeature = menuFeature;
    locationid = menuid;
    password = key;
    email = content;
    
    NSLog(@"Inside add_comments :::: ");
    NSLog(@"menufeature ::: %@",menufeature);
    NSLog(@"locationid ::: %@",locationid);
    NSLog(@"password ::::: %@", password);
    NSLog(@"email :::: %@",email);
    NSLog(@"menuType :::: %@",menuType);
    
    
    NSDictionary *json = [self flickrPostJSONSWithParameters:menuType];
    NSArray *photos = [json objectForKey:menuType];
    return photos;
}


- (NSDictionary *)likes:(NSString *)menuFeature :(NSString *)menuType :(NSString *)menuid :(NSString *)key
{
    
     NSLog(@"Inside SimpleFlickApi ::: comments :::: ");
     NSLog(@"menutype ::: %@",menuType);
     NSLog(@"menuid ::::: %@", menuid);
     NSLog(@"key :::: %@",key);
     NSLog(@"menuFeature :::: %@",menuFeature);
    
    
    menufeature = menuFeature;
    locationid = menuid;
    password = key;
    
    NSLog(@"Inside likes :::: ");
    NSLog(@"menufeature ::: %@",menufeature);
    NSLog(@"locationid ::: %@",locationid);
    NSLog(@"password ::::: %@", password);
    NSLog(@"menuType :::: %@",menuType);
    
    NSDictionary *json = [self flickrPostJSONSWithParameters:menuType];
    NSLog(@"likes json :::: %@",json);
    
    return json;
}


- (NSDictionary *)fblogin:(NSString *)emailadd
{
    
    email = emailadd;
    
    NSDictionary *photos = [self flickrJSONSWithParameters:@"fblogin"];
   
    return photos;
}


- (NSDictionary *)loginProcess:(NSArray *)menuFeature
{
    NSString *feature = [menuFeature objectAtIndex:0];
    username = [menuFeature objectAtIndex:1];
    password = [menuFeature objectAtIndex:2];
    
    NSDictionary *photos = [self flickrPostJSONSWithParameters:feature];
    
    return photos;
     
}

- (NSDictionary *)signinProcess:(NSArray *)menuFeature
{
    username = [menuFeature objectAtIndex:1];
    phone = [menuFeature objectAtIndex:2];
    email = [menuFeature objectAtIndex:3];
    password = [menuFeature objectAtIndex:4];
    dob = [menuFeature objectAtIndex:5];
    
    NSDictionary *photos = [self flickrPostJSONSWithParameters:[menuFeature objectAtIndex:0]];

    return photos;
    
}

- (NSDictionary *)updateprofile:(NSArray *)menuFeature
{
    menufeature = [menuFeature objectAtIndex:0];
    username = [menuFeature objectAtIndex:1];
    email = [menuFeature objectAtIndex:2];
    phone = [menuFeature objectAtIndex:3];
    dob = [menuFeature objectAtIndex:4];
    
    NSDictionary *photos = [self flickrPostJSONSWithParameters:[menuFeature objectAtIndex:0]];
    
    return photos;
    
}


- (NSDictionary *)forgotpassword:(NSArray *)menuFeature
{
    menufeature = [menuFeature objectAtIndex:0];
    email = [menuFeature objectAtIndex:1];
    
    NSDictionary *photos = [self flickrPostJSONSWithParameters:[menuFeature objectAtIndex:0]];
    
    return photos;
}


- (NSData *)fetchResponseWithURL:(NSURL *)URL
{
    //NSLog(@"Am here now :::: ");
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    //NSLog(@"request %@",request);
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (data == nil)
    {
        NSLog(@"%s: Error: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
    }
    return data;
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    //NSLog(@"Error connecting 1 :::::::");
    return nil;
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *) error
{
    //NSLog(@"Error connecting 2 :::::::");
}

- (NSData *)fetchResponseWithPostURL:(NSURL *)URL : (NSString *)feature
{
    NSString *body = @"";
    
    if ([feature isEqualToString:@"login"])
    {
        body = [NSString stringWithFormat:@"username=%@&pwd=%@&client=%@",username,password,flickrClient];
    }
    else if ([feature isEqualToString:@"forgotpassword"])
    {
        body = [NSString stringWithFormat:@"username=%@&client=%@",username,flickrClient];
    }
    else if ([feature isEqualToString:@"signin"])
    {
        body = [NSString stringWithFormat:@"username=%@&pwd=%@&email=%@&phone=%@&dob=%@&client=%@",username,password,email,phone,dob,flickrClient];
    }
    else if ([feature isEqualToString:@"update"])
    {
        body = [NSString stringWithFormat:@"key=%@&email=%@&phone=%@&client=%@&dob=%@",username,email,phone,flickrClient,dob];
    }
    else if ([feature isEqualToString:@"add_comment"])
    {
        NSString *idtype = @"";
        NSString *feature2 = @"";
        
        if([menufeature isEqualToString:@"audios"])
            feature2 = @"audio";
        else if([menufeature isEqualToString:@"video uploads"])
            feature2 = @"videos";
        else if([menufeature isEqualToString:@"audio uploads"])
            feature2 = @"audio_upload";
        else
            feature2 = menufeature;
        
        idtype = [self getID:feature2];
        
        body = [NSString stringWithFormat:@"key=%@&%@=%@&content=%@&client=%@",password,idtype,locationid,email,flickrClient];
         NSLog(@"body of add_comment ::::: %@",body);
    }
    else if ([feature isEqualToString:@"like"])
    {
        NSString *idtype = @"";
        NSString *feature2 = @"";
        
        if([menufeature isEqualToString:@"audios"])
            feature2 = @"audio";
        else if([menufeature isEqualToString:@"video uploads"])
            feature2 = @"videos";
        else if([menufeature isEqualToString:@"audio uploads"])
            feature2 = @"audio_upload";
        else
            feature2 = menufeature;
        
        idtype = [self getID:feature2];
        
        body = [NSString stringWithFormat:@"key=%@&%@=%@&client=%@",password,idtype,locationid,flickrClient];
        NSLog(@"body of like ::::: %@",body);
    }
    
    
    NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:URL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:[body dataUsingEncoding:NSASCIIStringEncoding]];
    
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    if (data == nil)
    {
        //NSLog(@"%s: Error: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
    }
    
    return data;
}

-(NSString *)getID:(NSString *)feature
{
    NSString* idtype = @"";
    
    if ([feature isEqualToString:@"gallery"])
        idtype = @"gid";
    else if ([feature isEqualToString:@"videos"])
        idtype = @"vid";
    else if ([feature isEqualToString:@"news"])
        idtype = @"nid";
    else if ([feature isEqualToString:@"events"])
        idtype = @"eid";
    else if ([feature isEqualToString:@"contests"])
        idtype = @"cid";
    else if ([feature isEqualToString:@"blogs"])
        idtype = @"bid";
    else if ([feature isEqualToString:@"adverts"])
        idtype = @"bid";
    else if ([feature isEqualToString:@"audio"])
        idtype = @"aid";
    else if ([feature isEqualToString:@"audio_upload"])
        idtype = @"aid";
    
    return idtype;
}


- (NSURL *)buildFlickrURLWithParameters:(NSString *)feature
{
    NSMutableString *URLString = [[NSMutableString alloc] initWithString:flickrBaseURL];
    //NSLog(@"URLString 1 ::: %@",URLString);
    
    if ([feature isEqualToString:@"gallery"])
    {
        locationid = [locationid isEqualToString:@"0"] ? @"new_releases": locationid;
        locationid = [locationid isEqualToString:@"1"] ? @"top_favorites": locationid;
        locationid = [locationid isEqualToString:@"2"] ? @"star_gallery": locationid;
        
        [URLString appendString:[NSString stringWithFormat:@"gallery/%@?page=%@&format=json",locationid,pageno]];
        //NSLog(@"URLString ::: %@",URLString);
    }
    else if ([feature isEqualToString:@"videos"])
    {
        locationid = [locationid isEqualToString:@"0"] ? @"new_releases": locationid;
        locationid = [locationid isEqualToString:@"1"] ? @"top20": locationid;
        locationid = [locationid isEqualToString:@"2"] ? @"star_videos": locationid;
        locationid = [locationid isEqualToString:@"3"] ? @"free_downloads": locationid;
        
        [URLString appendString:[NSString stringWithFormat:@"videos/%@?page=%@&format=json",locationid,pageno]];
        //NSLog(@"URLString ::: %@",URLString);
    }
    else if ([feature isEqualToString:@"get_uploads"])
    {
        [URLString appendString:@"videos/get_uploads?format=json"];
    }
    else if ([feature isEqualToString:@"uploads"])
    {
        [URLString appendString:@"audio_upload/uploads?format=json"];
        //NSLog(@"URLString 2 ::: %@",URLString);
    }
    else if ([feature isEqualToString:@"adverts"])
    {
        //locationid = [locationid isEqualToString:@"0"] ? @"new_releases": locationid;
        //locationid = [locationid isEqualToString:@"1"] ? @"top20": locationid;
        
        [URLString appendString:@"adverts?format=json"];
        //NSLog(@"URLString ::: %@",URLString);
    }
    else if ([feature isEqualToString:@"news"])
    {
        locationid = [locationid isEqualToString:@"0"] ? @"breaking": locationid;
        locationid = [locationid isEqualToString:@"1"] ? @"foreign": locationid;
        locationid = [locationid isEqualToString:@"2"] ? @"local": locationid;
        
        [URLString appendString:[NSString stringWithFormat:@"news/%@?page=%@&format=json",locationid,pageno]];
        //NSLog(@"URLString ::: %@",URLString);
    }
    else if ([feature isEqualToString:@"blogs"])
    {
        [URLString appendString:[NSString stringWithFormat:@"blogs?page=%@&format=json",pageno]];
    }
    else if ([feature isEqualToString:@"events"])
    {
        [URLString appendString:[NSString stringWithFormat:@"events?page=%@&format=json",pageno]];
    }
    else if ([feature isEqualToString:@"contests"])
    {
        [URLString appendString:[NSString stringWithFormat:@"contests?page=%@&format=json",pageno]];
    }
    else if ([feature isEqualToString:@"audios"])
    {
        [URLString appendString:[NSString stringWithFormat:@"audio?page=%@&format=json",pageno]];
    }
    else if ([feature isEqualToString:@"locations"])
    {
        [URLString appendString:@"bars/locations?"];
    }
    else if ([feature isEqualToString:@"bars"])
    {
        [URLString appendString:[NSString stringWithFormat:@"bars/location?id=%@",locationid]];
    }
    else if ([feature isEqualToString:@"comments"])
    {
        NSString *idtype = @"";
        NSString *feature2 = @"";
        
        if([menufeature isEqualToString:@"audios"])
            feature2 = @"audio";
        else if([menufeature isEqualToString:@"video uploads"])
            feature2 = @"videos";
        else if([menufeature isEqualToString:@"audio uploads"])
            feature2 = @"audio_upload";
        else
            feature2 = menufeature;
        
        idtype = [self getID:feature2];
        
        [URLString appendString:[NSString stringWithFormat:@"%@/comments?%@=%@",feature2,idtype,locationid]];
        
    }
    else if ([feature isEqualToString:@"search"])
    {
        NSString *cPayload = [locationid stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [URLString appendString:[NSString stringWithFormat:@"%@/search?q=%@",menufeature,cPayload]];
        //NSLog(@"%@",[NSString stringWithFormat:@"%@/search?q=%@",menufeature,locationid]);
    }
    else if ([feature isEqualToString:@"login"])
    {
        [URLString appendString:@"users/login?"];
    }
    else if ([feature isEqualToString:@"fblogin"])
    {
        [URLString appendString:[NSString stringWithFormat:@"users/api_key?email=%@",email]];
    }
    else if ([feature isEqualToString:@"signin"])
    {
        [URLString appendString:@"users/create?"];
    }
    else if ([feature isEqualToString:@"forgotpassword"])
    {
        [URLString appendString:@"users/forgotpwd?"];
    }
    else if ([feature isEqualToString:@"update"])
    {
        [URLString appendString:@"users/update?"];
    }
    else if ([feature isEqualToString:@"profile"])
    {
        [URLString appendString:[NSString stringWithFormat:@"users/profile?username=%@&key=%@&format=json",pageno,locationid]];
    }
    else if ([feature isEqualToString:@"add_comment"])
    {
        NSString *feature2 = @"";
        
        if([menufeature isEqualToString:@"audios"])
            feature2 = @"audio";
        else if([menufeature isEqualToString:@"video uploads"])
            feature2 = @"videos";
        else if([menufeature isEqualToString:@"audio uploads"])
            feature2 = @"audio_upload";
        else
            feature2 = menufeature;
        
        [URLString appendString:[NSString stringWithFormat:@"%@/add_comment",feature2]];
        
        NSLog(@"URLString :::: %@",URLString);
    }
    else if ([feature isEqualToString:@"like"])
    {
        NSString *feature2 = @"";
        
        if([menufeature isEqualToString:@"audios"])
            feature2 = @"audio";
        else if([menufeature isEqualToString:@"video uploads"])
            feature2 = @"videos";
        else if([menufeature isEqualToString:@"audio uploads"])
            feature2 = @"audio_upload";
        else
            feature2 = menufeature;
        
        [URLString appendString:[NSString stringWithFormat:@"%@/like",feature2]];
        
        NSLog(@"URLString :::: %@",URLString);
    }
    else 
    {
        [URLString appendString:@"news?format=json"];
    }
    
    NSURL *URL = [NSURL URLWithString:URLString];
    return URL;
    
}

- (id)flickrJSONSWithParameters:(NSString *)feature
{
    NSURL *URL = [self buildFlickrURLWithParameters:feature];
    NSData *data = [self fetchResponseWithURL:URL];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    //NSLog(@"%s: json: %@", __PRETTY_FUNCTION__, string);
    
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:jsonData
                                              options:NSJSONReadingAllowFragments
                                                error:&error];
    if (json == nil)
    {
        NSLog(@"%s: Error: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
    }
    
    return json;
}


- (id)flickrPostJSONSWithParameters:(NSString *)feature
{
    NSURL *URL = [self buildFlickrURLWithParameters:feature];
    NSData *data = [self fetchResponseWithPostURL:URL:feature];
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    //NSLog(@"%s: json: %@", __PRETTY_FUNCTION__, string);
    
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:jsonData
                                              options:NSJSONReadingAllowFragments
                                                error:&error];
    if (json == nil)
    {
        NSLog(@"%s: Error: %@", __PRETTY_FUNCTION__, [error localizedDescription]);
    }
    
    return json;
}

@end
