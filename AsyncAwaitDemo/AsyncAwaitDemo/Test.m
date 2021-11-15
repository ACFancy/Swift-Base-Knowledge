//
//  Test.m
//  AsyncAwaitDemo
//
//  Created by Lee Danatech on 2021/11/15.
//

#import "Test.h"
@import UIKit;
#import "AsyncAwaitDemo-Swift.h"

@implementation Test


- (instancetype)init {
    if (self = [super init]) {
        ViewController *vc = [ViewController new];
        [vc calculate2WithInput:100 completionHandler:^(NSInteger value) {
            NSLog(@"%zd", value);
        }];
        [vc calculate3WithInput:300 completionHandler:^(NSInteger value) {
            NSLog(@"%zd", value);
        }];
    }
    return self;
}

@end
