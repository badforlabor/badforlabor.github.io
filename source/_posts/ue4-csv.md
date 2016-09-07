---
title: ue4-csv
date: 2016-09-07 16:46:18
tags: [UE4]
---

# UE4加载CSV的各种方法

## 准备
当然，加载csv的第一步，要先建立一个与csv表对应的结构体，在导入csv表的时候会用到。
该结构体，__必须继承自FTableRowBase__，比如：
``` cpp
USTRUCT()
struct FTestDataRow : public FTableRowBase
{
	GENERATED_USTRUCT_BODY()

	UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = Test)
		float time;
	UPROPERTY(EditAnywhere, BlueprintReadOnly, Category = Test)
		int scene_id;

	// 这里没加“EditAnywhere”，这个变量就无法在editor中编辑，嘿嘿。
	UPROPERTY()
		float alpha;
};
```

<br>
<br>

有了这个结构体之后，就能建立一下csv表，当然，按照UE4的约定，__csv表的结构必须与对应的结构体一致__，比如，创建的test1.csv的内容是：
``` cpp
// test1.csv
id,time,scene_id,alpha
1,0.1,1,0
2,0.5,3,0
3,0,0,0
```

<br>
<br>

## 读取

然后，就可以在UE4中导入这个csv表啦。

### 方法一

在C++中，访问csv表，很简单，把UDataTable加载出来即可，如下所示：
``` cpp
	// 加载csv，并且显示第一行数据
	UDataTable* csv = LoadObject<UDataTable>(NULL, TEXT("DataTable'/Game/csv/test1.test1'"));
	if (csv != NULL && csv->GetRowNames().Num() > 0)
	{
		// 获取id=1的那行的数据
		FTestDataRow* row = csv->FindRow<FTestDataRow>(TEXT("1"), TEXT(""));
		if (row != NULL)
		{
			Debug(FString::Printf(TEXT("csv, row time="), row->time));
		}
	}
```

<br>

### 方法二

在BP中，读取csv，依然也很简单，如图：

![](/img/ue4/2016-09-07_171527.png)

<br>

### 方法三

在C++中，直接读取csv文件，方法，当然也很简单，因为UE4提供了这个功能，__核心是调用函数：UDataTable::CreateTableFromCSVString__
``` cpp
	// 动态读取csv文件，不过，这个只能在Editor模式运行，如果需要在发布版中运行，那么自己新建一个类
	FString FilePath = FPaths::ConvertRelativePathToFull(FPaths::GameDir()) + FString::Printf(TEXT("csv/test1.csv"));
	FString Data;
	if (FFileHelper::LoadFileToString(Data, *FilePath))
	{
		UDataTable* DataTable = NewObject<UDataTable>(GetTransientPackage(), FName(TEXT("CSV_Test")));
		DataTable->RowStruct = FTestDataRow::StaticStruct();
		DataTable->CreateTableFromCSVString(Data);
		Debug(FString::Printf(TEXT("%d"), DataTable->GetRowNames().Num()));
	}
```

<br>

## 后记

想起一下用UT2004的年代，csv相关的函数都是自己写的，Unreal并没有提供太多的帮助。这次用UE4，着实方便了很多啊！