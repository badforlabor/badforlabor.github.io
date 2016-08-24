---
title: C++基础语法
date: 2016-08-23 10:24:09
tags: [c++]
---

### C++基础语法
说来有意思，前些年天天写C++，非常擅长。这才几年，忘光啦，又没有笔记可翻，所以只能重新再把C++Primer翻一遍，把一些基本的定义记录在这里，当成手册，以后方便查阅


## 数组
&nbsp;&nbsp;&nbsp;&nbsp;声明方法：int a[3]; // 必须带长度
&nbsp;&nbsp;&nbsp;&nbsp;声明和赋值：int a[] = {1,2,3};
&nbsp;&nbsp;&nbsp;&nbsp;动态数组：int* a = new int[3];
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;需要动态释放：delete [] a;
__错误的写法：__
``` cpp
	//int c[];	// 编译错误，没有指定数组大小
	
	int elen = 5;
	//int e[elen];	// 编译错误，数组大小不确定，所以编译不过

	// 正确的写法
	const int flen = 3;
	int f[flen];

```
