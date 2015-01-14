//
//  VDDReachability.m
//  GimVic
//
//  Created by Vid Drobnič on 10/11/14.
//  Copyright (c) 2014 Vid Drobnič. All rights reserved.
//

#import "VDDReachability.h"

@implementation VDDReachability

#pragma mark - Checking Connection

+ (BOOL)checkInternetConnection {
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://app.gimvic.org/internetCheck.html"]];
    return data == nil ? NO : YES;
}

@end