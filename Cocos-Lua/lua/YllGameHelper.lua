
local YllGameHelper = class("YllGameHelper")
local targetPlatform = cc.Application:getInstance():getTargetPlatform()
local activityClassName = "org/cocos2dx/lua/AppActivity"

--设置网络模式，强/弱联网
function YllGameHelper:setNetModel(NetModel)
	if device.platform == "android" then
		local luaj = require "cocos.cocos2d.luaj"
		local args = {NetModel}
		local signs = "(I)V"
		local ok,ret = luaj.callStaticMethod(activityClassName, "setNetModel", args, signs)
		return ok
	elseif(device.platform == "ios") then
		local args = {net = NetModel}
		local luaoc = require "cocos.cocos2d.luaoc"
		local className = "RootViewController"
		local ok,ret = luaoc.callStaticMethod(className,"setNetModel",args)
		return ok
	end
end
--登陆
function YllGameHelper:login()
	local callback = handler(self, self.onLoginCallBack)
	if device.platform == "android" then
		local luaj = require "cocos.cocos2d.luaj"
		local args = {callback}
		local signs = "(I)V"
		local ok,ret = luaj.callStaticMethod(activityClassName, "login", args, signs)
		if not ok then
			print("call init fail"..ret)
		end
	elseif(device.platform == "ios") then
		local args = {
			luaFun = callback
		}
		local luaoc = require "cocos.cocos2d.luaoc"
		local className = "RootViewController"
		local ok,ret = luaoc.callStaticMethod(className,"login",args)
	else
		local jsonString = "{'loginCode':1,'openUserId':123456,'nickName':'userNickName','accessToken':'123'}"
		callback(jsonString)
	end
end

--游客登陆
function YllGameHelper:loginGuest()
	local callback = handler(self, self.onLoginCallBack)
	if device.platform == "android" then
		local luaj = require "cocos.cocos2d.luaj"
		local args = {callback}
		local signs = "(I)V"
		local ok,ret = luaj.callStaticMethod(activityClassName, "loginGuest", args, signs)
		if not ok then
			print("call init fail"..ret)
		end
	elseif(device.platform == "ios") then
		local args = {
			luaFun = callback
		}
		local luaoc = require "cocos.cocos2d.luaoc"
		local className = "RootViewController"
		local ok,ret = luaoc.callStaticMethod(className,"loginGuest",args)
	else
		local jsonString = "{'loginCode':1,'openUserId':123456,'nickName':'userNickName','accessToken':'123'}"
		callback(jsonString)
	end
end

--登陆回调，在这里通知各个Scene去处理
function YllGameHelper:onLoginCallBack(jsonString)
	dump(jsonString, "登陆回调成功")
	local userInfo = json.decode(jsonString)
	g_commonhandler:notifyEvent("luaLoginCallBack", userInfo)
end

--同步角色
function YllGameHelper:syncRoleInfo(roleid, roleName, roleLV, roleVipLv, serverID, castleLevel)
	local callback = handler(self, self.syncRoleInfoCallBack)
	if device.platform == "android" then
		local luaj = require "cocos.cocos2d.luaj"
		local args = {roleid, roleName, roleLV, roleVipLv, serverID, castleLevel, callback}
		local signs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
		local ok,ret = luaj.callStaticMethod(activityClassName, "syncRoleInfo", args, signs)
		if not ok then
			print("call init fail"..ret)
		end
	elseif (device.platform == "ios") then
		local args = {
			rid = roleid,
			rname = roleName,
			rlv = roleLV,
			viplv = roleVipLv,
			sid = serverID,
			clv = castleLevel,
			luaFun = callback
		}
		local luaoc = require "cocos.cocos2d.luaoc"
		local className = "RootViewController"
		local ok,ret = luaoc.callStaticMethod(className,"syncRoleInfo",args)
	else
		callback("success")
	end
end
--同步角色回调,在这里通知各个Scene去处理
function YllGameHelper:syncRoleInfoCallBack(into)
	g_commonhandler:notifyEvent("luaSyncRoleCallBack", into)
end

--修改昵称
function YllGameHelper:modifyName(callback)
	if device.platform == "android" then
		local luaj = require "cocos.cocos2d.luaj"
		local args = {callback}
		local signs = "(I)V"
		local ok,ret = luaj.callStaticMethod(activityClassName, "showModifyName", args, signs)
		if not ok then
			print("call init fail"..ret)
		end
	elseif (device.platform == "ios") then
		local args = {luaFun = callback}
		local luaoc = require "cocos.cocos2d.luaoc"
		local className = "RootViewController"
		local ok,ret = luaoc.callStaticMethod(className,"showModifyName",args)
	else
		callback("success")
	end
