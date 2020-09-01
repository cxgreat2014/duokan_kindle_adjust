#!/bin/sh
#
# DuoKan 2014 Installation
# support email: kindleuser [at] duokan.com
# update 2015-04-22
#
# Kindle 3 , Kindle 4 , Kindle 4 Black
# IS_VE=4
#
# Kindle Touch v5.0.0 - v5.0.4, v5.1.0, v5.1.1, v5.1.2, v5.3.2, v5.3.2.1, v5.3.7, v5.3.7.1 ; Kindle Paperwhite 5.2.0 , 5.3.0, 5.3.1 - 5.3.9, 5.4.4-5.4.4.2
# Kindle Paperwhite 2nd Generation 5.4.0, 5.4.2, 5.4.2.1, 5.4.3-5.4.3.2, (todo 5.4.5 , 5.4.5.1 )
# IS_VE=5
#

IS_VE=5
IS_K1=0
IS_K2=0
IS_K3=0
IS_K4=0
IS_K5=0
IS_KP=0
IS_KP2=0
IS_KDX=0
IS_DEBUG=0

#
# defines
#

SYS_OLD_PATH="/test"
SYS_LITE_PATH="/test/DKLite"
LITE_USER_PATH="/mnt/us/DK_System/Lite"

DUOKAN_SYS_PATH="/DuoKan"
DUOKAN_RES="/DuoKan/res"
DUOKAN_USB_PATH="/mnt/us/DK_System"
DUOKAN_INSTALLER_PATH="/mnt/us/DK_System/install"
DUOKAN_USER_PATH="/mnt/us/DK_System/xKindle"
DUOKAN_SYSFONTS_PATH="/DuoKan/res/sysfonts"
DUOKAN_USERFONTS_PATH="/mnt/us/DK_System/xKindle/res/userfonts"
DUOKAN_WEBBROWSER_PATH="/mnt/us/DK_System/xKindle/web_browser"
DUOKAN_TTS_PATH="/mnt/us/DK_System/xKindle/res/tts"

REBOOT_TAG=/var/reboottag
INSTALL_TAG=/var/installtag

ARG1=$1
ROW=5
COL=22
NEWLINE=5

START=`date +%s`
TOTAL_TIMES=$(($START + 0))
TIMES=0


start_framework()
{
	echo "start_framework"
	if [ -f /etc/init.d/framework ] ; then
		/etc/init.d/framework start
	else
		start x
	fi
}

stop_framework()
{
	echo "stop_framework"
	if [ -f /etc/init.d/framework ] ; then
		/etc/init.d/framework stop
	else
		stop x
		stop early_progress
	fi
}

