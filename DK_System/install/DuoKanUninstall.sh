#!/bin/sh

# update 20131218

uninstall_all()
{
		#clean old DuoKan script
		rm -f /etc/rcS.d/S79switch
		rm -f /etc/rc5.d/s96rundk
		rm -f /etc/rc5.d/S96rundk
		rm -f /etc/rc5.d/rundk.sh
		rm -f /etc/rc5.d/S95dkupdate
		
		#clean new DuoKan script
		rm -f /etc/init.d/DK_switch
		rm -f /etc/init.d/DK_run
		rm -f /etc/rc5.d/S95DK_switch
		rm -f /etc/rc5.d/S96DK_run
		
		rm -rf /mnt/us/DK_System/
		rm -rf /test/DKLite

		#uninstall Duokan 2013
		rm -rf /DuoKan
		rm -rf /mnt/us/DK_Mbp/
		rm -rf /mnt/us/DK_User/
		rm	-f /mnt/base/?pdate*.bin
        rm -rf /var/local/evernote
        rm -rf /var/local/xiaomi
        rm -rf /mnt/us/system/*.ini
        rm -rf /mnt/us/system/*.info
        rm -rf /mnt/us/system/userfile
        rm -rf /mnt/us/system/reading.dk
}

clean_repair()
{
	echo "clean_repair"		
	rm -f /var/local/upstart/*.restarts
	rm -f /var/local/system/.framework_reboots
	rm -f /var/local/system/.framework_retries
}

######## beign to run #######
clean_repair

stop x&
eips -c
eips 10 20 "Duokan is uninstalling ......"

echo "uninstall all"

mntroot rw

uninstall_all
sync

mntroot ro

eips -c
eips 10 20 "Duokan has been uninstalled."
eips 10 22 "Rebooting ....."
reboot -f
