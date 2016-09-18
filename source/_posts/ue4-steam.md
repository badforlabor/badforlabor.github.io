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

不过，为了保证发布的版本依然使用UE4提供的Steam，把逻辑代码做了一点点修改，如下：
``` cpp
FString UMyBlueprintFunctionLibrary::GetMySteamName()
{
	IOnlineSubsystem* mysteam = NULL;// IOnlineSubsystem::Get(FName("MY_STEAM"));
	
#if UE_EDITOR
	mysteam = IOnlineSubsystem::Get(FName("MY_STEAM"));
#else
	mysteam = IOnlineSubsystem::Get(STEAM_SUBSYSTEM);
#endif

	if (mysteam != NULL && mysteam->GetIdentityInterface().IsValid())
	{
		return mysteam->GetIdentityInterface()->GetPlayerNickname(0);
	}
	return TEXT("");
}
```
当然，按照[wiki](https://wiki.unrealengine.com/Steam,_Using_the_Steam_SDK_During_Development)上所说，依然要对自己的游戏工程做一定设置（如果不设置，发布版本之后，不会包含Steamworks SDK对应的DLL）。我的游戏工程叫test_cpp，所以修改如下：
``` cpp
// test_cpp.Target.cs
public class test_cppTarget : TargetRules
{
	public test_cppTarget(TargetInfo Target)
	{
		Type = TargetType.Game;
        bUsesSteam = true;	// 标记使用steam
    }
	// 后面的省略了
}
```
``` cpp
// test_cpp.Build.cs
public class test_cpp : ModuleRules
{
	public test_cpp(TargetInfo Target)
	{
		PublicDependencyModuleNames.AddRange(new string[] { "Core", "CoreUObject", "Engine", "InputCore" });

		PrivateDependencyModuleNames.AddRange(new string[] {  });

		// Uncomment if you are using Slate UI
		// PrivateDependencyModuleNames.AddRange(new string[] { "Slate", "SlateCore" });
		
		// Uncomment if you are using online features
		PrivateDependencyModuleNames.Add("OnlineSubsystem");
//         if ((Target.Platform == UnrealTargetPlatform.Win32) || (Target.Platform == UnrealTargetPlatform.Win64))
//         {
//             if (UEBuildConfiguration.bCompileSteamOSS == true)
//             {
                 DynamicallyLoadedModuleNames.Add("OnlineSubsystemSteam");
//             }
//         }
    }
}
```

### 问题
1、在Editor模式下运行Steam之后，在打开发布的版本，发布版本的Steam会运行失败，原因是初始化steam的时候，会创建一个steamserver，端口被占用了。醉了，代码在这里
``` cpp
bool FOnlineSubsystemSteam::InitSteamworksServer()
{
	// 省略...
	
	// NOTE: IP of 0 causes SteamGameServer_Init to automatically use the public (external) IP
	UE_LOG_ONLINE(Verbose, TEXT("Initializing Steam Game Server IP: 0x%08X Port: %d SteamPort: %d QueryPort: %d"), LocalServerIP, GameServerGamePort, GameServerSteamPort, GameServerQueryPort);
	bSteamworksGameServerInitialized = SteamGameServer_Init(LocalServerIP, GameServerSteamPort, GameServerGamePort, GameServerQueryPort,
		(bVACEnabled ? eServerModeAuthenticationAndSecure : eServerModeAuthentication),
		TCHAR_TO_UTF8(*GameVersion));
	
	// 省略...
}
```