end
--设置
function YllGameHelper:showSetting(serviceId, roleID)
	if device.platform == "android" then
		local luaj = require "cocos.cocos2d.luaj"
		local args = {serviceId, roleID}
		local signs = "(Ljava/lang/String;Ljava/lang/String;)V"
		local ok,ret = luaj.callStaticMethod(activityClassName, "showSetting", args, signs)
		if not ok then
			print("call init fail"..ret)
		end
	elseif (device.platform == "ios") then
		local args = {
			sid = serviceId,
			rid = roleID,
		}
		local luaoc = require "cocos.cocos2d.luaoc"
		local className = "RootViewController"
		local ok,ret = luaoc.callStaticMethod(className,"showSetting",args)
	end
end

--主动崩溃
function YllGameHelper:crashTest()
	if device.platform == "android" then
		local luaj = require "cocos.cocos2d.luaj"
		local args = {}
		local signs = "()V"
		local ok,ret = luaj.callStaticMethod(activityClassName, "crashTest", args, signs)
		if not ok then
			print("call init fail"..ret)
		end
	elseif (device.platform == "ios") then
		local args = {}
		local luaoc = require "cocos.cocos2d.luaoc"
		local className = "RootViewController"
		local ok,ret = luaoc.callStaticMethod(className,"crashTest",args)
	end
end

--账号管理
function YllGameHelper:showAccountManage()
	if device.platform == "android" then
		local luaj = require "cocos.cocos2d.luaj"
		local args = {}
		local signs = "()V"
		local ok,ret = luaj.callStaticMethod(activityClassName, "accountManager", args, signs)
		if not ok then
			print("call init fail"..ret)
		end
	elseif (device.platform == "ios") then
		local args = {}
		local luaoc = require "cocos.cocos2d.luaoc"
		local className = "RootViewController"
		local ok,ret = luaoc.callStaticMethod(className,"showAccountManage",args)
	end
end

--获取SDK信息
function YllGameHelper:getSDKInfo()
	local str = "{'baseurl':'mac','versionname':'mac'}"
	if device.platform == "android" then
		local luaj = require "cocos.cocos2d.luaj"
		local args = {}
		local signs = "()Ljava/lang/String;"
		local ok,ret = luaj.callStaticMethod(activityClassName, "getSDKInfo", args, signs)
		if not ok then
			print("call init fail"..ret)
		else
			str = ret
		end
	elseif (device.platform == "ios") then
		local args = {}
		local luaoc = require "cocos.cocos2d.luaoc"
		local className = "RootViewController"
		local ok,ret = luaoc.callStaticMethod(className,"getSDKInfo",args)
		print("IOS 版本信息"..ret)
		str = "{'baseurl':'IOS','versionname':'"..ret.."'}"
	end
	return str
end
--客服
function YllGameHelper:showserviceChat(serverid, roleID)
	if device.platform == "android" then
		local luaj = require "cocos.cocos2d.luaj"
		local args = {serverid, roleID}
		local signs = "(Ljava/lang/String;Ljava/lang/String;)V"
		local ok,ret = luaj.callStaticMethod(activityClassName, "showserviceChat", args, signs)
		if not ok then
			print("call init fail"..ret)
		end
	elseif (device.platform == "ios") then
		local args = {
			rsid = serverid,
			rid = roleID
		}
		local luaoc = require "cocos.cocos2d.luaoc"
		local className = "RootViewController"
		local ok,ret = luaoc.callStaticMethod(className,"showserviceChat",args)
	end
end
--设置语言
function YllGameHelper:setLanguage()
	if device.platform == "android" then
		local luaj = require "cocos.cocos2d.luaj"
		local args = {Language}
		local signs = "(Ljava/lang/String;)V"
		local ok,ret = luaj.callStaticMethod(activityClassName, "setLanguage", args, signs)
		if not ok then
			print("call init fail"..ret)
		end
	elseif (device.platform == "ios") then
		local args = {
			lan = Language,
		}
		local luaoc = require "cocos.cocos2d.luaoc"
		local className = "RootViewController"
		local ok,ret = luaoc.callStaticMethod(className,"setLanguage",args)
	end
end

function YllGameHelper:shareToFB(desc, link, callBack)
	if device.platform == "android" then
		local luaj = require "cocos.cocos2d.luaj"
		local args = {desc, link, callBack}
		local signs = "(Ljava/lang/String;Ljava/lang/String;I)V"
		local ok,ret = luaj.callStaticMethod(activityClassName, "shareToFB", args, signs)
		if not ok then
			print("call init fail"..ret)
		end
	elseif (device.platform == "ios") then
		local args = {
			quote = desc,
			link = link,
			luaFun = callBack
		}
		local luaoc = require "cocos.cocos2d.luaoc"
		local className = "RootViewController"
		local ok,ret = luaoc.callStaticMethod(className,"shareToFB",args)
	else
		
	end
