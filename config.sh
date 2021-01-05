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


FILE_NAME="git-2.29.2"
(cd $FILE_PATH && tar -zxvf $FILE_NAME.tar.gz && cd $FILE_NAME \
&& make configure && ./configure --prefix=$APPSPATH && make -j$(nproc) && \
make install)


# 添加环境变量
echo "export PATH=$APPSPATH/bin:$PATH" >> /etc/profile && \
echo "export LD_LIBRARY_PATH=$APPSPATH/lib:$APPSPATH/lib64:$LD_LIBRARY_PATH" >> /etc/profile && \
source /etc/profile


# 安装vim8
FILE_NAME="vim-8.2.2202"
(cd $FILE_PATH && tar -zxvf $FILE_NAME.tar.gz && cd FILE_NAME && \
 ./configure --prefix=$APPSPATH && \
 make -j$(nproc)  && make install)

# 安装vim-plug
echo -e "140.82.112.4\tgithub.com\n\
185.199.108.153\tgithub.github.io\n\
199.232.69.194\tgithub.global.ssl.fastly.net\n\
199.232.28.133\traw.githubusercontent.com" >> /etc/hosts

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# 安装GCC 

yum install bison -y

yum install autoconf automake -y

FILE_NAME="gcc-10.2.0"
(cd $FILE_PATH; tar -zxvf $FILE_NAME.tar.gz && cd $FILE_NAME && \
cp -r $FILE_PATH/gcc-devel/* . && \
sh contrib/download_prerequisites && \
mkdir build && cd build && \
../configure --enable-checking=release --enable-languages=c,c++ --disable-multilib --prefix=$APPSPATH && \
make -j$(nproc) && make install)

yum remove -y gcc gcc-c++

# 安装GDB
FILE_NAME="gdb-10.1"
(cd $FILE_PATH; tar -zxvf $FILE_NAME.tar.gz && cd $FILE_NAME && ./configure --prefix=$APPSPATH && \
make -j$(nproc) && make install)


# 安装cmake
FILE_NAME="cmake-3.19.2-Linux-x86_64"
(cd $FILE_PATH; tar -zxvf $FILE_NAME.tar.gz && cd $FILE_NAME && ./configure --prefix=$APPSPATH && \
make -j$(nproc) && make install)
