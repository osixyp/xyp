#!/bin/bash

nginx_pkg='nginx-1.5.1.tar.gz'
nginx_prefix=/usr/local/nginx
html=/var/nginx
log=/var/log/nginx

check13 () {
   [ $UID -ne 0 ] && echo "need to be root to that" && exit 1
   [ ! -f $nginx_pkg ]  && echo "not found source packager" && exit 1
   [ ! -d $html ] && mkdir -p $html
   [ ! -d $log ] && mkdir -p $log
}

nginx_install () {
   source_pkg=`echo $nginx_pkg|awk -F ".tar" '{print $1}'` 
   [ -d /usr/src/$source_pkg ]&&rm -rf /usr/src/$source_pkg
   tar xf $nginx_pkg -C /usr/src
   cp nginxd /usr/src/$source_pkg
	if [ $? -eq 0 ];then
		cd /usr/src/$source_pkg
		if [ $? -eq 0 ];then
			yum -y install gcc-* pcre pcre-devel zlib zlib-devel openssl-* &> /dev/null
			[ $? -ne 0 ]&&"YUM set error" && exit 1
			./configure --prefix=$nginx_prefix
			if [ $? -eq 0 ];then
				make
				if [ $? -eq 0 ];then
					make install
					if [ $? -eq 0 ];then
						ln -s -f $nginx_prefix/conf/nginx.conf /etc/
						ln -s -f $nginx_prefix/logs/ $log/logs
						ln -s -f $nginx_prefix/html $html/html
						ln -s -f $nginx_prefix/sbin/ /usr/sbin/
						cp nginxd /etc/init.d/nginx;chmod 755 /etc/init.d/nginx
					else
                                         	exit 1
					fi
				else
					exit 1
				fi
			else	
				exit 1
			fi
		else
			exit 1
		fi
	else
		exit 1
fi
 [ $? -eq 0 ]&&clear||exit
   echo -e "\n\033[32m Nginx Install Success: \033[0m"
   echo -e "\n"
   echo -e "\tNginx_conf: /etc/nginx.conf"
   echo -e "\tNginx_html: $html/html"
   echo -e "\tNginx_access_log: $log/logs/access.log"
   echo -e "\tNginx_error_log: $log/logs/error.log\n\n\n\n"
   read -n1 -p "press any key and exit...."
   echo 
}

check13
nginx_install
