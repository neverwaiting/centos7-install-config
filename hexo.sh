#!/bin/bash

# 保证是root用户
if [ $(whoami) != "root" ]; then
    echo "please make sure user is root!"
    return
fi

# 确定需要配置的用户
read -p "please input your username(not root!): " USER_NAME
while :; do
        if [ $(ls /home | grep $USER_NAME | wc -l) -gt 0 ]; then
                break;
        else
                read -p "Invalid username, please input your username again: " USER_NAME
        fi
done

# 下载必备文件
git clone https://e.coding.net/wintersun/centos-config/centos-config.git

if [ $? -ne 0 ];then
    echo -e "\033[49;31m git clone error, cannot contine! \033[0m"
	return 
else
	echo -e "\033[49;32m git clone success, start installing! \033[0m"; echo
fi

# app path
APPSPATH=/apps/$USER_NAME

mkdir -p $APPSPATH

# 安装必要工具
# ---------------------------------------
# 解压工具
yum install zip unzip -y 

# 安装gcc gcc-c++ 默认版本4.8.5
yum -y install gcc gcc-c++

# 安装network工具/ wget /
yum -y install net-tools.x86_64 wget

# 安装ftp lftp vsftpd mailx
yum -y install lftp ftp vsftpd mailx

yum install zsh autoconf zlib-devel curl-devel texinfo -y

yum install bzip2 python3 bzip2-devel openssl-devel ncurses-devel \
	python-devel python3-devel -y


# 将文件转移到/opt/$username下
FILE_PATH=/opt/$USER_NAME
mkdir -p $FILE_PATH && cp -r centos-config/* $FILE_PATH/

# remove 系统自带git
yum -y remove git 

# 安装git
echo -e "\033[49;33m start install git...... \033[0m"; sleep 1

FILE_NAME="git.zip"
(cd $FILE_PATH && unzip -q $FILE_NAME && cd git-master \
&& make configure && ./configure --prefix=$APPSPATH && make -j$(nproc) && \
make install)
echo -e "\033[49;32m install git success! \033[0m"; echo

# 安装nodejs
echo -e "\033[49;33m start install nodejs...... \033[0m"; sleep 1

FILE_NAME="node-v12.18.4-linux-x64.tar.gz"
mkdir -p $APPSPATH/nodejs
(cd $FILE_PATH; tar -zxf $FILE_NAME -C $APPSPATH/nodejs)
(cp $APPSPATH/nodejs/node-v12.18.4-linux-x64/* $APPSPATH/nodejs -r && \
rm -rf $APPSPATH/nodejs/node-v12.18.4-linux-x64)

# 添加环境变量
echo "export PATH=$APPSPATH/bin:$APPSPATH/nodejs/bin:$PATH" >> /etc/profile && \
echo "export LD_LIBRARY_PATH=$APPSPATH/lib:$APPSPATH/lib64:$LD_LIBRARY_PATH" >> /etc/profile && \
source /etc/profile

echo -e "\033[49;32m install nodejs success! \033[0m"; echo

# 安装hexo-cli
echo -e "\033[49;33m start install hexo-cli...... \033[0m"; sleep 1

npm install -g cnpm --registry=https://registry.npm.taobao.org
cnpm install -g hexo-cli

# 安装vim8
echo -e "\033[49;33m start install vim8...... \033[0m"; sleep 1

FILE_NAME="vim.zip"

(cd $FILE_PATH && unzip -q $FILE_NAME && cd vim-master && \
 ./configure --prefix=$APPSPATH && \
 make -j$(nproc)  && make install)
echo install vim8 success!; echo 


echo -e "\033[49;32m finish! \033[0m"; echo
