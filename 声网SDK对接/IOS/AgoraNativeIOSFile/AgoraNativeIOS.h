//
//  AgoraNativeIOS.h
//  yllbailudemo
//
//  Created by waha225 on 2021/8/25.
//  Copyright © 2021 egret. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgoraRtcKit/AgoraRtcEngineKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AgoraNativeIOSDelegate <NSObject>

@optional

#pragma mark - 网络相关
/** 网络连接中断，且 SDK 无法在 10 秒内连接服务器回调

 SDK 在调用 joinChannelByToken 后无论是否加入成功，只要 10 秒和服务器无法连接就会触发该回调。

 @param engine AgoraRtcEngineKit object.
 */
- (void)rtcEngineConnectionDidLost:(AgoraRtcEngineKit *_Nonnull)engine;

/** 本地网络类型发生改变回调

 本地网络连接类型发生改变时，SDK 会触发该回调，并在回调中明确当前的网络连接类型。
 你可以通过该回调获取正在使用的网络类型；当连接终端时，该回调能辨别引起中断的原因是网络切换还是网络条件不好。

@param engine AgoraRtcEngineKit object.
@param type 网络连接类型
*/
- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine networkTypeChangedToType:(AgoraNetworkType)type;

/** 网络连接状态已改变回调

该回调在网络连接状态发生改变的时候触发，并告知用户当前的网络连接状态，和引起网络状态改变的原因。

@param engine AgoraRtcEngineKit 对象
@param state 当前的网络连接状态。
@param reason 引起网络连接状态发生改变的原因。
*/
- (void)rtcEngine:(AgoraRtcEngineKit* _Nonnull)engine connectionChangedToState:(AgoraConnectionStateType)state reason:(AgoraConnectionChangedReason)reason;

/** 通话中每个用户的网络上下行 last mile 质量报告回调

 该回调描述每个用户在通话中的 last mile 网络状态，其中 last mile 是指设备到 Agora 边缘服务器的网络状态。
 该回调每 2 秒触发一次。如果远端有多个用户，该回调每 2 秒会被触发多次。

 @note 用户不发流时，txQuality 为 Unknown ；用户不收流时，rxQuality 为 Unknown 。

 @param engine   AgoraRtcEngineKit 对象
 @param uid       用户 ID。表示该回调报告的是持有该 ID 的用户的网络质量。当 uid 为 0 时，返回的是本地用户的网络质量。
 @param txQuality 该用户的上行网络质量。基于上行视频的发送码率、上行丢包率、平均往返时延和网络抖动计算。
 该值代表当前的上行网络质量，帮助判断是否可以支持当前设置的视频编码属性。假设上行码率是 500 Kbps，那么支持 480 x 480 的分辨率、30 fps 的帧率没有问题，但是支持 1280 x 720 的分辨率就会有困难。
 @param rxQuality 该用户的下行网络质量。基于下行网络的丢包率、平均往返延时和网络抖动计算。
 */
- (void)rtcEngine:(AgoraRtcEngineKit* _Nonnull)engine networkQuality:(NSUInteger)uid txQuality:(AgoraNetworkQuality)txQuality rxQuality:(AgoraNetworkQuality)rxQuality;

/** 发生错误回调

 该回调方法表示 SDK 运行时出现了（网络或媒体相关的）错误。通常情况下，SDK 上报的错误意味着 SDK 无法自动恢复，需要 App 干预或提示用户。 比如启动通话失败时，SDK 会上报 AgoraErrorCodeStartCall = 1002 错误。App 可以提示用户启动通话失败，并调用 leaveChannel 退出频道。

 @param engine    AgoraRtcEngineKit object
 @param errorCode Error code: AgoraErrorCode
 */
- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didOccurError:(AgoraErrorCode)errorCode;


#pragma mark - 频道相关
/** 加入频道回调

 该回调方法表示该客户端成功加入了指定的频道。同joinChannelByToken API 的 joinSuccessBlock 回调。

 @param engine  AgoraRtcEngineKit object.
 @param channel 频道名称
 @param uid  用户ID。 如果在joinChannelByToken方法中指定了 uid，它会返回指定的 ID; 如果没有，它将返回由 Agora 服务器自动分配的 ID。
 @param elapsed 从调用joinChannelByToken开始到发生此事件过去的时间（ms)。
 */
- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didJoinChannel:(NSString *_Nonnull)channel withUid:(NSUInteger)uid elapsed:(NSInteger)elapsed;

