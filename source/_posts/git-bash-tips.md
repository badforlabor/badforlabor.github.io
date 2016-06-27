---
title: git-bash-tips
date: 2016-06-27 11:19:49
tags: [git]
---

# git-bash小技巧

	最近用hexo写日志的时候，使用了一堆命令，然后还得鼠标点击打开文本编辑器，编辑自己的日志。有一天发现，自己用的是git-bash，为啥不写点shell脚步，改进工作效率呢？

### 修改初始路径
	双击git安装目录中的"Git Bash"之后，默认的初始路径是"/c/windows/system32"，如何设置到自己的日志路径呢？
	很简单，按照下面的步骤一步一步执行即可：
		1. 拷贝一份"Git Bash"到自己的日志路径，比如自己的是“D:\liubo\github2\hexo”
		2. 右键“Git Bash” --> 属性 --> 找到“快捷方式” --> 将“起始位置”的值改成“D:\liubo\github2\hexo”即可。
		3. 如图所示：
![](/img/git-bash-tips-pic1.png)
		
		
### 提交效率的shell脚步
	自己学的Linux/shell并不多，导致写shell很吃力，不过，最终还是写了一个很实用的，参考如下：
``` bash
#post.sh
hexo new post $1
/c/"Program Files (x86)"/Notepad++/notepad++.exe ./source/_posts/$1.md
```
<font color="#ff0000">	(注意，shell脚步中如果有空格出现，那么用""包含起来，比如"Program Files (x86)") </font>

	执行shell，如图
![](/img/git-bash-tips-pic2.png)
	这个shell脚步的好处是，当用hexo写日志的时候，会自动使用notepad++打开日志文件
	