clean_install_sh()
{
	rm -f $DUOKAN_INSTALLER_PATH/liteinstall.sh
	rm -f $DUOKAN_INSTALLER_PATH/DuoKanInstall.sh	
	sync
					
	if [ -f $DUOKAN_INSTALLER_PATH/liteinstall.sh ] ; then
		mv -f $DUOKAN_INSTALLER_PATH/liteinstall.sh $DUOKAN_INSTALLER_PATH/liteinstall.sh.tmp
	fi

	if [ -f $DUOKAN_INSTALLER_PATH/DuoKanInstall.sh ] ; then
		mv -f $DUOKAN_INSTALLER_PATH/DuoKanInstall.sh $DUOKAN_INSTALLER_PATH/DuoKanInstall.sh.tmp
	fi
	rm -f $DUOKAN_INSTALLER_PATH/*.tmp
	rm -f $DUOKAN_INSTALLER_PATH/*.tmp
}

install_duokan_diags()
{
	MNT_PATH="/cust"

	mntroot rw
	mkdir -p $MNT_PATH
	mount /dev/mmcblk0p1 $MNT_PATH

	if [ -f $DUOKAN_INSTALLER_PATH/duokan.conf ] ; then
		cp $DUOKAN_INSTALLER_PATH/duokan.conf $MNT_PATH/etc/upstart/duokan.conf
		chmod +x $MNT_PATH/etc/upstart/duokan.conf
	fi
	
	if [ -f $DUOKAN_INSTALLER_PATH/DK_update ] ; then
		cp $DUOKAN_INSTALLER_PATH/DK_update $MNT_PATH/etc/init.d/DK_update
		chmod +x $MNT_PATH/etc/init.d/DK_update
	fi

	# kindle.conf only exist on KT/KP, if not, it must be K3/K4
	if [ ! -f $MNT_PATH/etc/upstart/kindle.conf ] ; then
		ln -s ../init.d/DK_update $MNT_PATH/etc/rc5.d/S79DK_update
		ln -s ../init.d/framework $MNT_PATH/etc/rc5.d/S95framework
	fi

	sync
	mntroot ro
}

set_bootmode_main()
{
	idme -d --bootmode main
	rm -f /mnt/us/ENABLE_DIAGS
}

# sometimes reboot hangs
do_reboot()
{
	reboot
	sleep 5
	reboot -n
	reboot -f
	sleep 60
	return
}

check_bootmode_diags()
{
	BOOTMODE=`idme --bootmode ?`

	if [ "$BOOTMODE"_x != "diags"_x ] ; then
		echo "bootmode not diags"
		return
	fi

	install_duokan_diags
	set_bootmode_main
	do_reboot
}

switch_to_kindle()
{
	enable_usb_storage
	
	EXIT_TIME=$(($1 + 0))
	NEWLINE=$(($NEWLINE + 2))

	eips $ROW $NEWLINE "Switch to Kindle in $EXIT_TIME seconds ..."
	
	while [ $EXIT_TIME != 0 ]
	do
		sleep 1
		EXIT_TIME=$(($EXIT_TIME - 1))
		eips $ROW $NEWLINE "Switch to Kindle in $EXIT_TIME seconds ..."
	done

	start_framework
}

reboot_in_seconds()
{	
	clean_install_sh
	set_bootmode_main
	
	EXIT_TIME=$(($1 + 1))

	NEWLINE=$(($NEWLINE + 2))
	eips $ROW $NEWLINE "REBOOT in $EXIT_TIME seconds ..."

	while [ $EXIT_TIME != 0 ]
	do
		sleep 1
		EXIT_TIME=$(($EXIT_TIME - 1))
		eips $ROW $NEWLINE "REBOOT in $EXIT_TIME seconds ..."
	done
	
	NEWLINE=$(($NEWLINE + 2))
	eips $ROW $NEWLINE "Kindle is REBOOTING ..."

	do_reboot
}

ready_in_seconds()
{	
	EXIT_TIME=$(($1 + 1))

	eips $ROW $NEWLINE "Ready in $EXIT_TIME seconds ..."

	while [ $EXIT_TIME != 0 ]
	do
		sleep 1
		EXIT_TIME=$(($EXIT_TIME - 1))
		eips $ROW $NEWLINE "Ready in $EXIT_TIME seconds ..."
	done
	
	NEWLINE=$(($NEWLINE + 2))
}

print_pattern()
{	
	stop_framework
	eips -c -f
	eips -p
	eips -q
	sleep 1
}

take_screenshot()
{	
	if [ -x /usr/sbin/screenshot ] ; then
		/usr/sbin/screenshot
	fi
}

print_duokan_title_bar()
{	
	eips -c -f
	NEWLINE=2
	eips $ROW $NEWLINE " _________________________________ "
	NEWLINE=$(($NEWLINE + 2))
	eips $ROW $NEWLINE "|  DUOKAN 2014 AUTO INSTALLATION  |"
	NEWLINE=$(($NEWLINE + 1))
	eips $ROW $NEWLINE " _________________________________ "
	NEWLINE=$(($NEWLINE + 2))
}

check_kindle_k3k4()
{
	IS_K34=$(($IS_K3 + $IS_K4))

	if [ $IS_K34 != 0  ] ; then
		eips $ROW $NEWLINE "( OK, DuoKan is ready for the Device )"
		NEWLINE=$(($NEWLINE + 2))	
	else	
		enable_usb_storage
		sleep 1
		eips $ROW $NEWLINE "( ERROR, Device is not Kindle 3 / 4 )"
		NEWLINE=$(($NEWLINE + 2))		
		clean_install_sh
		switch_to_kindle 20
		exit
	fi
			
	if [ $IS_K4 != 0 ] ; then
		cp -f /mnt/us/DK_System/bin/8bit/* /mnt/us/DK_System/bin/
	fi

	if [ $IS_K3 != 0 ] ; then
		cp -f /mnt/us/DK_System/bin/4bit/* /mnt/us/DK_System/bin/
	fi

}

check_kindle_k5kp()
{
	IS_K5KP=$(($IS_K5 + $IS_KP + $IS_KP2))
		
	if [ $IS_K5KP != 0 ] ; then
		eips $ROW $NEWLINE "( OK, DuoKan is ready for the Device )"
		NEWLINE=$(($NEWLINE + 2))	
	else
		enable_usb_storage
		sleep 1
		eips $ROW $NEWLINE "( ERROR, Device is not KP / KT )"
		NEWLINE=$(($NEWLINE + 2))
		clean_install_sh
		switch_to_kindle 20
		exit
	fi
}

check_kindle_version()
{
	KINDLE_SN=`cat /proc/usid`
	Processor=`cat /proc/cpuinfo | grep Processor`
	Hardware=`cat /proc/cpuinfo | grep Hardware`
	Revision=`cat /proc/cpuinfo | grep Revision`
	MAC=`cat /proc/mac_addr`

	temp=$(expr substr "$KINDLE_SN" 1 4)	
	case $temp in
	B001)
		IS_K1=1
		KINDLE_INFO="Kindle 1"
		;;
	B002)
		IS_K2=1
		KINDLE_INFO="Kindle 2 U.S."
		;;
	B003)
		IS_K2=1
		KINDLE_INFO="Kindle 2 International"
    ;;
	B004)
		IS_KDX=1
		KINDLE_INFO="Kindle DX U.S."
    ;;
	B005)
		IS_KDX=1
		KINDLE_INFO="Kindle DX International"
    ;;
	B009)
		IS_KDX=1
		KINDLE_INFO="Kindle DX Graphite"
    ;;
	B006)
		IS_K3=1
		KINDLE_INFO="Kindle 3 3G+WiFi U.S. (K3)"
    ;;
	B008)
		IS_K3=1
		KINDLE_INFO="Kindle 3 WiFi (K3)"
    ;;
	B00A)
		IS_K3=1
		KINDLE_INFO="Kindle 3 3G+WiFi Graphite (k3)"
    ;;
	B00E)
		IS_K4=1
		KINDLE_INFO="Kindle 4 WiFi (K4)"
    ;;
	B00F)
		IS_K5=1
		KINDLE_INFO="Kindle Touch 3G (KT)"
    ;;	
	B010)
		IS_K5=1
		KINDLE_INFO="Kindle Touch 3G I (KT)"
    ;;
	B011)
		IS_K5=1
		KINDLE_INFO="Kindle Touch WiFi (KT)"
    ;;
	B023)
		IS_K4=1
		KINDLE_INFO="Kindle 4 WiFi Black (K4)"
    ;;
	B024)
		IS_KP=1
		KINDLE_INFO="Kindle PaperWhite WiFi (KP)"
    ;;
	B01B)
		IS_KP=1
		KINDLE_INFO="Kindle PaperWhite 3G U.S.(KP)"
    ;;
	B01C)
		IS_KP=1
		KINDLE_INFO="Kindle PaperWhite 3G Can.(KP)"
    ;;
	B01D)
		IS_KP=1
		KINDLE_INFO="Kindle PaperWhite 3G EU (KP)"
    ;;
	B01F)
		IS_KP=1
		KINDLE_INFO="Kindle PaperWhite 3G JP (KP)"
    ;;
	B020)
		IS_KP=1
		KINDLE_INFO="Kindle PaperWhite 3G (KP)"
    ;;
	9023)
		IS_K4=1
		KINDLE_INFO="Kindle 4 WiFi Black (K4)"
    ;;
	B05A | B0D4 | 90D4 | 905A )
		IS_KP2=1
		KINDLE_INFO="Kindle PaperWhite2 WiFi(KPW2)"
    ;;
	B0D5 | B0D6 | B0D7 | B0D8 | B0D9 | B0F2 | 90D5 | 90D6 | 90D7 | 90D8 | 90D9 | 90F2 )
		IS_KP2=1
		KINDLE_INFO="Kindle PaperWhite2 3G(KPW2 3G)"
    ;;
	B05F | B0F4 | B0F9 | 905F | 90F4 | 90F9 )
		IS_KP2=1
		KINDLE_INFO="Kindle PaperWhite2 (KPW2)"
    ;; 
	B017 | B060 | B062 | 9017 | 9060 | 9062 )
		IS_KP2=1
		KINDLE_INFO="Kindle PaperWhite2 (4GB MMC)"
    ;;
	*)
		KINDLE_INFO="Unkown Type"
    ;;
	esac

	eips $ROW $NEWLINE "$Processor"
	NEWLINE=$(($NEWLINE + 1))

	eips $ROW $NEWLINE "$Hardware"
	NEWLINE=$(($NEWLINE + 1))

	eips $ROW $NEWLINE "$Revision"
	NEWLINE=$(($NEWLINE + 1))
	
	# eips $ROW $NEWLINE "WiFi MAC ADDR : $MAC"
	# NEWLINE=$(($NEWLINE + 1))

	eips $ROW $NEWLINE "Serial Number : $KINDLE_SN"
	NEWLINE=$(($NEWLINE + 2))
	
	eips $ROW $NEWLINE "Device is $KINDLE_INFO"
	NEWLINE=$(($NEWLINE + 2))
	
	case $IS_VE in
	4)
		check_kindle_k3k4
		;;
	5)
		check_kindle_k5kp
		;;
	*)
		eips $ROW $NEWLINE "DEBUG VERSION"
		NEWLINE=$(($NEWLINE + 2))
		enable_usb_storage
		exit 0
    ;;
	esac
	
	eips $ROW $NEWLINE "++++++++++++++++++++++++++++++++"
	NEWLINE=$(($NEWLINE + 2))
}

mv_old_sysfonts_and_res()
{
	mntroot rw

	for name in hwkt fzxbsjt fzltkh_gbk hyfs fzssjt DejaVu Arial GenBkBasR trebuc Comic Inconsolata
	do
		cp $DUOKAN_SYSFONTS_PATH/$name* $DUOKAN_USERFONTS_PATH/
		rm -f $DUOKAN_SYSFONTS_PATH/$name*
	done

	for name in home.bmp start.bmp splash_logo.bmp USBdevice.bmp start2013.jpg start2013@kp.jpg
	do
		rm -f $DUOKAN_RES/$name
	done

	sync
}

fix_lost_space()
{	
	usMB=`du -m -d 0 /mnt/base-us | awk '{print $1}'`

	umount /mnt/base-us
	baseusMB=`du -m -d 0 /mnt/base-us | awk '{print $1}'`

	echo "Fix lost space $usMB MB, $baseusMB MB"
	if [ $IS_DEBUG != 0 ] ; then
		eips $ROW $NEWLINE "Fix lost space $usMB MB, $baseusMB MB"
		NEWLINE=$(($NEWLINE + 2))
	fi
	
	if [ $usMB -eq $baseusMB ] ; then
		mount /mnt/base-us
		return
	fi
		
	if [ -d /mnt/base-us/DK_System/install ] ; then
		mount /mnt/base-us
		return
	fi

	rm -rf /mnt/base-us/*
	mount /mnt/base-us	
}


# /DuoKan  for k3, k4 , kt (size in MB ):
# add 1 MB rich
check_free_space()
{
	DK3=54
	DK4=57
	DK5=57
	DKP=57
	DKP2=52
	ADD=2
	DK=0
	DKOLD=0
	SHORTAGE=0
	ROOT=0
	USED=0
	FREE=0
	AVAILABLE=0

	# suppose the installation is INSTALL
	ARG1=1
	touch $INSTALL_TAG

	# if exist /DuoKan, the installation logic is UPDATE
	if [ -e $DUOKAN_SYS_PATH ] ; then
		ARG1=0
		rm -f $INSTALL_TAG

		eips $ROW $NEWLINE "Found DuoKan in ROOTFS"
		NEWLINE=$(($NEWLINE + 2))

		mv_old_sysfonts_and_res
		DKOLD=`du -m -d 0 $DUOKAN_SYS_PATH | awk '{print $1}' | grep [0-9]`

		eips $ROW $NEWLINE "DuoKan already used $DKOLD MB"
		NEWLINE=$(($NEWLINE + 2))
	fi

	fix_lost_space

	# let's check k3/k4/k5 space
	
	if [ $IS_K3 != 0 ] ; then
		ROOT=`df -m | grep mmcblk0p1 | awk '{print $2}' | grep [0-9][0-9] | head -1`
		USED=`df -m | grep mmcblk0p1 | awk '{print $3}' | grep [0-9] | head -1`
		FREE=`df -m | grep mmcblk0p1 | awk '{print $4}' | grep [0-9] | head -1`
		DK=$DK3
	fi

	if [ $IS_K4 != 0 ] ; then
		ROOT=`df -m | grep mmcblk0p1 | awk '{print $2}' | grep [0-9][0-9] | head -1`
		USED=`df -m | grep mmcblk0p1 | awk '{print $3}' | grep [0-9] | head -1`
		FREE=`df -m | grep mmcblk0p1 | awk '{print $4}' | grep [0-9] | head -1`
		DK=$DK4
	fi

	if [ $IS_K5 != 0 ] ; then
		ROOT=`df -m / | awk '{print $2}' | grep [0-9][0-9]`
		USED=`df -m / | awk '{print $3}' | grep [0-9]`
		FREE=`df -m / | awk '{print $4}' | grep [0-9]`
		DK=$DK5
	fi

	if [ $IS_KP != 0 ] ; then
		ROOT=`df -m / | awk '{print $2}' | grep [0-9][0-9]`
		USED=`df -m / | awk '{print $3}' | grep [0-9]`
		FREE=`df -m / | awk '{print $4}' | grep [0-9]`
		DK=$DKP
	fi

	if [ $IS_KP2 != 0 ] ; then
		ROOT=`df -m / | awk '{print $2}' | grep [0-9][0-9]`
		USED=`df -m / | awk '{print $3}' | grep [0-9]`
		FREE=`df -m / | awk '{print $4}' | grep [0-9]`
		DK=$DKP2
	fi

	# add 3 MB more
	AVAILABLE=$(($ROOT - $USED - 3))
	if [ $AVAILABLE -gt $FREE ] ; then
		FREE=$AVAILABLE
	fi

	eips $ROW $NEWLINE "ROOTFS     $ROOT MB"
	NEWLINE=$(($NEWLINE + 1))
	eips $ROW $NEWLINE "USED       $USED MB"
	NEWLINE=$(($NEWLINE + 1))
	eips $ROW $NEWLINE "FREE ABOVE $FREE MB"
	NEWLINE=$(($NEWLINE + 2))

	NEED=$(($DK + $ADD))
	AVAILABLE=$(($FREE + $DKOLD))
	eips $ROW $NEWLINE "NEED $NEED MB, AVAILABLE $AVAILABLE MB"
	NEWLINE=$(($NEWLINE + 2))

	if [ $NEED -gt $AVAILABLE ] ; then
		SHORTAGE=$(($NEED - $AVAILABLE ))
		eips $ROW $NEWLINE "NOT ENOUGH SPACE, SHORTAGE $SHORTAGE MB"
		NEWLINE=$(($NEWLINE + 2))
        eips $ROW $NEWLINE "SETUP HAS SUCCESSFULLY QUIT"
        NEWLINE=$(($NEWLINE + 2))
		take_screenshot
		clean_install_sh
		switch_to_kindle 20
	fi

	eips $ROW $NEWLINE "(Free space is OK, ready to install)"
	NEWLINE=$(($NEWLINE + 2))
	ready_in_seconds 10
}

start_times()
{
	START=`date +%s`
	TOTAL_TIMES=$(($START + 0))
	TIMES=0
}

get_times()
{
	END=`date +%s`
	TIMES=$(($END - $START + 0))
	START=$(($END + 0))  
}

get_total_times()
{
	END=`date +%s`
	TOTAL_TIMES=$(($END - $TOTAL_TIMES))
}

disable_usb_storage()
{
	modprobe -r g_file_storage
}

enable_usb_storage()
{
	modprobe g_file_storage "removable=y"
}

print_begin()
{
	stop_framework
	eips -c
	eips -r  "DuoKan is installing. Wait about 3 minutes."
	if [ "$ARG1" -eq "1" ] ; then
		eips $ROW $COL "Running DuoKan Update ......"
	else
		eips $ROW $COL "Running DuoKan Install ......"
	fi 
	sleep 1 
}

print_mid()
{
	eips -c
	eips -r  "Copying new files ... Wait about 2 minutes."
	if [ "$ARG1" -eq "1" ] ; then
		eips $ROW $COL "Running DuoKan Update ......"
	else
		eips $ROW $COL "Running DuoKan Install ......"
	fi 
	sleep 1 
}

print_end()
{

	eips $ROW $NEWLINE "Install OK, Start in 5 seconds..."
}

print_reboot()
{
	eips $ROW $NEWLINE "Install OK, Reboot in 1 minute..."
}

#killall the app before installation happening 
stop_duokan()
{
	kill -9 `ps -A | grep KindleApp | awk '{print $1}'`
	kill -9 `ps -A | grep UsbSignal.bin | awk '{print $1}'`
	kill -9 `ps -A | grep BatterySignal.bin | awk '{print $1}'`
	kill -9 `ps -A | grep notCharging.bin| awk '{print $1}'`
	kill -9 `ps -A | grep Charging.bin| awk '{print $1}'`
	kill -9 `ps -A | grep PowerState.bin| awk '{print $1}'`
	kill -9 `ps -A | grep suspending.bin| awk '{print $1}'`
	killall -9 lipc-wait-event
		
	# disable the ScreenSaver
	# lipc-set-prop com.lab126.powerd preventScreenSaver 1
}

install_lib_lnk()
{    
	cd  $DUOKAN_SYS_PATH/lib

	ln -s ./libasound.so ./libasound.so.2

	ln -s ./libcharset.so.1.0.0 ./libcharset.so
	ln -s ./libcharset.so.1.0.0 ./libcharset.so.1

	ln -s ./libcurl.so.4.3.0 ./libcurl.so
	ln -s ./libcurl.so.4.3.0 ./libcurl.so.4

	ln -s ./libfreetype.so.6.5.0 ./libfreetype.so
	ln -s ./libfreetype.so.6.5.0 ./libfreetype.so.6

	ln -s ./libiconv.so.2.5.0 ./libiconv.so
	ln -s ./libiconv.so.2.5.0 ./libiconv.so.2

	ln -s ./libxml2.so.2.7.4 ./libxml2.so
	ln -s ./libxml2.so.2.7.4 ./libxml2.so.2 

	ln -s ./libz.so.1.2.5 ./libz.so
	ln -s ./libz.so.1.2.5 ./libz.so.1 

	ln -s ./libzip.so.2.1.0 ./libzip.so
	ln -s ./libzip.so.2.1.0 ./libzip.so.2

	ln -s ./libjson-c.so.2.0.0 ./libjson-c.so.2
	ln -s ./libjson-c.so.2.0.0 ./libjson-c.so
}

clean_old_dk_lite()
{
	#rm all old DuoKan script
	
	rm -f /etc/rc5.d/rundk.sh 
	rm -f /etc/rc5.d/duokantag 

	rm -f /etc/rc5.d/S79switch
	rm -f /etc/rc5.d/S95dkupdate 
	rm -f /etc/rc5.d/S96rundk
	
	rm -f /etc/rcS.d/S79switch
	rm -f /etc/rcS.d/S95DK_switch

	rm -rf $SYS_LITE_PATH
	rm -rf $SYS_OLD_PATH
}

instal_dk_lnk()
{
	ln -s /etc/init.d/DK_update /etc/rc5.d/S79DK_update
	ln -s /etc/init.d/DK_switch /etc/rc5.d/S95DK_switch
	ln -s /etc/init.d/DK_run 	/etc/rc5.d/S96DK_run
	ln -s /etc/init.d/framework 	/etc/rc5.d/S95framework
}

check_dk_scripts()
{
	for name in DK_update DK_switch DK_run duokan.conf
	do
		OLDFILE=$DUOKAN_SYS_PATH/$name
		NEWFILE=$DUOKAN_USB_PATH/install/$name			
		if [ -f $OLDFILE ] && [ -f $NEWFILE ] ; then
			MD5OLD=`md5sum $OLDFILE | awk '{print $1}'`
			MD5NEW=`md5sum $NEWFILE | awk '{print $1}'`				
				if [ "$MD5OLD" != "$MD5NEW" ]; then
					touch $REBOOT_TAG
				fi
		fi
	done
}

install_dk_scripts()
{
	mntroot rw
	rm -f /core.*

	clean_old_dk_lite

	if [ -f $DUOKAN_USB_PATH/install/DK_update ]; then
		cp -f $DUOKAN_USB_PATH/install/DK_update 	/etc/init.d/DK_update
		chmod +x /etc/init.d/DK_update
	fi

	if [ -f $DUOKAN_USB_PATH/install/DK_switch ]; then
		cp -f $DUOKAN_USB_PATH/install/DK_switch 	/etc/init.d/DK_switch
		chmod +x /etc/init.d/DK_switch				
	fi

	if [ -f $DUOKAN_USB_PATH/install/DK_run ]; then
		cp -f $DUOKAN_USB_PATH/install/DK_run 	/etc/init.d/DK_run
		chmod +x /etc/init.d/DK_run
	fi

	if [ $IS_K4 != 0 ] ; then
		instal_dk_lnk
	fi

	if [ $IS_K3 != 0 ] ; then
		instal_dk_lnk
	fi

	cp -f $DUOKAN_USB_PATH/install/DuoKanUninstall.sh	$DUOKAN_SYS_PATH/
}

# for K3K4 /K5
make_wifi_script()
{	
	if [ -f $DUOKAN_USER_PATH/wifi ] ; then
		rm -f $DUOKAN_SYS_PATH/wifi
		cp -f $DUOKAN_USER_PATH/wifi $DUOKAN_SYS_PATH/
		rm -f $DUOKAN_USER_PATH/wifi
	fi

	chmod +x $DUOKAN_SYS_PATH/wifi
}

install_dk_k3_special()
{
	if [ $IS_K3 != 1 ] ; then
		return
	fi
	
	rm -f $DUOKAN_USER_PATH/powerd5*
	rm -f $DUOKAN_SYS_PATH/powerd5*

	rm -f $DUOKAN_USER_PATH/lib/libssl.so.0.9.8
	rm -f $DUOKAN_USER_PATH/lib/libcrypto.so.0.9.8

	rm -f $DUOKAN_SYS_PATH/lib/libssl.so.0.9.8
	rm -f $DUOKAN_SYS_PATH/lib/libcrypto.so.0.9.8
}

install_dk_k4_special()
{
	if [ $IS_K4 != 1 ] ; then
		return
	fi

	rm -f $DUOKAN_USER_PATH/mplayer
	rm -f $DUOKAN_SYS_PATH/mplayer
	
	rm -f $DUOKAN_USER_PATH/powerd5*
	rm -f $DUOKAN_SYS_PATH/powerd5*

	rm -f $DUOKAN_USER_PATH/lib/libssl.so.0.9.8
	rm -f $DUOKAN_USER_PATH/lib/libcrypto.so.0.9.8

	rm -f $DUOKAN_SYS_PATH/lib/libssl.so.0.9.8
	rm -f $DUOKAN_SYS_PATH/lib/libcrypto.so.0.9.8
	
	rm -rf $DUOKAN_TTS_PATH
}

install_dk_k5_special()
{
	if [ $IS_K5 != 1 ] ; then
		return
	fi

	rm -f $DUOKAN_USER_PATH/powerd520
	rm -f $DUOKAN_USER_PATH/powerd530
	
	rm -f $DUOKAN_SYS_PATH/powerd520
	rm -f $DUOKAN_SYS_PATH/powerd530

	rm -f $DUOKAN_USER_PATH/res/ScreenSaver/*@kp.jpg
	
	if [ ! -f /usr/bin/powerd.old ]; then
		cp -f /usr/bin/powerd /usr/bin/powerd.old
	fi
}

install_dk_kp_special()
{
	if [ $IS_KP != 1 ] ; then
		return
	fi
	
	rm -f $DUOKAN_USER_PATH/mplayer
	rm -f $DUOKAN_SYS_PATH/mplayer
	
	rm -f $DUOKAN_USER_PATH/powerd51*
	rm -f $DUOKAN_SYS_PATH/powerd51*
	
	rm -f $DUOKAN_USER_PATH/res/ScreenSaver/*@kt.jpg
	
	rm -rf $DUOKAN_TTS_PATH
}

install_dk_kp2_special()
{
	if [ $IS_KP2 != 1 ] ; then
		return
	fi
	
	rm -f $DUOKAN_USER_PATH/mplayer
	rm -f $DUOKAN_SYS_PATH/mplayer
	
	rm -f $DUOKAN_USER_PATH/powerd51*
	rm -f $DUOKAN_SYS_PATH/powerd51*

	rm -f $DUOKAN_USER_PATH/powerd52*
	rm -f $DUOKAN_SYS_PATH/powerd52*

	rm -f $DUOKAN_USER_PATH/powerd53*
	rm -f $DUOKAN_SYS_PATH/powerd53*

	rm -f $DUOKAN_USER_PATH/res/ScreenSaver/*@kt.jpg

	rm -rf $DUOKAN_TTS_PATH
}

clean_old_lib()
{    
	cd  $DUOKAN_SYS_PATH/lib

	rm -f ./libcurl.so.4.2.0 ./libcurl.so ./libcurl.so.4
	rm -f ./libjson.so
}

install_dk_duokan_and_lib()
{
	mntroot rw
	
	if [ ! -e $DUOKAN_SYS_PATH ] ; then
		mkdir -p $DUOKAN_SYS_PATH
	fi

	install_dk_k3_special
	install_dk_k4_special
	install_dk_k5_special
	install_dk_kp_special
	install_dk_kp2_special

	make_wifi_script

	cp -f $DUOKAN_USER_PATH/* $DUOKAN_SYS_PATH/
	chmod +x $DUOKAN_SYS_PATH/*

	rm -f $DUOKAN_SYS_PATH/*.log
	rm -f $DUOKAN_SYS_PATH/installlib.sh

	if [ ! -e $DUOKAN_SYS_PATH/lib ] ; then
		mkdir -p $DUOKAN_SYS_PATH/lib
	fi
	
	# lib files

    # clean
    clean_old_lib

	cp -f $DUOKAN_USER_PATH/lib/* $DUOKAN_SYS_PATH/lib/
	
	rm -rf $DUOKAN_USER_PATH/lib
	rm -f $DUOKAN_USER_PATH/KindleApp
	rm -f $DUOKAN_USER_PATH/mplayer
	rm -f $DUOKAN_USER_PATH/ntpdate
	rm -f $DUOKAN_USER_PATH/miniftp*
	rm -f $DUOKAN_USER_PATH/*.bin
	rm -f $DUOKAN_USER_PATH/power*
	rm -f $DUOKAN_USER_PATH/installlib.sh
	rm -f $DUOKAN_USER_PATH/LayoutDemo.txt
}

# res files for kpw2 / kpw after 5.4.4
install_dk_duokan_res_kpw2()
{
	mntroot rw

	# res	
	if [ ! -e $DUOKAN_RES ] ; then
		mkdir -p $DUOKAN_RES
	fi

	# LINK file to res/py , Resource
	if [ ! -L $DUOKAN_SYS_PATH/Resource ] ; then
 		rm -rf $DUOKAN_SYS_PATH/Resource
		ln -s $DUOKAN_USER_PATH/Resource/ $DUOKAN_SYS_PATH/Resource
	fi

	if [ ! -L $DUOKAN_RES/py ] ; then
		rm -rf $DUOKAN_RES/py
		ln -s $DUOKAN_USER_PATH/res/py/ $DUOKAN_RES/py
	fi

	cd $DUOKAN_USER_PATH/res

	cp -f $DUOKAN_USER_PATH/res/* $DUOKAN_RES
	cp -rf ./touch ./sysfonts ./CssAliases ./sharedicon $DUOKAN_RES
	rm -f ./*
	rm -rf ./touch ./sysfonts ./CssAliases	./sharedicon
}

# res files for K3/K4/KT
install_dk_duokan_res_old()
{
	mntroot rw

	# res	
	if [ ! -e $DUOKAN_RES ] ; then
		mkdir -p $DUOKAN_RES
	fi

	cd $DUOKAN_USER_PATH/res

	cp -f $DUOKAN_USER_PATH/res/* $DUOKAN_RES
	cp -rf ./touch ./py ./sysfonts ./CssAliases ./sharedicon $DUOKAN_RES
	rm -f ./*
	rm -rf ./touch ./py ./sysfonts ./CssAliases	./sharedicon
		
	# Resource

	if [ ! -e $DUOKAN_SYS_PATH/Resource ] ; then
		mkdir -p $DUOKAN_SYS_PATH/Resource
	fi

	if [ -e $DUOKAN_USER_PATH/Resource ] ; then
		cp -rf  $DUOKAN_USER_PATH/Resource $DUOKAN_SYS_PATH/
		rm -rf $DUOKAN_USER_PATH/Resource
	fi
}

install_dk_duokan_res()
{
	if [ $IS_KP2 != 0 ] ; then
		install_dk_duokan_res_kpw2
		return
	fi

	if [ $IS_KP != 0 ] ; then
		install_dk_duokan_res_kpw2
		return
	fi
	
	install_dk_duokan_res_old
}

install_python_etc()
{
	chmod +x $DUOKAN_USER_PATH/python/bin/iconv
	rm -f $DUOKAN_USER_PATH/res/userfonts/Palatino.ttc
	
	mkdir -p $DUOKAN_USER_PATH/res/ScreenSaver
	mkdir -p $DUOKAN_USER_PATH/res/language 
	mkdir -p $DUOKAN_USER_PATH/res/dict
	mkdir -p $DUOKAN_USER_PATH/res/userfonts
	mkdir -p $DUOKAN_USER_PATH/SQMData

	#merge Lite Configuration
	if [ -d  $LITE_USER_PATH/res ] ; then
		cp -r $LITE_USER_PATH/res/ScreenSaver $DUOKAN_USER_PATH/res
		cp -r $LITE_USER_PATH/res/dict $DUOKAN_USER_PATH/res
		cp -r $LITE_USER_PATH/userfonts $DUOKAN_USER_PATH/res
	fi
	
	rm -rf $DUOKAN_USER_PATH/res/UserScreenSaver
	rm -rf $LITE_USER_PATH
}

install_documents()
{
	mkdir -p /mnt/us/DK_Documents
	mkdir -p /mnt/us/DK_Download
	mkdir -p /mnt/us/DK_News 
	mkdir -p /mnt/us/DK_Sync
}

install_duokanconf()
{	
	if [ -f /mnt/us/DK_System/install/duokan.conf ] ; then
		cp /mnt/us/DK_System/install/duokan.conf /etc/upstart/
		chmod +x /etc/upstart/duokan.conf
	fi
}

clean_script()
{
	rm -f $DUOKAN_USB_PATH/install/top.sh
	rm -f $DUOKAN_USB_PATH/install/duokan.conf
	rm -f $DUOKAN_USB_PATH/install/liteinstall.sh
	rm -f $DUOKAN_USB_PATH/install/DuoKanInstall.sh
	rm -f $DUOKAN_USB_PATH/install/DuoKanInstallK4.sh
	rm -f $DUOKAN_USB_PATH/install/DK_update
	rm -f $DUOKAN_USB_PATH/install/DK_run
	rm -f $DUOKAN_USB_PATH/install/DK_switch
}

# open the firewall for Linux, need to reboot
install_sysconfig_iptables()
{	
	return
}

install_check_reboot()
{
	if [ -f $INSTALL_TAG ] ; then
		rm -f $INSTALL_TAG
		touch $REBOOT_TAG
	fi

	if [ -f $REBOOT_TAG ] ; then
		rm -f $REBOOT_TAG
		print_reboot
		do_reboot
	else
		print_end
	fi
}

uninstall_bambook()
{
	eips $ROW $NEWLINE "Uninstall bambook ..."

	killall -3 sndabrowser
	mntroot rw
	sleep 2
	rmmod g_ether
	umount /var/local/bambook/snb-mnt
	
	# clean scripts 
	rm -f /etc/init.d/bambook
	rm -f /etc/rc5.d/S96bambook

	# clean bambook
	rm -rf /bambook	
	rm -rf /var/local/bambook
	rm -rf /mnt/data
	rm -rf /mnt/key-data

	#clean bambook data
	rm -rf /mnt/us/bambook/

	eips $ROW $NEWLINE "Uninstall bambook OK"
	NEWLINE=$(($NEWLINE + 2))
}

clean_bambook()
{
	if [ -e /bambook ] ; then
		uninstall_bambook
	fi
}

clean_repair()
{
	echo "clean_repair"		
	rm -f /var/local/upstart/*.restarts
	rm -f /var/local/system/.framework_reboots
	rm -f /var/local/system/.framework_retries
}

# if the locale missed, make the default locale 
make_default_locale()
{	
	LOCFILE=/var/local/system/locale
	mkdir -p /var/local/system/
	touch $LOCFILE
	echo LANG=en_US.utf8 > $LOCFILE
	echo LC_ALL=en_US.utf8 >> $LOCFILE
}

make_locale()
{
	LOCFILE=/var/local/system/locale

	if [ ! -f  $LOCFILE ] ; then
		make_default_locale
	fi

	FIND=`cat $LOCFILE | grep -c LANG`
	if [ $FIND -eq 0 ] ; then
		make_default_locale
	fi
}

MD5FILE=/mnt/us/DK_System/install/screensaver_md5.txt
SSPATH=/mnt/us/DK_System/xKindle/res/ScreenSaver
remove_old_screensaver()
{
	if [ ! -f $MD5FILE ] ; then
		return
	fi
		
	SAVEIFS=$IFS;
	IFS=$(echo -en "\n\b")
	FILELIST=`find $SSPATH/* -type f`	
	for FILE in $FILELIST
	do
		IFS=$SAVEIFS
		echo ""
		echo check file: "$FILE"
		md5hash=`md5sum "$FILE" | awk '{print $1}'`
		md5find=`grep -c $md5hash $MD5FILE`
		echo md5hash=$md5hash
		echo md5find=$md5find
		if [ $md5find != "0" ] ; then
			echo same file: "$FILE"
			rm -f "$FILE"
		fi
		IFS=$(echo -en "\n\b")
	done
	rm -f $MD5FILE	
	IFS=$SAVEIFS
}

clean_old_log()
{
	rm -f /var/local/DIAGNOSTIC*
	rm -f /var/local/*.log
}

# /mnt/us/DK_System/duokan
install_web_browser()
{
	if [ ! -e $DUOKAN_WEBBROWSER_PATH ] ; then
		return
	fi

	if [ ! -e $DUOKAN_SYS_PATH/plugins ] ; then
		mkdir -p $DUOKAN_SYS_PATH/plugins
	fi

    cp -f $DUOKAN_WEBBROWSER_PATH/setup* $DUOKAN_SYS_PATH/
    cp -f $DUOKAN_WEBBROWSER_PATH/bin/* $DUOKAN_SYS_PATH/
    chmod +x $DUOKAN_SYS_PATH/*

    cp -rf $DUOKAN_WEBBROWSER_PATH/plugins/* $DUOKAN_SYS_PATH/plugins

    rm -rf $DUOKAN_WEBBROWSER_PATH/setup*
    rm -rf $DUOKAN_WEBBROWSER_PATH/bin
    rm -rf $DUOKAN_WEBBROWSER_PATH/plugins
}


###########################
#
#  begin to install
#
###########################

# very early
check_bootmode_diags

clean_old_log

#stop x / framework
stop_framework

# make the default locale
make_locale

# clean Kindle Repair flag
clean_repair

# TURN OFF USB FILESTORAGE
disable_usb_storage
mntroot rw

# print install pic
print_pattern
print_duokan_title_bar

# check Kindle Version, K3 / K4 / KT
check_kindle_version

# uninstall bambook
clean_bambook

#clean old dk
clean_old_dk_lite

# check the free space
check_free_space

#check the dk_scripts changing
check_dk_scripts

# print installing barcode, or string
print_begin
start_times

# killall the app before installation 
stop_duokan

#print midway barcode
print_mid
NEWLINE=$(($COL + 2))
get_times


# part 1
eips $ROW $NEWLINE "part 1. install_duokan, wait..."

# 0 for kpw 5.4.4, remove old KindleApp
# mntroot rw
# rm -f $DUOKAN_SYS_PATH/KindleApp

# 0 for kpw 5.4.4,  install res
install_dk_duokan_res

# 1. mntroot rw and cp /etc/init.d
install_dk_scripts

# 2. install duokan conf
install_duokanconf

# 3. cp DuoKan
install_dk_duokan_and_lib

# 4. install_lib_lnk
install_lib_lnk

get_times
eips $ROW $NEWLINE "part 1. install_duokan, $TIMES seconds"
NEWLINE=$(($NEWLINE + 2))

# part 2
eips $ROW $NEWLINE "part 2. install_duokan_res, wait..."
# install_dk_duokan_res (moved 20140317, for kpw 5.4.x)

# 6. install python_etc dirs
install_python_etc

# 7. install ducuments dirs
install_documents

# 7.1 install webbrowser
install_web_browser

# 8. clean the script
clean_script
clean_install_sh

# 8.1
remove_old_screensaver

get_times
eips $ROW $NEWLINE "part 2. install_duokan_res, $TIMES seconds"
NEWLINE=$(($NEWLINE + 2))

# part 3
# 9. sync
eips $ROW $NEWLINE "sync, wait..."
sync
get_times
eips $ROW $NEWLINE "sync, $TIMES seconds"
NEWLINE=$(($NEWLINE + 2))

# install ok, total_times
get_total_times
eips $ROW $NEWLINE "OK, total $TOTAL_TIMES seconds"
NEWLINE=$(($NEWLINE + 2))

# check reboot or not
enable_usb_storage
reboot_in_seconds 5

#EOF