/** 重新加入频道回调

 有时候由于网络原因，客户端可能会和服务器失去连接，SDK 会进行自动重连，自动重连成功后触发此回调方法。

 @param engine  AgoraRtcEngineKit object.
 @param channel 频道名称
 @param uid  用户ID。 如果在joinChannelByToken方法中指定了 uid，它会返回指定的 ID; 如果没有，它将返回由 Agora 服务器自动分配的 ID。
 @param elapsed 从开始重连到重连成功的时间（ms）。
 */
- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didRejoinChannel:(NSString *_Nonnull)channel withUid:(NSUInteger)uid elapsed:(NSInteger)elapsed;

/** 已离开频道回调

 当用户调用 leaveChannel 离开频道后，SDK 会触发该回调。在该回调方法中，App 可以得到此次通话的总通话时长、SDK 收发数据的流量等信息。

 @param engine AgoraRtcEngineKit object.
 @param stats  Statistics of the call: [AgoraChannelStats](AgoraChannelStats).
 */
- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didLeaveChannelWithStats:(AgoraChannelStats *_Nonnull)stats;

/** 远端用户/主播加入回调

 通信场景下，该回调提示有远端用户加入了频道，并返回新加入用户的 ID；如果加入之前，已经有其他用户在频道中了，新加入的用户也会收到这些已有用户加入频道的回调。
 直播场景下，该回调提示有主播加入了频道，并返回该主播的 ID。如果在加入之前，已经有主播在频道中了，新加入的用户也会收到已有主播加入频道的回调。Agora 建议连麦主播不超过 17 人。

 该回调在如下情况下会被触发：
 远端用户/主播调用 joinChannelByToken 方法加入频道
 远端用户加入频道后调用 setClientRole 将用户角色改变为主播
 远端用户/主播网络中断后重新加入频道
 主播通过调用 addInjectStreamUrl 方法成功输入在线媒体流

 **Note:**

 直播场景下，
 主播间能相互收到新主播加入频道的回调，并能获得该主播的 uid
 观众也能收到新主播加入频道的回调，并能获得该主播的 uid
 当 Web 端加入直播频道时，只要 Web 端有推流，SDK 会默认该 Web 端为主播，并触发该回调

 @param engine  AgoraRtcEngineKit object.
 @param uid     新加入频道的远端用户/主播 ID。如果 joinChannelByToken 中指定了 uid，则此处返回该 ID；否则使用 Agora 服务器自动分配的 ID。
 @param elapsed 从本地用户加入频道 joinChannelByToken 或 joinChannelByUserAccount 开始到发生此事件过去的时间（ms）。
 */
- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed;

/** 远端用户（通信场景）/主播（直播场景）离开当前频道回调

 提示有远端用户/主播离开了频道（或掉线）。用户离开频道有两个原因，即正常离开和超时掉线：
 正常离开的时候，远端用户/主播会发送类似“再见”的消息，接收此消息后，判断用户离开频道。
 超时掉线的依据是，在一定时间内（通信场景为 20 秒，直播场景稍有延时），用户没有收到对方的任何数据包，则判定为对方掉线。在网络较差的情况下，有可能会误报。

 @param engine AgoraRtcEngineKit object.
 @param uid    离线的用户 ID。
 @param reason 离线原因
 */
- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason;

#pragma mark - 音量相关
/** 用户音量提示回调

 该回调默认禁用，你可以通过 enableAudioVolumeIndication 开启。 开启后，只要频道内有发流用户，SDK 会在加入频道后按 enableAudioVolumeIndication 中设置的时间间隔触发 reportAudioVolumeIndicationOfSpeakers 回调。每次会触发两个 reportAudioVolumeIndicationOfSpeakers 回调，一个报告本地发流用户的音量相关信息，另一个报告瞬时音量最高的远端 用户（最多 3 位）的音量相关信息。

 @note 如果有用户将自己静音（调用了 muteLocalAudioStream ），SDK 行为会受如下影响：

  - 本地用户静音后 SDK 立即停止报告本地用户的音量提示回调。
  - 瞬时音量最高的远端用户静音后 20 秒，远端的音量提示回调中将不再包含该用户；如果远端所有用户都将自己静音，20 秒后 SDK 停止报告远端用户的音量提示回调。

 @param engine      AgoraRtcEngineKit 对象。
 @param speakers    用户音量信息，详见 AgoraRtcAudioVolumeInfo 数组。如果 speakers 为空，则表示远端用户不发流或没有远端用户。
 @param totalVolume 混音后的总音量，取值范围为 [0,255]。
 - 在本地用户的回调中，totalVolume 为本地发流用户的音量。
 - 在远端用户的回调中，totalVolume 为瞬时音量最高的远端用户（最多 3 位）混音后的总音量。
 
 如果用户调用了 startAudioMixing，则 totalVolume 为音乐文件 和用户声音的总音量。
 */
