#!/bin/bash

#  生成要屏蔽的域名... MVPS HOSTS​​​​​​​​​....
curl  "http://winhelp2002.mvps.org/hosts.txt" -o hosts.txt
sed -i '/^#/d; /localhost/d; /^$/d; s/0.0.0.0 //g; s/ //' hosts.txt
sed -i 's/#\(.*\)//g' hosts.txt
sed -i '/^\s*$/d' hosts.txt
sed -i 's/^/"/; s/\s*$/",/' hosts.txt
sed -i '$s/,//' hosts.txt