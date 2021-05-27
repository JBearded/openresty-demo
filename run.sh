#!/bin/bash

user root root;

#环境配置
while [ -n "$1" ]
do
    case $1 in
        --env)
            shift
            environment=$1
            ;;
        --build)
            build_flag=1
            ;;
    esac
    shift
done
environment=${environment:-prod}

base_dir=`pwd`
openresty_source_dir=$base_dir/lib/openresty-1.19.3.1

app_build_dir=/data/apps/openresty
if [ ! -d $app_build_dir ]
then
    mkdir -p $app_build_dir
    chmod 755 -R $app_build_dir
fi

#构建openresty
if [ -n "$build_flag" ]
then
    #安装依赖
    apt-get install libpcre3-dev libssl-dev perl make build-essential curl zlib1g-dev
    #安装openresty
    chmod 755 -R $openresty_source_dir
    pushd $openresty_source_dir
    ./configure --prefix=$app_build_dir && make && make install
    popd
fi

#源码拷贝到openresty运行目录
if [ ! -d $app_build_dir/nginx/src ]
then
    mkdir -p $app_build_dir/nginx/src
fi

cp -r $base_dir/src/* $app_build_dir/nginx/src/
echo "finish cp -r $base_dir/src/* $app_build_dir/nginx/src/"

cp $base_dir/src/config/config-$environment.lua $app_build_dir/nginx/src/config.lua
echo "finish cp $base_dir/src/config/config-$environment.lua $app_build_dir/nginx/src/config.lua"

cp $base_dir/nginx/nginx.conf $app_build_dir/nginx/conf/nginx.conf
echo "finish cp $base_dir/nginx/nginx.conf $app_build_dir/nginx/conf/nginx.conf"

chmod 755 -R $app_build_dir

#启动进程
pushd $app_build_dir/nginx
pid=$(ps aux | grep -v grep | grep 'nginx: master' | awk '{print $2}')
if [ -z "$pid" ]
then
    echo "no nginx running, will start nginx"
    nice -n -10 ./sbin/nginx
else
    echo "nginx already running, will restart it"
    ./sbin/nginx -s reload
    renice -n -10 -g $pid
fi
popd