- (void)rtcEngine:(AgoraRtcEngineKit* _Nonnull)engine reportAudioVolumeIndicationOfSpeakers:(NSArray<AgoraRtcAudioVolumeInfo*>* _Nonnull)speakers totalVolume:(NSInteger)totalVolume;

/** 远端用户音频静音回调

 该回调是由远端用户调用 muteLocalAudioStream 方法关闭或开启音频发送触发的。

 @note 当频道内的用户（通信场景）或主播（直播场景）的人数超过 17 时，该回调可能不准确。

 @param engine AgoraRtcEngineKit object.
 @param muted  该用户是否静音：
 * YES:静音
 * NO: 取消静音
 @param uid  远端用户 ID
 */
- (void)rtcEngine:(AgoraRtcEngineKit* _Nonnull)engine didAudioMuted:(BOOL)muted byUid:(NSUInteger)uid;

#pragma mark - Token相关
/** Token 服务即将过期回调

 在调用 joinChannelByToken 时如果指定了 Token，由于 Token 具有一定的时效，在通话过程中如果 Token 即将失效，SDK 会提前 30 秒触发该回调，提醒应用程序更新 Token。 当收到该回调时，用户需要重新在服务端生成新的 Token，然后调用 renewToken 将新生成的 Token 传给 SDK。

 @param engine AgoraRtcEngineKit 对象
 @param token 即将服务失效的 Token
 */
- (void)rtcEngine:(AgoraRtcEngineKit* _Nonnull)engine tokenPrivilegeWillExpire:(NSString* _Nonnull)token;

/** Token 过期回调

 在调用 joinChannelByToken joinChannelByToken:channelId:info:uid:joinSuccess:]) 时如果指定了 Token，由于 Token 具有一定的时效，在通话过程中 SDK 可能由于网络原因和服务器失去连接，重连时可能需要新的 Token。 该回调通知 App 需要生成新的 Token，然后调用 joinChannelByToken，使用新的 Token 重新加入频道。

 @param engine AgoraRtcEngineKit object.
 */
- (void)rtcEngineRequestToken:(AgoraRtcEngineKit *_Nonnull)engine;

#pragma mark - 其它
/** 用户角色已切换回调

 直播场景下，当本地用户在加入频道后调用 setClientRole 切换角色时会触发此回调，即主播切换为观众时，或观众切换为主播时。

 @param engine  AgoraRtcEngineKit object.
 @param oldRole 切换前的角色
 @param newRole 切换后的角色
 */
- (void)rtcEngine:(AgoraRtcEngineKit *_Nonnull)engine didClientRoleChanged:(AgoraClientRole)oldRole newRole:(AgoraClientRole)newRole;

@end


@interface AgoraNativeIOS : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)new NS_UNAVAILABLE;

#pragma mark - 初始化和销毁
/** 创建 AgoraRtcEngineKit 实例

  除非特别指定，AgoraRtcEngineKit实例提供的所有方法都是异步执行的。Agora建议在同一个线程中调用这些方法。
  **Note:**

  - 请确保在调用其他 API 前先调用该方法创建并初始化 AgoraRtcEngineKit。
  - 调用该方法和 sharedEngineWithConfig 均能创建 AgoraRtcEngineKit 实例。该方法与 sharedEngineWithConfig 的区别在于，sharedEngineWithConfig 支持在创建 AgoraRtcEngineKit实例时指定访问区域。
  - 目前 Agora RTC Native SDK 只支持每个 app 创建一个 AgoraRtcEngineKit 实例。

 @param appId   Agora 为 app 开发者签发的 App ID，详见获取 App ID。使用同一个 App ID 的 app 才能进入同一个频道进行通话或直播。一个 App ID 只能用于创建一个 AgoraRtcEngineKit。如需更换 App ID，必须先调用 destroy 销毁当前 AgoraRtcEngineKit，并在 destroy 成功返回后，再调用 sharedEngineWithAppId 重新创建 AgoraRtcEngineKit。

 @return - 方法调用成功，返回一个 AgoraRtcEngineKit 对象。
 - 方法调用失败，返回错误码。

  -1(AgoraErrorCodeFailed): 一般性的错误（未明确归类）
  -2(AgoraErrorCodeInvalidArgument): 未提供 AgoraRtcEngineDelegate 对象
  -7(AgoraErrorCodeNotInitialized): SDK 尚未初始化
  -101(AgoraErrorCodeInvalidAppId)：不是有效的 App ID。
 */
