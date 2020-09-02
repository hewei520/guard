##  一、简介
进程守护脚本

##  二、搭建前准备

* liunx环境
    * 支持shell
    * 支持nohup

##  三、搭建步骤

#### 1.修改配置文件

本脚本的核心配置文件是config/guard.config，支持修改日志输出路劲和时间间隔配置，只要核心配置文件存在就可以正常运行
如需要正常守护功能，还需添加进程配置文件，方法如下：
```
    在config文件夹下找到demo_guard.config配置演示文件，复制此文件到同级目录下修改名称（修改规则：***_guard.config）
然后进入配置文件修改psName、projectPath、executeScript三个配置项，即可
```

#### 2.启动守护
进入守护进程文件（guard.sh）同级目录下，执行方法如下
```
调试模式：sh guard.sh
后台模式：nohup sh guard.sh &>/dev/null &
```

#### 3.查看是否正常运行
方法：ps -aux | grep guard.sh
查看是否有guard.sh进程存在，有则运行成功


##  四、作者
威少
[824056342@qq.com]
