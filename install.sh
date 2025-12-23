#! /bin/bash

uid=`echo "$UID"`
if [ $uid -ne 0 ];then
echo "改程序需要以root身份运行"
exit
fi

cd Quectel_Linux_USB_Serial_Option_Driver_v5.6.11
make clean
make
make install

cd ..
cd qmi_wwan_V1.2.0.14
make clean
make
make install

cd ..
cd quectel-CM-v1.6.1
make clean
make
make install