- (instancetype)initWithSharedEngineWithAppId:(NSString* _Nonnull)appId delegate:(id<AgoraNativeIOSDelegate> _Nullable)delegate;

/**
 销毁 AgoraRtcEngineKit 实例
 
 该方法释放 Agora SDK 使用的所有资源。有些 app 只在用户需要时才进行实时音视频通信，不需要时则将资源释放出来用于其他操作，该方法适用于此类情况。调用 destroy 方法后，你将无法再使用 SDK 的其它方法和回调。如需再次使用实时音视频通信功能，你必须重新调用 sharedEngineWithAppId 方法创建一个新的 AgoraRtcEngineKit 实例。
 
 **Notes**
  - 该方法为同步调用，需要等待 AgoraRtcEngineKit 实例资源释放后才能执行其他操作，所以我们建议在子线程中调用该方法，避免主线程阻塞。此外，我们不建议 在 SDK 的回调中调用 destroy，否则由于 SDK 要等待回调返回才能回收相关的对象资源，会造成死锁。
  - 如需在销毁后再次创建 AgoraRtcEngineKit 实例，需要等待destroy` 方法执行结束后再创建实例。
 */
- (void)destroy;

#pragma mark - 频道相关设置操作
/** 使用 token 加入频道

 该方法让用户加入通话频道，在同一个频道内的用户可以互相通话，多个用户加入同一个频道，可以群聊。 使用不同 App ID 的 App 是不能互通的。如果已在通话中，用户必须调用 leaveChannel 退出当前通话，才能进入下一个频道。SDK 在通话中使用 iOS 系统的 AVAudioSession 共享对象进行采集和播放， App 对该对象的操作可能会影响 SDK 的音频相关功能。

 调用该 API 后会触发 joinSuccessBlock 或 didJoinChannel 回调。block 比 delegate 优先级高，如果两种回调都实现了，只有 block 会触发。

 我们建议你将 joinSuccessBlock 设置为 nil，使用 delegate 回调。

 加入频道后，本地会触发 didJoinChannel 回调；通信场景下的用户和直播场景下的主播加入频道后，远端会触发 didJoinedOfUid 回调。

 用户成功加入频道后，默认订阅频道内所有其他用户的音频流和视频流，因此产生用量并影响计费。如果想取消订阅，可以通过调用相应的 mute 方法实现。

 在网络状况不理想的情况下，客户端可能会与 Agora 的服务器失去连接；SDK 会自动尝试重连，重连成功后，本地会触发 didRejoinChannel 回调。

**Note:**

- 频道内每个用户的 UID 必须是唯一的。如果将 UID 设为 0，系统将自动分配一个 UID。如果想要从不同的设备同时接入同一个频道，请确保每个设备上使用的 UID 是不同的。
- 在加入频道时，SDK 调用 setCategory(AVAudioSessionCategoryPlayAndRecord) 将 AVAudioSession 设置到 PlayAndRecord 模式， App 不应将其设置到其他模式。设置该模式时，正在播放的音频会被打断（比如正在播放的响铃声）。

 @param token 在你服务器上生成的 Token。( https://docs.agora.io/en/Interactive%20Broadcast/token_server?platform=All%20Platforms)
 @param channelId 标识通话频道的字符串，长度在 64 字节以内的字符串。以下为支持的字符集范围（共 89 个字符）:
 * 26 个小写英文字母 a-z
 * 26 个大写英文字母 A-Z
 * 10 个数字 0-9
 * 空格
 * “!” 、 “#” 、 “$” 、 “%” 、 “&” 、 “(” 、 “)” 、 “+” 、 “-” 、 “:” 、 “;” 、 “<” 、 “=” 、 “.” 、 “>” 、 “?” 、 “@” 、 “[” 、 “]” 、 “^” 、 “_” 、 “{” 、 “}” 、 “|” 、 “~” 、 “,”

@param info (非必选项) 开发者需加入的任何附加信息。一般可设置为空字符串，或频道相关信息。该信息不会传递给频道内的其他用户。
@param uid 用户 ID，32 位无符号整数。建议设置范围：1到 (232-1)，并保证唯一性。如果不填或设为 0，SDK 会自动分配一个，并在 joinSuccessBlock 回调方法中返回，App 层必须记住该返回值并维护，SDK 不对该返回值进行维护。
@param options 频道媒体设置选项：https://docs.agora.io/cn/Voice/API%20Reference/oc/Classes/AgoraRtcChannelMediaOptions.html

@return - 0(AgoraErrorCodeNoError): 方法调用成功
- < 0: 方法调用失败
  -2(AgoraErrorCodeInvalidArgument): 参数无效。
  -3(AgoraErrorCodeNotReady): SDK 初始化失败，请尝试重新初始化 SDK。
  -5(AgoraErrorCodeRefused)：调用被拒绝。可能有如下两个原因：
    1.已经创建了一个同名的 AgoraRtcChannel 频道。
    2.已经通过 AgoraRtcChannel 加入了一个频道，并在该 AgoraRtcChannel 频道中发布了音视频流。由于通过 AgoraRtcEngineKit 加入频道会默认发布音视频流，而 SDK 不支持同时在两个频道发布音视频流，因此会报错。
  -7(AgoraErrorCodeNotInitialized): SDK 尚未初始化，就调用其 API。请确认在调用 API 之前已创建 AgoraRtcEngineKit 并完成初始化。
*/
- (int)joinChannelByToken:(NSString* _Nullable)token channelId:(NSString* _Nonnull)channelId info:(NSString* _Nullable)info uid:(NSUInteger)uid options:(AgoraRtcChannelMediaOptions* _Nonnull)options;

