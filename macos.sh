#!/bin/zsh
echo "配置macos flutter 全局环境变量"

# echo $SHELL
# echo "我的名字是 `basename $0` - 我是调用自 $0"
# echo "我有 $# 参数"
shpath=$HOME/.bash_profile
echo $shpath
echo "export FLUTTER_HOME=$1">$shpath
echo 'export PATH=$PATH:$FLUTTER_HOME/bin'>>$shpath
echo 'export PATH=$PATH:$FLUTTER_HOME/bin/cache/dart-sdk/bin'>>$shpath
echo 'export PUB_HOSTED_URL=https://pub.flutter-io.cn'>>$shpath
echo 'export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn'>>$shpath
source ~/.bash_profile
# count=1
# while [ "$#" -ge "1" ];do
#     echo "参数序号为 $count 是 $1"
#     let count=count+1
#     shift
# done

# # 打印出第一行与第十行
# sed -n $2'p;'$3'p' $1
