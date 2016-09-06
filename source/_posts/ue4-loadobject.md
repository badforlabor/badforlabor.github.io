---
title: ue4-loadobject
date: 2016-09-05 12:06:51
tags: [UE4]
---


### UE4 C++加载对象

开发功能的时候，经常会用到一些对象，比如Material、Texture，如何动态加载呢？

核心函数是：StaticLoadObject

不过，有几种封装。

第一种，只能在构造函数中运行。

```cpp
	// 这个只能在构造函数中执行
	static ConstructorHelpers::FObjectFinder<UTexture>
		GameObjectLookupDataTable_BP(TEXT("Texture2D'/Game/t1.t1'"));
	UTexture* txture = GameObjectLookupDataTable_BP.Object;
```

第二种，在任何地方都能调用，不过，尽量别在构造函数中调用，因为，被加载的内容，有可能被垃圾回收掉。

```cpp
	// 名字，在UE4Editor中，按Ctrl+c，然后在notepad中，按Ctrl+v，就可以查看了。
	UTexture* txture = (UTexture*)StaticLoadObject(UTexture::StaticClass(), NULL, TEXT("Texture2D'/Game/t1.t1'"), NULL, LOAD_None, NULL, true);
	txture = (UTexture*)StaticLoadObject(UTexture::StaticClass(), NULL, TEXT("Texture2D'/Game/t1.t1'"));

	txture = LoadObject<UTexture>(NULL, TEXT("Texture2D'/Game/t1.t1'"));
```

注意， 动态加载的内容，是可以被垃圾回收掉的，如果想一直保留在内存中，可以这样：（不过，不建议这样调用，还是让UnrealEngine自动管理好）
```cpp

	UTexture* txture = (UTexture*)StaticLoadObject(UTexture::StaticClass(), NULL, TEXT("Texture2D'/Game/t1.t1'"), NULL, LOAD_None, NULL, true);
	txture->AddToRoot();
```
