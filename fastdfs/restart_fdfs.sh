#!/bin/bash

killall fdfs_trackerd

killall fdfs_storaged

/usr/local/bin/stop.sh  /usr/local/bin/fdfs_storaged /etc/fdfs/storage.conf

ps aux |grep fdfs

/usr/local/bin/fdfs_trackerd /etc/fdfs/tracker.conf

/usr/local/bin/fdfs_storaged  /etc/fdfs/storage.conf

ps aux |grep fdfs

