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

# 安装vim-plug
echo -e "\033[49;33m start install vim-plug...... \033[0m"; sleep 1

echo -e "140.82.112.4\tgithub.com\n\
185.199.108.153\tgithub.github.io\n\
199.232.69.194\tgithub.global.ssl.fastly.net\n\
199.232.28.133\traw.githubusercontent.com" >> /etc/hosts

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

echo -e "\033[49;33m start install ycm...... \033[0m"; sleep 1

cp $FILE_PATH/vimrc ~/.vimrc && chmod 644 ~/.vimrc

# 安装GCC 9.3.0

yum install bison -y

# 安装依赖autoconf automake
echo -e "\033[49;33m start install autoconf-2.69...... \033[0m"; sleep 1
FILE_NAME="autoconf-2.69.tar.gz"
(cd $FILE_PATH; tar -zxvf $FILE_NAME && cd autoconf-2.69 && ./configure --prefix=$APPSPATH && \
make -j$(nproc) && make install)

echo -e "\033[49;33m start install automake-1.15...... \033[0m"; sleep 1
FILE_NAME="automake-1.15.tar.gz"
(cd $FILE_PATH; tar -zxvf $FILE_NAME && cd automake-1.15 && ./configure --prefix=$APPSPATH && \
sed -i '3687s/$/ --no-discard-stderr/' Makefile && \
make -j$(nproc) && make install)

echo -e "\033[49;33m start install GCC-9.3.0...... \033[0m"; sleep 1
FILE_NAME="gcc-9.3.0.tar.gz"
(cd $FILE_PATH; tar -zxvf $FILE_NAME && cd gcc-9.3.0 && \
cp -r $FILE_PATH/gcc-devel/* . && \
sh contrib/download_prerequisites && \
mkdir build && cd build && \
../configure --enable-checking=release --enable-languages=c,c++ --disable-multilib --prefix=$APPSPATH && \
make -j$(nproc) && make install)

# 安装GDB 8.3
echo -e "\033[49;33m start install GDB 8.3...... \033[0m"; sleep 1
FILE_NAME="gdb-8.3.tar.gz"
(cd $FILE_PATH; tar -zxvf $FILE_NAME && cd gdb-8.3 && ./configure --prefix=$APPSPATH && \
make -j$(nproc) && make install)

echo -e "\033[49;32m install GDB 8.3 success! \033[0m"; echo

# 安装cmake-3.18.4.tar.gz
echo -e "\033[49;33m start install cmake-3.18.4...... \033[0m"; sleep 1
FILE_NAME="cmake-3.18.4.tar.gz"
(cd $FILE_PATH; tar -zxvf $FILE_NAME && cd cmake-3.18.4 && ./configure --prefix=$APPSPATH && \
make -j$(nproc) && make install)

echo -e "\033[49;32m install cmake-3.18.4 success! \033[0m"; echo


# su - $USER_NAME <<EOF
# # 安装oh-my-zsh
# sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# 
# sed 's/robbyrussell/ys/g' .zshrc -i
# EOF

# 安装llvmorg-11.0.0
echo -e "\033[49;33m start install llvmorg-11.0.0...... \033[0m"; sleep 1
FILE_NAME="llvmorg-11.0.0.zip"
(cd $FILE_PATH; unzip -q $FILE_NAME && cd llvmorg-11.0.0 && \
mkdir build && cd build && \
cmake -DLLVM_ENABLE_PROJECTS="clang;libcxx;libcxxabi" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$APPSPATH ../llvm &&\
make -j$(nproc) && make install)

echo -e "\033[49;32m install llvmorg-11.0.0 success! \033[0m"; echo

# 安装ccls
echo -e "\033[49;33m start install ccls...... \033[0m"; sleep 1
(git clone --depth=1 --recursive https://github.com/MaskRay/ccls && \
cd ccls && \
cmake -H. -BRelease -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=$APPSPATH && \
cmake -DCMAKE_INSTALL_PREFIX=$APPSPATH --build Release && \
cd Release && make -j$(nproc) && make install)

echo -e "\033[49;32m install ccls success! \033[0m"; echo

echo -e "\033[49;32m finish! \033[0m"; echo