/** 使用 User Account 加入频道

 该方法允许本地用户使用 User Account 加入频道。成功加入频道后，会触发以下回调：

- 本地：didRegisteredLocalUser 和 didJoinChannel 回调
- 远端：通信场景下的用户和直播场景下的主播加入频道后，远端会依次触发 didJoinedOfUid 和 didUpdatedUserInfo 回调

 用户成功加入频道后，默认订阅频道内所有其他用户的音频流和视频流，因此产生用量并影响计费。如果想取消订阅，可以通过调用相应的 mute 方法实现。

@note 请确保在使用 String 型用户名前阅读如何使用 String 型用户 ID，了解使用限制及实现方法。(https://docs.agora.io/cn/Voice/faq/string)
 为保证通信质量，请确保频道内使用同一类型的数据标识用户身份。即同一频道内需要统一使用 UID 或 User Account。如果有用户通过 Agora Web SDK 加入频道，请确保 Web 加入的用户也是同样类型。

@param userAccount 用户 User Account。该参数为必需，最大不超过 255 字节，不可为 nil。请确保加入频道的 User Account 的唯一性。 以下为支持的字符集范围（共 89 个字符）：

- 26 个小写英文字母 a-z
- 26 个大写英文字母 A-Z
- 10 个数字 0-9
- 空格
- “!” 、 “#” 、 “$” 、 “%” 、 “&” 、 “(” 、 “)” 、 “+” 、 “-” 、 “:” 、 “;” 、 “<” 、 “=” 、 “.” 、 “>” 、 “?” 、 “@” 、 “[” 、 “]” 、 “^” 、 “_” 、 “{” 、 “}” 、 “|” 、 “~” 、 “,”
@param token token 在你服务器上生成的 Token。( https://docs.agora.io/en/Interactive%20Broadcast/token_server?platform=All%20Platforms)
@param channelId 标识通话频道的字符串，长度在 64 字节以内的字符串。以下为支持的字符集范围（共 89 个字符）:
 * 26 个小写英文字母 a-z
 * 26 个大写英文字母 A-Z
 * 10 个数字 0-9
 * 空格
 * “!” 、 “#” 、 “$” 、 “%” 、 “&” 、 “(” 、 “)” 、 “+” 、 “-” 、 “:” 、 “;” 、 “<” 、 “=” 、 “.” 、 “>” 、 “?” 、 “@” 、 “[” 、 “]” 、 “^” 、 “_” 、 “{” 、 “}” 、 “|” 、 “~” 、 “,”
@param options 频道媒体设置选项：https://docs.agora.io/cn/Voice/API%20Reference/oc/Classes/AgoraRtcChannelMediaOptions.html

@return 0: 方法调用成功
* < 0: 方法调用失败
 - AgoraErrorCodeInvalidToken(110)：不是有效的 Token。请更换有效的 Token 重新加入频道。建议你进行如下检查：
 - 检查生成 Token 的 uid 与 joinChannelByUserAccount 方法中的 uid 是否一致
 - 检查 Token 的格式是否有效
 - 检查 Token 与 App ID 是否匹配
*/
- (int)joinChannelByUserAccount:(NSString *_Nonnull)userAccount token:(NSString *_Nullable)token channelId:(NSString *_Nonnull)channelId options:(AgoraRtcChannelMediaOptions *_Nonnull)options;

