//
//  PS_DataRequest.m
//  iPhotoSocial
//
//  Created by MAXToooNG on 15/3/26.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_DataRequest.h"
#import "PS_DataRequestManager.h"
#import "AFHTTPRequestOperationManager.h"

@interface PS_DataRequest()
{
    
}
@property (nonatomic, strong) AFJSONRequestSerializer *requestSerializer;
@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@end
@implementation PS_DataRequest

- (id)init{
    self = [super init];
    if (self) {
        //初始化downloadData
        _requestSerializer = [AFJSONRequestSerializer serializer];
        
        [_requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [_requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        _manager = [AFHTTPRequestOperationManager manager];
        _manager.requestSerializer = _requestSerializer;
        _downloadData = [[NSMutableData alloc] init];
    }
    return self;
}

+ (PS_DataRequest *)getRequestWithUrlString:(NSString *)str target:(id)target action:(SEL)action tag:(NSInteger)tag{
    PS_DataRequest *request = [[PS_DataRequest alloc] init];
    request.requestString = str;
    request.target = target;
    request.action = action;
    request.tag = tag;

    //cache
    
//    NSString *path = [LCHTTPRequest pathWithUrlString:str];
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if ([fileManager fileExistsAtPath:path] && ![NSFileManager isTimeOutWithPath:path time:60*60]) {
//        //获取到指定路径下的data
//        NSData *data = [NSData dataWithContentsOfFile:path];
//        [request.downloadData setLength:0];
//        //将data给downloadData
//        [request.downloadData appendData:data];
//        //数据准备完毕后, 直接让target调用action进行后续实现
//        [request.target performSelector:request.action withObject:request];
//        
//        return request;
//    }else{
//        //发起请求
//        [request startRequest];
//    }
    
    [request startGetRequest];
    
    //将request对象加到manager字典中, 由manager来维护request
    [[PS_DataRequestManager shareDataRequestManager] addRequest:request forKey:str];
    
    
    
    return request;
}

- (void)startGetRequest
{
    [_manager GET:self.requestString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
    }];
}

@end
