---
title: ue4使用steam sdk
date: 2016-09-16 21:41:26
tags: [UE4]
---

# UE4使用Steamworks SDK

### SDK官网
[戳这里](https://partner.steamgames.com/)
在官网上，SDK的信息很详细，登陆steam账号，下载SDK，之后，可以运行其中的例子，例子中提供了各种API的使用方法

### UE4接入Steam

嘿嘿，UE4已经接入了steam，在Online系统中，叫OnlineSubsystemSteam
官方已经给出了设置方式，详细在[这里](https://docs.unrealengine.com/latest/INT/Programming/Online/Steam/index.html)，还可以参考[wiki](https://wiki.unrealengine.com/Steam,_Using_the_Steam_SDK_During_Development)
<br>
调用方式很简单，比如获取steam的昵称
```cpp
FString UMyBlueprintFunctionLibrary::GetMySteamName()
{
	IOnlineSubsystem* mysteam = IOnlineSubsystem::Get(STEAM_SUBSYSTEM);
	if (mysteam != NULL && mysteam->GetIdentityInterface().IsValid())
	{
		return mysteam->GetIdentityInterface()->GetPlayerNickname(0);
	}
	return TEXT("");
}
```
<br>

不过，在editor模式下，有些问题，SubsystemSteam实例会创建失败，原因是这段代码搞得鬼
``` cpp
bool FOnlineSubsystemSteam::IsEnabled()
{
	if (bSteamworksClientInitialized || bSteamworksGameServerInitialized)
	{
		return true;
	}

	// Check the ini for disabling Steam
	bool bEnableSteam = true;
	GConfig->GetBool(TEXT("OnlineSubsystemSteam"), TEXT("bEnabled"), bEnableSteam, GEngineIni);
	if (bEnableSteam)
	{
		// Steam doesn't support running both the server and client on the same machine
		bEnableSteam = !FParse::Param(FCommandLine::Get(),TEXT("MultiprocessOSS"));
#if UE_EDITOR
		if (bEnableSteam)
		{
			bEnableSteam = IsRunningDedicatedServer() || IsRunningGame();
		}
#endif
	}

	return bEnableSteam;
}

```
居然多加了如下这个判断，真的搞不明白
```cpp
#if UE_EDITOR
		if (bEnableSteam)
		{
			bEnableSteam = IsRunningDedicatedServer() || IsRunningGame();
		}
#endif
```
所以，没办法，自己重新把OnlineSubsystemSteam代码复制粘贴了一份，叫做MySteam。大部分都没动，只是简单的把几个类改名为*MySteam*，比如USteamNetConnection改名为UMySteamNetConnection，默认是的STEAM_SUBSYSTEM改名为MY_STEAM。
