//
//  AgoraNativeIOS.m
//  yllbailudemo
//
//  Created by waha225 on 2021/8/25.
//  Copyright © 2021 egret. All rights reserved.
//

#import "AgoraNativeIOS.h"
#import <EgretNativeIOS.h>

@interface AgoraNativeIOS()<AgoraRtcEngineDelegate>
// 定义 agoraKit 变量
@property (strong, nonatomic) AgoraRtcEngineKit *agoraKit;

@property (nonatomic, weak) id<AgoraNativeIOSDelegate> delegate;

@end

@implementation AgoraNativeIOS

- (instancetype)initWithSharedEngineWithAppId:(NSString* _Nonnull)appId delegate:(id<AgoraNativeIOSDelegate> _Nullable)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.agoraKit = [AgoraRtcEngineKit sharedEngineWithAppId:appId delegate:self];
        [self.agoraKit setChannelProfile:AgoraChannelProfileCommunication];
//        [self.agoraKit setAudioProfile:AgoraAudioProfileSpeechStandard scenario:AgoraAudioScenarioChatRoomEntertainment];
    }
    return self;
}

- (int)joinChannelByToken:(NSString* _Nullable)token channelId:(NSString* _Nonnull)channelId info:(NSString* _Nullable)info uid:(NSUInteger)uid options:(AgoraRtcChannelMediaOptions* _Nonnull)options {
    return [self.agoraKit joinChannelByToken:token channelId:channelId info:info uid:uid options:options];
}

- (int)joinChannelByUserAccount:(NSString *_Nonnull)userAccount token:(NSString *_Nullable)token channelId:(NSString *_Nonnull)channelId options:(AgoraRtcChannelMediaOptions *_Nonnull)options {
    return [self.agoraKit joinChannelByUserAccount:userAccount token:token channelId:channelId options:options];
}

- (int)leaveChannel:(void (^_Nullable)(AgoraChannelStats* _Nonnull stat))leaveChannelBlock {
    return [self.agoraKit leaveChannel:leaveChannelBlock];
}

- (int)setEnableSpeakerphone:(BOOL)enableSpeaker {
    return [self.agoraKit setEnableSpeakerphone:enableSpeaker];
}

- (int)adjustRecordingSignalVolume:(NSInteger)volume {
    return [self.agoraKit adjustRecordingSignalVolume:volume];
}

- (int)enableAudioVolumeIndication:(NSInteger)interval smooth:(NSInteger)smooth report_vad:(BOOL)report_vad {
    return [self.agoraKit enableAudioVolumeIndication:interval smooth:smooth report_vad:report_vad];
}

- (int)enableLocalAudio:(BOOL)enabled {
    return [self.agoraKit enableLocalAudio:enabled];
}

- (int)muteLocalAudioStream:(BOOL)mute {
    return [self.agoraKit muteLocalAudioStream:mute];
}

- (int)muteRemoteAudioStream:(NSUInteger)uid mute:(BOOL)mute {
    return [self.agoraKit muteRemoteAudioStream:uid mute:mute];
}

- (int)muteAllRemoteAudioStreams:(BOOL)mute {
    return [self.agoraKit muteAllRemoteAudioStreams:mute];
}

- (int)setClientRole:(AgoraClientRole)role {
    return [self.agoraKit setClientRole:role];
}

- (int)setDefaultAudioRouteToSpeakerphone:(BOOL)defaultToSpeaker {
    return [self.agoraKit setDefaultAudioRouteToSpeakerphone:defaultToSpeaker];
}

- (void)destroy {
    [AgoraRtcEngineKit destroy];
}

- (int)renewToken:(NSString *_Nonnull)token {
    return [self.agoraKit renewToken:token];
}

- (int)enableDeepLearningDenoise:(BOOL)enabled {
    return [self.agoraKit enableDeepLearningDenoise:enabled];
}

