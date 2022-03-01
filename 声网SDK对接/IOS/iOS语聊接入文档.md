# iOS 语聊接入文档

- 该接入文档API只限 Egret 平台使用, 语聊具体功能方法在AgoraNativeIOS.h和AgoraNativeIOS.mm文件内([下载](https://github.com/yllgame2021/yllgamesdk/tree/master/%E8%AF%AD%E8%81%8ASDK/iOS/AgoraNativeIOSFile)), 如在其他平台使用可参考此文件

## 1.接入前环境配置

### 1.1 需要安装cocoapods管理工具([参考](https://www.kancloud.cn/god-is-coder/cocoapods/617031))

### 1.2配置项目

#### 1.2.1 cd 到 xxx.xcodeproj 目录下，pod init 创建pod管理文件

#### 1.2.2 在podfile文件中添加以下依赖库
```obj-c
  pod 'AgoraAudio_iOS', '~> 3.5.0.3'
```
#### 1.2.3 然后执行 pod install

## 2. 代码集成

### 2.1 将AgoraNativeIOS.h和AgoraNativeIOS.mm文件([下载](https://github.com/yllgame2021/yllgamesdk/tree/master/%E8%AF%AD%E8%81%8ASDK/iOS/AgoraNativeIOSFile))拖进相对应的项目Target下面

### 2.2 在项目中对应的xxx.h文件导入
```obj-c
#import "AgoraNativeIOS.h"
```

### 2.3 初始化
```obj-c
__block AgoraNativeIOS *agoraNavite = [[AgoraNativeIOS alloc] initWithSharedEngineWithAppId:@"AppId" delegate:self];
```

### 2.4 遵循代理
```obj-c
@interface AppDelegate()<AgoraNativeIOSDelegate>
```

## 3. API

- 详情请参考以下文件([跳转](https://github.com/yllgame2021/yllgamesdk/tree/master/%E8%AF%AD%E8%81%8ASDK/iOS/AppDelegate))
  
### 3.1事件(用户触发)
```obj-c
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
```
  
### 3.2 回调(SDK触发) - AgoraNativeIOSDelegate
```obj-c
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
```

### 3.3 tool方法
```obj-c
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
```
  
