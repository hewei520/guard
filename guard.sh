#!/bin/bash
#url=$(pwd)
url=$(dirname $(readlink -f "$0") || (cd "$(dirname "$0")";pwd))
configUrl="$url/config/guard.config"
#检测配置文件是否存在
if [ ! -f "$configUrl" ];
  then
    echo "${configUrl} 配置文件不存在"
    exit
fi

#获取日志路径
logUrl=`sed '/^logUrl=/!d;s/.*=//' $configUrl`
#判断日志文件是否配置
if [ ! -n "$logUrl" ];
  then
    echo  "logUrl 未配置"
    exit
fi
#获取循环时间
whileTime=`sed '/^whileTime=/!d;s/.*=//' $configUrl`
#判断循环时间是否为空，给默认60秒
if [ ! -n "$whileTime" -o $whileTime == "" ];
  then
	  whileTime=60
fi

#封装输出日志到日志文件方法
echoLog(){
  echo $1 >> ${logUrl}
}

#开始分割符
echoStart(){
  echoLog "/----------------------------------$1 start------------------------------------/"
}

#结束分割符
echoEnd(){
  echoLog "/----------------------------------$1 end--------------------------------------/"
}

#封装判断进程是否运行方法
testingPs(){
	#$1=进程名 $2=项目路径 $3=执行方法
  #检测逻辑，用ps判断进程是否存在运行
  ps -x |grep $1 | grep -v grep >/dev/null
  if [ $? -eq 0 ];
    then
      echoLog "$1正在运行"
      echoEnd $file
      continue
    else
      echoLog "$1没有运行"
      cd ${2}
      if [ $? -ne 0 ];
      then
        echoLog  "进入项目$2失败！"
        echoEnd $file
        continue
      fi
      echoLog  "进入项目$2"

      nohup ${3} >/dev/null 2>&1 &
      if [ $? -ne 0 ];
        then
           echoLog "运行$3失败！"
           echoEnd $file
           continue
      fi
      echoLog  "运行$3"
  fi
}
while : #循环执行
do
sleep $whileTime #间隔时间,每分钟执行一次
  for file in $(find  "$url/config" -type f)
	do
	  if [ "$(echo $file | grep "_guard.config")" != "" -a "$(echo $file | grep "demo_guard.config")" == "" ];
	    then
	      echoStart $file
        #获取进程名
        psName=`sed '/^psName=/!d;s/.*=//' $file`
        #判断是否配置进程名
        if [ ! -n "$psName" ];
          then
            echoLog  "${file}里未配置 psName"
	          echoEnd $file
            continue
        fi

        #获取项目路径
        projectPath=`sed '/^projectPath=/!d;s/.*=//' $file`
        #判断是否配置项目路径
        if [ ! -n "$projectPath" ];
          then
            echoLog  "${file}里未配置 projectPath"
	          echoEnd $file
            continue
        fi
        #获取执行脚本命令
        executeScript=`sed '/^executeScript=/!d;s/.*=//' $file`
        #判断是否配置执行脚本命令
        if [ ! -n "$executeScript" ];
          then
            echoLog  "${file}里未配置 executeScript"
	          echoEnd $file
            continue
        fi

        testingPs  $psName $projectPath "$executeScript"
	      echoEnd $file
	  fi
  done
done