/** 离开频道

 离开频道，即挂断或退出通话。

 当调用 joinChannelByToken 方法后，必须调用 leaveChannel 结束通话，否则无法开始下一次通话。 不管当前是否在通话中，都可以调用本方法，没有副作用。该方法会把会话相关的所有资源释放掉。该方法是异步操作，调用返回时并没有真正退出频道。

 成功调用该方法离开频道后，本地会触发 didLeaveChannelWithStats 回调；通信场景下的用户和直播场景下的主播离开频道后，远端会触发 didOfflineOfUid(AgoraUserOfflineReasonBecomeAudience) 回调。

**Note:**
 
- 如果你调用了本方法后立即调用 destroy 方法，SDK 将无法触发 didLeaveChannelWithStats 回调。
- 如果你在旁路推流时调用本方法， SDK 将自动调用 removePublishStreamUrl 方法。
- 在调用本方法时，iOS 默认情况下 SDK 会停用 audio session，可能会对其他应用程序造成影响。如果想改变这种默认行为，可以通过setAudioSessionOperationRestriction 方法设置 AgoraAudioSessionOperationRestrictionDeactivateSession，这样在 leaveChannel 时，SDK 不会停用 audio session。

 @param leaveChannelBlock 成功离开频道的回调，提供通话相关的统计信息。

 @return - 0(AgoraErrorCodeNoError): 方法调用成功
- < 0: 方法调用失败
  -1(AgoraErrorCodeFailed): 一般性的错误（未明确归类）
  -2(AgoraErrorCodeInvalidArgument): 参数无效
  -7(AgoraErrorCodeNotInitialized): SDK 尚未初始化
 */
- (int)leaveChannel:(void (^_Nullable)(AgoraChannelStats* _Nonnull stat))leaveChannelBlock;

#pragma mark - 音频相关设置操作
/** 设置默认的音频路由。

 如果 SDK 默认的音频路由（见《设置音频路由》）无法满足你的需求， 你可以调用该方法切换默认的音频路由。成功切换音频路由后，SDK 会触发 didAudioRouteChanged 回调提示音频路由已更改。
 
 **Note**
 该方法仅适用于 iOS 平台。
 该方法需要在 joinChannelByToken 前调用。如需在加入频道后切换音频路由，请调用 setEnableSpeakerphone。
 如果用户使用了蓝牙耳机、有线耳机等外接音频播放设备，则该方法的设置无效， 音频只会通过外接设备播放。当有多个外接设备时，音频会通过最后一个接入的设备播放。

 @param defaultToSpeaker 设置默认的音频路由：

   - `YES`: 默认的音频路由为扬声器。
   - `NO`: 默认的音频路由为听筒。

 @return - 0: Success.
 - < 0: Failure.
 */
- (int)setDefaultAudioRouteToSpeakerphone:(BOOL)defaultToSpeaker;

/** 开启/关闭扬声器播放。

 如果 SDK 默认的音频路由（见《设置音频路由》）或 setDefaultAudioRouteToSpeakerphone 的设置无法满足你的需求，你可以调用 setEnableSpeakerphone 切换当前的音频路由。 成功切换音频路由后，SDK 会触发 didAudioRouteChanged 回调提示音频路由已更改。

 该方法只设置用户在当前频道内使用的音频路由，不会影响 SDK 默认的音频路由。 如果用户离开当前频道并加入新的频道，则用户还是会使用 SDK 默认的音频路由。

 **Notes**

 - 该方法仅适用于 iOS 平台。
 - 该方法需要在 joinChannelByToken 后调用。
 - 如果用户使用了蓝牙耳机、有线耳机等外接音频播放设备，则该方法的设置无效， 音频只会通过外接设备播放。当有多个外接设备时，音频会通过最后一个接入的设备播放。

 @param enableSpeaker 设置是否开启扬声器播放：

  - `YES`: 开启。音频路由为扬声器。
  - `NO`: 关闭。音频路由为听筒。

 @return * 0: Success.
 * < 0: Failure.
 */
- (int)setEnableSpeakerphone:(BOOL)enableSpeaker;

/** 调节麦克风采集信号音量

 该方法在加入频道前后都能调用。

 @param volume 麦克风采集信号音量。取值范围为 [0,100]。默认值为 100，表示原始音量。

 @return * 0: 方法调用成功
* < 0: 方法调用失败
 */
- (int)adjustRecordingSignalVolume:(NSInteger)volume;

