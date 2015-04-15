//
//  PS_DataRequest.m
//  iPhotoSocial
//
//  Created by MAXToooNG on 15/3/26.
//  Copyright (c) 2015年 Chen.Liu. All rights reserved.
//

#import "PS_DataRequestManager.h"
#import "AFHTTPRequestOperationManager.h"
#import <CommonCrypto/CommonCrypto.h>

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
        
//        _manager = [AFHTTPRequestOperationManager manager];
//        _manager.requestSerializer = _requestSerializer;
//        _downloadData = [[NSMutableData alloc] init];
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
    
//    [request startGetRequest];
    
    //将request对象加到manager字典中, 由manager来维护request
    [[PS_DataRequestManager shareDataRequestManager] addRequest:request forKey:str];
    
    
    
    return request;
}

/**
 *  网络请求接口
 *
 *  @param url        请求 Url
 *  @param params      请求参数字典
 *  @param httpMethod 请求方法 "GET" or "POST"
 *  @param block       回调
 *
 *  @return 返回 RequestOperation
 */

+ (AFHTTPRequestOperation *)requestWithURL:(NSString *)url params:(NSMutableDictionary *)params httpMethod:(NSString *)httpMethod block:(CompletionLoad)block errorBlock:(ErrorCallBack)errorR
{
    //创建request请求管理对象
    AFHTTPRequestOperationManager * manager =[AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation * operation = nil;
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    manager.requestSerializer = requestSerializer;
    //GET请求
    NSComparisonResult comparison1 = [httpMethod caseInsensitiveCompare:@"GET"];
    if (comparison1 == NSOrderedSame) {
        operation =[manager GET:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            block(responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            errorR(error);
            
        }];
    }
    //POST请求
    NSComparisonResult comparisonResult2 = [httpMethod caseInsensitiveCompare:@"POST"];
    if (comparisonResult2 == NSOrderedSame)
    {
        //标示
        BOOL isFile = NO;
        for (NSString * key in params.allKeys)
        {
            id value = params[key];
            //判断请求参数是否是文件数据
            if ([value isKindOfClass:[NSData class]]) {
                isFile = YES;
                break;
            }
        }
        if (!isFile) {
            //参数中没有文件，则使用简单的post请求
            operation =[manager POST:url
                          parameters:params
                             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                 if (block != nil) {
                                     block(responseObject);
                                 }
                             } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                 errorR(error);
                             }];
        }
        else
        {
            operation =[manager POST:url
                          parameters:params
           constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
               for (NSString *key in params) {
                   id value = params[key];
                   if ([value isKindOfClass:[NSData class]]) {
                       [formData appendPartWithFileData:value
                                                   name:key
                                               fileName:key
                                               mimeType:@"image/jpeg"];
                   }
               }
           } success:^(AFHTTPRequestOperation *operation, id responseObject) {
               block(responseObject);
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               errorR(error);
               NSLog(@"请求网络失败");
               
           }];
            
        }
        
    }
    
    //POST请求
    NSComparisonResult comparisonResult3 = [httpMethod caseInsensitiveCompare:@"DELETE"];
    if (comparisonResult3 == NSOrderedSame)
    {
        //标示
//        BOOL isFile = NO;
//        for (NSString * key in params.allKeys)
//        {
//            id value = params[key];
//            //判断请求参数是否是文件数据
//            if ([value isKindOfClass:[NSData class]]) {
//                isFile = YES;
//                break;
//            }
//        }
//        if (!isFile) {
        
        operation = [manager DELETE:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (block != nil) {
                block(responseObject);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            if (block != nil) {
                
            }
        }];
        
//        }
//        else
//        {
//            operation =[manager POST:url
//                          parameters:params
//           constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//               for (NSString *key in params) {
//                   id value = params[key];
//                   if ([value isKindOfClass:[NSData class]]) {
//                       [formData appendPartWithFileData:value
//                                                   name:key
//                                               fileName:key
//                                               mimeType:@"image/jpeg"];
//                   }
//               }
//           } success:^(AFHTTPRequestOperation *operation, id responseObject) {
//               block(responseObject);
//           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//               
//               NSLog(@"请求网络失败");
//               
//           }];
//            
//        }
        
    }

    
    //设置返回数据的解析方式
    
    operation.responseSerializer =[AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    
    return operation;
    
}

///url为请求地址，params是请求体，传字典进去，，httpMethod 是请求方式，block是请求完成做得工作，header是请求头，也是传字典过去（发送请求获得json数据）,如果没有则传nil,如果只有value而没有key，则key可以设置为anykey


+ (AFHTTPRequestOperation *)requestWithURL:(NSString *)url
                             requestHeader:(NSDictionary *)header
                                    params:(NSMutableDictionary *)params
                                httpMethod:(NSString *)httpMethod
                                     block:(CompletionLoad)block
{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:10];
    //添加请求头
    for (NSString *key in header.allKeys) {
        [request addValue:header[key] forHTTPHeaderField:key];
    }
    //get请求
    NSComparisonResult compResult1 =[httpMethod caseInsensitiveCompare:@"GET"];
    if (compResult1 == NSOrderedSame) {
        [request setHTTPMethod:@"GET"];
        if(params != nil)
        {
            //添加参数，将参数拼接在url后面
            NSMutableString *paramsString = [NSMutableString string];
            NSArray *allkeys = [params allKeys];
            for (NSString *key in allkeys) {
                NSString *value = [params objectForKey:key];
                [paramsString appendFormat:@"&%@=%@", key, value];
            }
            if (paramsString.length > 0) {
                [paramsString replaceCharactersInRange:NSMakeRange(0, 1) withString:@"?"];
                //重新设置url
                [request setURL:[NSURL URLWithString:[url stringByAppendingString:paramsString]]];
            }
        }
    }
    //post请求
    NSComparisonResult compResult2 = [httpMethod caseInsensitiveCompare:@"POST"];
    if (compResult2 == NSOrderedSame) {
        [request setHTTPMethod:@"POST"];
        for (NSString *key in params) {
            [request setHTTPBody:params[key]];
        }
    }
    //发送请求
    AFHTTPRequestOperation *requstOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    //设置返回数据的解析方式(这里暂时只设置了json解析)
    requstOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    [requstOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (block != nil) {
            block(responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"Error: %@", [error localizedDescription]);
        
        if (block != nil) {
            
            block(error);
            
        }
        
    }];
    
    [requstOperation start];
    
    return requstOperation;
    
}

//
//
//- (void)startGetRequest
//{
//    [_manager GET:self.requestString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//    }];
//}

-(NSString *)signWithKey:(NSString *)key usingData:(NSString *)data
{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSData *HMAC = [[NSData alloc] initWithBytes:cHMAC length:sizeof(cHMAC)];
    
    return [[HMAC.description stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
}

-(NSString*)getheaderData
{
    NSString *ipString = [self getIPAddress];
    NSString *signature = [self signWithKey:kClientSecret usingData:ipString];
    return signature;
}

- (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    // Free memory
    freeifaddrs(interfaces);
    
    return address;
}

@end