#pragma mark AgoraRtcEngineDelegate
- (void)rtcEngine:(AgoraRtcEngineKit* _Nonnull)engine reportAudioVolumeIndicationOfSpeakers:(NSArray<AgoraRtcAudioVolumeInfo*>* _Nonnull)speakers totalVolume:(NSInteger)totalVolume {
    if ([self.delegate respondsToSelector:@selector(rtcEngine:reportAudioVolumeIndicationOfSpeakers:totalVolume:)]) {
        [self.delegate rtcEngine:engine reportAudioVolumeIndicationOfSpeakers:speakers totalVolume:totalVolume];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit* _Nonnull)engine networkQuality:(NSUInteger)uid txQuality:(AgoraNetworkQuality)txQuality rxQuality:(AgoraNetworkQuality)rxQuality {
    if ([self.delegate respondsToSelector:@selector(rtcEngine:networkQuality:txQuality:rxQuality:)]) {
        [self.delegate rtcEngine:engine networkQuality:uid txQuality:txQuality rxQuality:rxQuality];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit* _Nonnull)engine connectionChangedToState:(AgoraConnectionStateType)state reason:(AgoraConnectionChangedReason)reason {
    if ([self.delegate respondsToSelector:@selector(rtcEngine:connectionChangedToState:reason:)]) {
        [self.delegate rtcEngine:engine connectionChangedToState:state reason:reason];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit* _Nonnull)engine tokenPrivilegeWillExpire:(NSString* _Nonnull)token {
    if ([self.delegate respondsToSelector:@selector(rtcEngine:tokenPrivilegeWillExpire:)]) {
        [self.delegate rtcEngine:engine tokenPrivilegeWillExpire:token];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didLeaveChannelWithStats:(AgoraChannelStats *_Nonnull)stats {
    if ([self.delegate respondsToSelector:@selector(rtcEngine:didLeaveChannelWithStats:)]) {
        [self.delegate rtcEngine:engine didLeaveChannelWithStats:stats];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didJoinChannel:(NSString *_Nonnull)channel withUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    if ([self.delegate respondsToSelector:@selector(rtcEngine:didJoinChannel:withUid:elapsed:)]) {
        [self.delegate rtcEngine:engine didJoinChannel:channel withUid:uid elapsed:elapsed];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didRejoinChannel:(NSString *_Nonnull)channel withUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    if ([self.delegate respondsToSelector:@selector(rtcEngine:didRejoinChannel:withUid:elapsed:)]) {
        [self.delegate rtcEngine:engine didRejoinChannel:channel withUid:uid elapsed:elapsed];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didOccurError:(AgoraErrorCode)errorCode {
    if ([self.delegate respondsToSelector:@selector(rtcEngine:didOccurError:)]) {
        [self.delegate rtcEngine:engine didOccurError:errorCode];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didClientRoleChanged:(AgoraClientRole)oldRole newRole:(AgoraClientRole)newRole {
    if ([self.delegate respondsToSelector:@selector(rtcEngine:didClientRoleChanged:newRole:)]) {
        [self.delegate rtcEngine:engine didClientRoleChanged:oldRole newRole:newRole];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed {
    if ([self.delegate respondsToSelector:@selector(rtcEngine:didJoinedOfUid:elapsed:)]) {
        [self.delegate rtcEngine:engine didJoinedOfUid:uid elapsed:elapsed];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason {
    if ([self.delegate respondsToSelector:@selector(rtcEngine:didOfflineOfUid:reason:)]) {
        [self.delegate rtcEngine:engine didOfflineOfUid:uid reason:reason];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine networkTypeChangedToType:(AgoraNetworkType)type {
    if ([self.delegate respondsToSelector:@selector(rtcEngine:networkTypeChangedToType:)]) {
        [self.delegate rtcEngine:engine networkTypeChangedToType:type];
    }
}

- (void)rtcEngineConnectionDidLost:(AgoraRtcEngineKit *_Nonnull)engine {
    if ([self.delegate respondsToSelector:@selector(rtcEngineConnectionDidLost:)]) {
        [self.delegate rtcEngineConnectionDidLost:engine];
    }
}

- (void)rtcEngineRequestToken:(AgoraRtcEngineKit *_Nonnull)engine {
    if ([self.delegate respondsToSelector:@selector(rtcEngineRequestToken:)]) {
        [self.delegate rtcEngineRequestToken:engine];
    }
}

- (void)rtcEngine:(AgoraRtcEngineKit* _Nonnull)engine didAudioMuted:(BOOL)muted byUid:(NSUInteger)uid {
    if ([self.delegate respondsToSelector:@selector(rtcEngine:didAudioMuted:byUid:)]) {
        [self.delegate rtcEngine:engine didAudioMuted:muted byUid:uid];
    }
}

@end
