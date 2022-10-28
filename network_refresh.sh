#!/bin/bash
mount -a
service smbd restart
service nmbd restart
service winbind restart
service ntp stop
ntpd -gq
service ntp start
