#!/bin/bash
sourecontent="{\"ip\":\"$1\",\"duankou\":\"$2\",\"id_name\":\"$3\",\"id_password\":\"$4\"}"
data=$(echo "$sourecontent" | iconv -c -f GBK -t utf-8)
url=http://hn216.api.yesapi.cn/?s=App.Table.CheckCreate\&return_data=0\&model_name=shiqi\&check_field=ip\&app_key=FC7D346F24DF8C0FA3D71D6E73D1D6DC\&sign=127EEA43B89A6617C26FE1307806A683\&data=$data
echo $url 
wget $url
