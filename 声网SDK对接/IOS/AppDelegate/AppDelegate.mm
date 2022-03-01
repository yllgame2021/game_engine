#import "AppDelegate.h"
#import "ViewController.h"
#import <EgretNativeIOS.h>
#import "AgoraNativeIOS.h"

@interface AppDelegate()<AgoraNativeIOSDelegate>

@end

@implementation AppDelegate {
    EgretNativeIOS* _native;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSString* gameUrl = @"http://tool.egret-labs.org/Weiduan/game/index.html";
    
    _native = [[EgretNativeIOS alloc] init];
    _native.config.showFPS = true;
    _native.config.fpsLogTime = 30;
    _native.config.disableNativeRender = false;
    _native.config.clearCache = false;
    _native.config.useCutout = false;

    UIViewController* viewController = [[ViewController alloc] initWithEAGLView:[_native createEAGLView]];
    if (![_native initWithViewController:viewController]) {
        return false;
    }
    [self setExternalInterfaces];
    
    self.window = [_native window];
    
    NSString* networkState = [_native getNetworkState];
    if ([networkState isEqualToString:@"NotReachable"]) {
        __block EgretNativeIOS* native = _native;
        [_native setNetworkStatusChangeCallback:^(NSString* state) {
            if (![state isEqualToString:@"NotReachable"]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [native startGame:gameUrl];
                });
            }
        }];
        return true;
    }
    
    [_native startGame:gameUrl];
    
    return true;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [_native pause];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [_native resume];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}

- (void)setExternalInterfaces {
    __weak typeof(self) weakSelf = self;
    __block AgoraNativeIOS *agoraNavite = [[AgoraNativeIOS alloc] initWithSharedEngineWithAppId:@"" delegate:self];
    // 加入频道
    [_native setExternalInterface:@"joinChannel" Callback:^(NSString *message) {
        NSDictionary *dict = [weakSelf dictionaryWithJsonString:message];
        [weakSelf requestTokenWithChannelName:dict[@"channelname"] uid:dict[@"uid"] url:dict[@"url"] WithCompleteHandle:^(NSString *token) {
            AgoraRtcChannelMediaOptions *options = [[AgoraRtcChannelMediaOptions alloc] init];
            options.autoSubscribeAudio = true;
            options.autoSubscribeVideo = false;
            options.publishLocalAudio = false;
            options.publishLocalVideo = false;
            int result = [agoraNavite joinChannelByToken:token channelId:dict[@"channelname"] info:nil uid:[dict[@"uid"] integerValue] options:options];
            if (result == 0) {
                [agoraNavite enableAudioVolumeIndication:15 smooth:3 report_vad:false];
                [agoraNavite setEnableSpeakerphone:true];
            }
        }];
    }];
    // 设置角色
    [_native setExternalInterface:@"setClientRole" Callback:^(NSString *message) {
        AgoraClientRole role = AgoraClientRoleAudience;
        if ([message isEqualToString:@"1"]) {
            role = AgoraClientRoleBroadcaster;
        } else {
            role = AgoraClientRoleAudience;
        }
        [agoraNavite setClientRole:role];
    }];
    // AI降噪
    [_native setExternalInterface:@"enableDeepLearningDenoise" Callback:^(NSString *message) {
        BOOL result = [message isEqualToString:@"1"];
        [agoraNavite enableDeepLearningDenoise:result];
    }];
    // 离开频道
    [_native setExternalInterface:@"leaveChannel" Callback:^(NSString *message) {
        [agoraNavite leaveChannel:nil];
    }];
    // 切换 听筒/扬声器
    [_native setExternalInterface:@"setEnableSpeakerphone" Callback:^(NSString * message) {
        BOOL result = [message isEqualToString:@"2"];
        [agoraNavite setEnableSpeakerphone:result];
    }];
    // 麦克风 开启/关闭
    [_native setExternalInterface:@"muteLocalAudioStream" Callback:^(NSString * message) {
        BOOL result = [message isEqualToString:@"2"];
        [agoraNavite muteLocalAudioStream:result];
    }];
    // 音频接收 开启/关闭
    [_native setExternalInterface:@"muteAllRemoteAudioStreams" Callback:^(NSString *message) {
        BOOL result = [message isEqualToString:@"2"];
        [agoraNavite muteAllRemoteAudioStreams:result];
    }];
//    [_native setExternalInterface:@"sendToNative" Callback:^(NSString* message) {
//        NSString* str = [NSString stringWithFormat:@"Native get message: %@", message];
//        NSLog(@"%@", str);
//        [support callExternalInterface:@"sendToJS" Value:str];
//    }];
//    [_native setExternalInterface:@"@onState" Callback:^(NSString *message) {
//        NSLog(@"Get @onState: %@", message);
//    }];
//    [_native setExternalInterface:@"@onError" Callback:^(NSString *message) {
//        NSLog(@"Get @onError: %@", message);
//    }];
//    [_native setExternalInterface:@"@onJSError" Callback:^(NSString *message) {
//        NSLog(@"Get @onJSError: %@", message);
//    }];
}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