/** 开关本地音频采集

 当 App 加入频道时，它的语音功能默认是开启的。该方法可以关闭或重新开启本地语音功能，即停止或重新开始本地音频采集。该方法在加入频道前后都能调用。
 该方法不影响接收远端音频流，enableLocalAudio(NO) 适用于只听不发的用户场景。
 语音功能关闭或重新开启后，会收到 localAudioStateChange 回调并报告 AgoraAudioLocalStateStopped(0) 或 AgoraAudioLocalStateRecording(1)。

**Note:**

 该方法与 muteLocalAudioStream 的区别在于：
  - enableLocalAudio：开启或关闭本地语音采集及处理。使用 enableLocalAudio 关闭或开启本地采集后，本地听远端播放会有短暂中断。
  - muteLocalAudioStream：停止或继续发送本地音频流。

 @param enabled * YES: 重新开启本地语音功能，即开启本地语音采集（默认）
 * NO: 关闭本地语音功能，即停止本地语音采集或处理
 @return * 0: 方法调用成功
* < 0: 方法调用失败
 */
- (int)enableLocalAudio:(BOOL)enabled;

/** 取消或恢复发布本地音频流。

 自 v3.4.5 起，该方法仅设置用户在 AgoraRtcEngineKit 频道中的音频发布状态。
 成功调用该方法后，远端会触发 didAudioMuted 回调。
 同一时间，本地的音视频流只能发布到一个频道。如果你创建了多个频道，请确保你只在一个频道中调用 muteLocalAudioStream(NO)，否则方法会调用失败并返回 -5 (AgoraErrorCodeRefused)。

 **Note:**

 - 该方法不会改变音频采集设备的使用状态。
 - 该方法的调用是否生效受 joinChannelByToken 和 setClientRole 方法的影响，详见《设置发布状态》。

 @param mute 是否取消发布本地音频流：

 * YES: 取消发布。
 * NO: 发布。

 @return * 0: 方法调用成功。
* < 0: 方法调用失败。
 -5 (AgoraErrorCodeRefused): 调用被拒绝。
 */
- (int)muteLocalAudioStream:(BOOL)mute;

/** 取消或恢复订阅指定远端用户的音频流。

 **Note:**

 - 该方法需要在加入频道后调用。
 - 该方法的推荐设置详见《设置订阅状态》。

 @param uid  指定用户的用户 ID。
 @param mute 是否取消订阅指定远端用户的音频流。
 specified user.

 * YES: 取消订阅。
 * NO: （默认）订阅。

 @return * 0: 方法调用成功
* < 0: 方法调用失败
 */
- (int)muteRemoteAudioStream:(NSUInteger)uid mute:(BOOL)mute;

/** 取消或恢复订阅所有远端用户的音频流。

 成功调用该方法后，本地用户会取消或恢复订阅所有远端用户的音频流， 包括在调用该方法后加入频道的用户的音频流。

 **Note**

 - 该方法需要在加入频道后调用。

 @param mute 是否取消订阅所有远端用户的音频流。

 * YES: 取消订阅。
 * NO: （默认）订阅。

 @return *0: 方法调用成功
*< 0: 方法调用失败
 */
- (int)muteAllRemoteAudioStreams:(BOOL)mute;

/** 启用用户音量提示

 该方法允许 SDK 定期向 app 报告本地发流用户和瞬时音量最高的远端用户（最多 3 位）的音量相关信息。启用该方法后，只要频道内有发流用户，SDK 会在加入频道后按设置的时间间隔触发 reportAudioVolumeIndicationOfSpeakers 回调。

 该方法在加入频道后才能调用。

 @param interval 指定音量提示的时间间隔：

 * ≤ 0: 禁用音量提示功能
 * 0: 提示间隔，单位为毫秒。建议设置到大于 200 毫秒。最小不得少于 10 毫秒。

 @param smooth 指定音量提示的灵敏度。取值范围为 [0,10]，建议值为 3，数字越大，波动越灵敏；数字越小，波动越平滑。
 @param report_vad - YES: 开启本地人声检测功能。开启后， reportAudioVolumeIndicationOfSpeakers 回调的 vad 参数会报告是否在本地检测到人声。
 - NO: （默认）关闭本地人声检测功能。除引擎自动进行本地人声检测的场景外， reportAudioVolumeIndicationOfSpeakers 回调的 vad 参数不会报告是否在本地检测到人声。

 @return * 0: Success.
* < 0: Failure.
 */
- (int)enableAudioVolumeIndication:(NSInteger)interval smooth:(NSInteger)smooth report_vad:(BOOL)report_vad;

