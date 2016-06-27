#post.sh
if [ "" = $1 ]
#if [ -z $1 ]
then
 echo "请输入一个参数，代表文件名"
else
 hexo new post $1
 /c/"Program Files (x86)"/Notepad++/notepad++.exe ./source/_posts/$1.md
 git add "./source/_posts/$1.md"
fi