- (NSString *)dictionaryToJson:(NSDictionary *)dic {
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSString *)arrayToJsonString:(NSArray *)array{
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:&error];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];;
}

- (void)dealloc {
    [_native destroy];
}

#pragma mark - AgoraNativeIOSDelegate
- (void)rtcEngineConnectionDidLost:(AgoraRtcEngineKit *_Nonnull)engine {
    NSLog(@"网络中断");
    __block EgretNativeIOS *support = _native;
    [support callExternalInterface:@"onConnectionLost" Value:@""];
}

- (void)rtcEngine:(AgoraRtcEngineKit* _Nonnull)engine reportAudioVolumeIndicationOfSpeakers:(NSArray<AgoraRtcAudioVolumeInfo*>* _Nonnull)speakers totalVolume:(NSInteger)totalVolume {
    NSLog(@"用户音量提示回调");
    __block EgretNativeIOS *support = _native;
    NSMutableArray *arrayM = [NSMutableArray array];
    for (AgoraRtcAudioVolumeInfo *info in speakers) {
        NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
        if (info.uid == 0) {
            [dictM setValue:@"0" forKey:@"uid"];
        } else {
            [dictM setValue:[NSString stringWithFormat:@"%.0lu", (unsigned long)info.uid] forKey:@"uid"];
        }
        [dictM setValue:[NSString stringWithFormat:@"%.0lu", (unsigned long)info.volume] forKey:@"volume"];
        [arrayM addObject:dictM.copy];
    }
    NSString *json = [self arrayToJsonString:arrayM.copy];
    [support callExternalInterface:@"onAudioVolumeIndication" Value:json];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine networkQuality:(NSUInteger)uid txQuality:(AgoraNetworkQuality)txQuality rxQuality:(AgoraNetworkQuality)rxQuality {
    NSLog(@"通话中每个用户的网络上下行 last mile 质量报告回调");
    __block EgretNativeIOS *support = _native;
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    [dictM setValue:[NSString stringWithFormat:@"%.0lu", (unsigned long)uid] forKey:@"uid"];
    [dictM setValue:[NSString stringWithFormat:@"%.0lu", (unsigned long)txQuality] forKey:@"txQuality"];
    [dictM setValue:[NSString stringWithFormat:@"%.0lu", (unsigned long)rxQuality] forKey:@"rxQuality"];
    NSString *json = [self dictionaryToJson:dictM.copy];
    [support callExternalInterface:@"onNetworkQuality" Value:json];
}

- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didClientRoleChanged:(AgoraClientRole)oldRole newRole:(AgoraClientRole)newRole {
    NSLog(@"用户角色已切换回调");
    __block EgretNativeIOS *support = _native;
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    [dictM setValue:[NSString stringWithFormat:@"%.0lu", (unsigned long)oldRole] forKey:@"oldRole"];
    [dictM setValue:[NSString stringWithFormat:@"%.0lu", (unsigned long)newRole] forKey:@"newRole"];
    NSString *json = [self dictionaryToJson:dictM.copy];
    [support callExternalInterface:@"onClientRoleChanged" Value:json];
}

- (void)rtcEngine:(AgoraRtcEngineKit* _Nonnull)engine didAudioMuted:(BOOL)muted byUid:(NSUInteger)uid {
    NSLog(@"远端用户音频静音回调");
    __block EgretNativeIOS *support = _native;
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    NSString *value = [NSString stringWithFormat:@"%ld", uid];
    [dictM setValue:value forKey:@"uid"];
    [dictM setObject:@(muted) forKey:@"muted"];
    [support callExternalInterface:@"onUserMuteAudio" Value:[self dictionaryToJson:dictM.copy]];
}

- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    NSLog(@"远端用户（通信场景）/主播（直播场景）离开当前频道回调");
    __block EgretNativeIOS *support = _native;
    NSString *value = [NSString stringWithFormat:@"%ld", uid];
    [support callExternalInterface:@"onUserOffline" Value:value];
}

- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    NSLog(@"远端用户/主播加入回调");
    __block EgretNativeIOS *support = _native;
    NSString *value = [NSString stringWithFormat:@"%ld", uid];
    [support callExternalInterface:@"onUserJoined" Value:value];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didJoinChannel:(NSString *)channel withUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    NSLog(@"加入频道回调");
    __block EgretNativeIOS *support = _native;
    NSString *value = [NSString stringWithFormat:@"%ld", uid];
    [support callExternalInterface:@"onJoinChannelSuccess" Value:value];
}


- (void)rtcEngine:(AgoraRtcEngineKit *)engine didRejoinChannel:(NSString *)channel withUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    NSLog(@"重新加入频道回调");
    __block EgretNativeIOS *support = _native;
    NSString *value = [NSString stringWithFormat:@"%ld", uid];
    [support callExternalInterface:@"onJoinChannelSuccess" Value:value];
}

- (void)rtcEngine:(AgoraRtcEngineKit *)engine didLeaveChannelWithStats:(AgoraChannelStats *)stats {
    NSLog(@"已离开频道回调");
    __block EgretNativeIOS *support = _native;
    [support callExternalInterface:@"onLeaveChannel" Value:@""];
}

#pragma mark - Request
- (void)requestTokenWithChannelName:(NSString *)channelName uid:(NSString *)uid url:(NSString *)url WithCompleteHandle:(void(^)(NSString *))completeHandle {
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    [dictM setValue:@"enterRoom" forKey:@"name"];
    [dictM setValue:channelName forKey:@"channelName"];
    [dictM setValue:uid forKey:@"uid"];
    [dictM setValue:@"101" forKey:@"gameid"];
    NSMutableDictionary *dictM1 = [NSMutableDictionary dictionary];
    [dictM1 setObject:[self jsonStringEncoded:dictM] forKey:@"postdata"];
    NSString *args = [self getParamsString:dictM1];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
      cachePolicy:NSURLRequestUseProtocolCachePolicy
      timeoutInterval:30.0];
    NSMutableDictionary *mutableHeaders = [[NSMutableDictionary alloc] init];
    [mutableHeaders setValue:@"application/x-www-form-urlencoded" forKey:@"Content-Type"];
    
    [request setAllHTTPHeaderFields:mutableHeaders];
    [request setHTTPBody:[args dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPMethod:@"POST"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest: request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options: kNilOptions error:nil];
            NSLog(@"dict===>%@", dict);
            if ([dict[@"Data"] isKindOfClass:[NSString class]]) { //
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completeHandle) {
                        completeHandle(dict[@"Data"]);
                    }
                });
            }
        } else {
            // 处理网络报错
        }
    }];
    [task resume];
}

- (NSString *)getParamsString:(NSDictionary*)params {
    NSString *string = @"";
    for (NSString *key in params.allKeys) {
        string = [string stringByAppendingString:[NSString stringWithFormat:@"%@=%@&", key, params[key]]];
    }
    return [string substringWithRange:NSMakeRange(0, [string length] - 1)];
}

- (NSString *)jsonStringEncoded:(NSDictionary *)dict {
    if ([NSJSONSerialization isValidJSONObject:dict]) {
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        return json;
    }
    return nil;
}

@end