end

function YllGameHelper:getFriends(callback)
	if device.platform == "android" then
		local luaj = require "cocos.cocos2d.luaj"
		local args = {callback}
		local signs = "(I)Ljava/lang/String;"
		local ok,ret = luaj.callStaticMethod(activityClassName, "getFriends", args, signs)
		if not ok then
			print("call init fail"..ret)
		end
	elseif (device.platform == "ios") then
		local args = {
			luaFun = callback
		}
		local luaoc = require "cocos.cocos2d.luaoc"
		local className = "RootViewController"
		local ok,ret = luaoc.callStaticMethod(className,"getFriends",args)
	else
		callback('[{"name":"name","fbId":"fbId","userOpenId":"userOpenId"},{"name":"name2","fbId":"fbId2","userOpenId":"userOpenId2"}]')
	end
end

--[[
    @desc: 点击商品开始充值
    author:{author}
    time:2021-07-12 16:46:04
    --@skutype:订阅传"subs",正常充值传“inapp”
	--@roleID:角色ID
	--@serverid:服务器ID
	--@sku:商品sku
	--@price:商品price
	--@pointID:商品pointID
	--@callback:回调，会在充值成功后异步调用此回调
    @return:
]]
function YllGameHelper:pay(roleID, serverid, sku, price, pointID, callback)
	dump("  roleID-"..roleID.."  serverid-"..serverid.."   sku-"..sku.."   price-"..price.."  pointID-"..pointID)
	if device.platform == "android" then
		local luaj = require "cocos.cocos2d.luaj"
		local args = {roleID, serverid, sku, price, pointID, callback}
		local signs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
		local ok,ret = luaj.callStaticMethod(activityClassName, "pay", args, signs)
		if not ok then
			print("call init fail"..ret)
		end
	elseif (device.platform == "ios") then
		local args = {
			rid = roleID,
			sid = serverid,
			sku = sku,
			pri = price,
			pid = pointID,
			luaFun = callback
		}
		local luaoc = require "cocos.cocos2d.luaoc"
		local className = "RootViewController"
		local ok,ret = luaoc.callStaticMethod(className,"pay",args)
	else
		callback(pointID)
	end
end

function YllGameHelper:paySubs(roleID, serverid, sku, price, pointID, callback)
	dump("  roleID-"..roleID.."  serverid-"..serverid.."   sku-"..sku.."   price-"..price.."  pointID-"..pointID)
	if device.platform == "android" then
		local luaj = require "cocos.cocos2d.luaj"
		local args = {roleID, serverid, sku, price, pointID, callback}
		local signs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
		local ok,ret = luaj.callStaticMethod(activityClassName, "paySubs", args, signs)
		if not ok then
			print("call init fail"..ret)
		end
	elseif (device.platform == "ios") then
		local args = {
			rid = roleID,
			sid = serverid,
			sku = sku,
			pri = price,
			pid = pointID,
			luaFun = callback
		}
		local luaoc = require "cocos.cocos2d.luaoc"
		local className = "RootViewController"
		local ok,ret = luaoc.callStaticMethod(className,"paySubs",args)
	else
		callback(pointID)
	end
end


--自定义事件
function YllGameHelper:onEvent(eventName, jsonStr)
	print(jsonStr)
	if device.platform == "android" then
		local luaj = require "cocos.cocos2d.luaj"
		local args = {eventName, jsonStr}
		local signs = "(Ljava/lang/String;Ljava/lang/String;)V"
		local ok,ret = luaj.callStaticMethod(activityClassName, "onEvent", args, signs)
		if not ok then
			print("call init fail"..ret)
		end
	elseif (device.platform == "ios") then
		local args = {
			evName = eventName,
			jsStr = jsonStr
		}
		local luaoc = require "cocos.cocos2d.luaoc"
		local className = "RootViewController"
		local ok,ret = luaoc.callStaticMethod(className,"onEvent",args)
	end
end

--复制剪切板
function YllGameHelper:copyToClipbord(needStr)
	print(jsonStr)
	if device.platform == "android" then
		local luaj = require "cocos.cocos2d.luaj"
		local args = {needStr}
		local signs = "(Ljava/lang/String;)V"
		local ok,ret = luaj.callStaticMethod(activityClassName, "copyToClipboard", args, signs)
		if not ok then
			print("call init fail"..ret)
		end
	elseif (device.platform == "ios") then
		local args = {
			str = needStr
		}
		local luaoc = require "cocos.cocos2d.luaoc"
		local className = "RootViewController"
		local ok,ret = luaoc.callStaticMethod(className,"copyToClipboard",args)
	end
end
return YllGameHelper