#pragma mark - Token相关设置操作
/** 更新 Token

 该方法用于更新 Token。如果启用了 Token 机制，过一段时间后使用的 Token 会失效。当以下任意一种情况发生时：
  - tokenPrivilegeWillExpire 回调。
  - connectionChangedToState 回调的 reason 参数报告 AgoraConnectionChangedTokenExpired(9)。

 App 应重新获取 Token，然后调用该 API 更新 Token，否则 SDK 无法和服务器建立连接。

 @param token 新的 Token

 @return - 0(AgoraErrorCodeNoError): 方法调用成功
- < 0: 方法调用失败
  -1(AgoraErrorCodeFailed): 一般性的错误（未明确归类）
  -2(AgoraErrorCodeInvalidArgument): 参数无效
  -7(AgoraErrorCodeNotInitialized): SDK 尚未初始化
 */
- (int)renewToken:(NSString *_Nonnull)token;

#pragma mark - 优化相关设置操作
/** 开启或关闭 AI 降噪模式。

 SDK 默认开启传统降噪模式，以消除大部分平稳噪声。如果你还需要消除非平稳噪声，Agora 推荐你按如下步骤开启 AI 降噪模式：

 确保已集成如下库：

 1. iOS: AgoraAIDenoiseExtension.xcframework
   macOS: AgoraAIDenoiseExtension.framework
 2. 调用 enableDeepLearningDenoise(YES)。

 AI 降噪模式对设备性能有要求。只有在设备性能良好的情况下，SDK 才会成功开启 AI 降噪模式。支持在如下设备及其之后的型号中开启 AI 降噪模式：

 iPhone 6S
 MacBook Pro 2015
 iPad Pro 第二代
 iPad mini 第五代
 iPad Air 第三代

 成功开启 AI 降噪模式后，如果 SDK 检测到当前设备的性能不足，SDK 会自动关闭 AI 降噪模式，并开启传统降噪模式。

 在频道内，如果你调用了 enableDeepLearningDenoise(NO) 或 SDK 自动关闭了 AI 降噪模式，当你需要重新开启 AI 降噪模式时， 你需要先调用 leaveChannel，再调用 enableDeepLearningDenoise(YES)。
 **Note**

 -该方法需要动态加载 AgoraAIDenoiseExtension 库，所以 Agora 推荐在加入频道前调用该方法。
 该方法对人声的处理效果最佳，Agora 不推荐调用该方法处理含音乐的音频数据。
 
 @param enabled Sets whether to enable deep-learning noise reduction.

 - `YES`: (Default) Enables deep-learning noise reduction.
 - `NO`: Disables deep-learning noise reduction.

 @return * 0: Success.
 * < 0: Failure.
   * -`157`(`AgoraErrorCodeModuleNotFound`): The library for enabling deep-learning noise reduction is not integrated.
 */
- (int)enableDeepLearningDenoise:(BOOL)enabled;

#pragma mark - 其它设置操作
/** 设置直播场景下的用户角色。

 调用 setChannelProfile(AgoraChannelProfileLiveBroadcasting) 后，SDK 会默认设置用户角色为观众，你可以调用 setClientRole 设置用户角色为主播。
 该方法在加入频道前后均可调用。如果你在加入频道后调用该方法切换用户角色，调用成功后，SDK 会自动进行如下操作：

 - 调用 muteLocalAudioStream 和 muteLocalVideoStream 修改发布状态。
 - 本地触发 didClientRoleChanged。
 - 远端触发 didJoinedOfUid 或 didOfflineOfUid(AgoraUserOfflineReasonBecomeAudience)。
 
 @param role 直播场景里的用户角色
 - `AgoraClientRoleBroadcaster(1)`:主播。主播既可以发流也可以收流。
 - `AgoraClientRoleAudience(2)`: 观众。观众只能收流不能发流。

 @return - `0`(`AgoraErrorCodeNoError`): Success.
 - < `0`: Failure.
  -1(AgoraErrorCodeFailed): 一般性的错误（未明确归类）。
  -2(AgoraErrorCodeInvalidArgument): 参数无效。
  -7(AgoraErrorCodeNotInitialized): SDK 尚未初始化。
  -5 (AgoraErrorCodeRefused): 调用被拒绝。在多频道场景中， 如果你已在一个频道中进行如下设置，则用户在另一个频道内切换角色为主播时会返回该错误
    - 调用带 options 参数的 joinChannelByToken， 并使用默认设置 publishLocalAudio = YES 或 publishLocalVideo = YES。
    - 调用 setClientRole，并设置用户角色为主播。
    - 调用 muteLocalAudioStream(NO) 或 muteLocalVideoStream(NO)。
 */
- (int)setClientRole:(AgoraClientRole)role;

@end

NS_ASSUME_NONNULL_END
