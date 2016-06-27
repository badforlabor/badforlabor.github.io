#post.sh
arg1="$1"
if [ "" = "${arg1//}" ]
#if [ -z $1 ]
then
 echo "请输入一个参数，代表文件名"
else
 rm -f ./source/_posts/$1.md
 hexo new post $1
 git add "./source/_posts/$1.md"
 /c/"Program Files (x86)"/Notepad++/notepad++.exe ./source/_posts/$1.md
fi