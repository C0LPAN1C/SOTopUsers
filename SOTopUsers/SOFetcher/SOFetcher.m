//
//  SOFetcher.m
//  SOTopUsers
//
//  Created by Amit Barman on 10/5/16.
//  Copyright (c) 2016 Apollo Software All rights reserved.
//

#import "SOFetcher.h"

#define STACKOVERFLOW_URL @"https://api.stackexchange.com/2.2/users?site=stackoverflow"

@implementation SOFetcher

+ (NSDictionary *)executeSOFetch:(NSString *)URL {
    NSLog(@"fetching %@", URL);
    NSData *jsonData = [[NSString stringWithContentsOfURL:[NSURL URLWithString:URL] encoding:NSUTF8StringEncoding error:nil] dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    
    NSDictionary *results = jsonData ? [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves error:&error] : nil;
    
    if (error) NSLog(@"[%@ %@] JSON error: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd), error.localizedDescription);
    
    NSLog(@"got user data from StackOverflow\n%@", results);
    
    return results;
}

+ (NSDictionary *)executeSOFetch {
    return [self executeSOFetch:STACKOVERFLOW_URL];
}

+ (NSArray *)topSOUsers {
    return [[self executeSOFetch] valueForKeyPath:SO_ITEMS];
}

+ (NSDictionary *)getUser:(NSArray *)user atIndex:(NSUInteger)index {
    return [NSDictionary dictionaryWithDictionary:[user objectAtIndex:index]];
}

@end
