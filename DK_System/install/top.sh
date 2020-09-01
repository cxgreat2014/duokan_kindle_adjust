# DuoKan 2013 for Kindle Paperwhite 5.4.2
# support email: kindleuser [at] duokan.com
# update 2013-11-26

NEWLINE=31

DUOKAN_USB_PATH=/mnt/us/DK_System

mntus_exec()
{
	if [ ! -f /MNTUS_EXEC ] ; then
		touch /MNTUS_EXEC
    fi
}

clean_repair()
{
	echo "clean_repair"		
	rm -f /var/local/upstart/*.restarts
	rm -f /var/local/system/.framework_reboots
	rm -f /var/local/system/.framework_retries
}

clean_debug()
{
	rm -f /mnt/us/MOBI8_DEBUG
	rm -f /mnt/us/documents/duokan.mobi*
	rm -rf /mnt/us/documents/duokan.sdr
    rm -f /mnt/us/update_*.bin
}

install_duokanconf()
{	
	if [ -f $DUOKAN_USB_PATH/install/duokan.conf ] ; then
		cp $DUOKAN_USB_PATH/install/duokan.conf /etc/upstart/
		chmod +x /etc/upstart/duokan.conf
	else	
		eips 10 $NEWLINE "not found DK_System/install/duokan.conf"
		exit 0
	fi
}

install_dk_scripts()
{
	if [ -f $DUOKAN_USB_PATH/install/DK_update ]; then
		cp -f $DUOKAN_USB_PATH/install/DK_update 	/etc/init.d/DK_update
		chmod +x /etc/init.d/DK_update
	else	
		eips 10 $NEWLINE "not found DK_System/install/DK_update"
		exit 0
	fi
}

display_beign()
{
	date=`date`
	eips 10 $NEWLINE "$date"	
	NEWLINE=$(($NEWLINE + 2))
}

display_end()
{
	date=`date`
	eips 10 $NEWLINE "OK, DuoKan is rebooting ..."
	eips
}

### begin to run
display_beign

clean_repair

mntroot rw
mntus_exec
install_duokanconf
install_dk_scripts

display_end
clean_debug
sync

mntroot ro
reboot -f
