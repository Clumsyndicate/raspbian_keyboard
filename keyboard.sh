#!/bin/bash

KEYMAP="us"
LOCALE="en_US.UTF-8"
TIMEZONE="America/Los_Angeles"
#
# Change keyboard
#
echo ""
echo ""
echo "Setting keyboard..."
sed -i /etc/default/keyboard -e "s/^XKBLAYOUT.*/XKBLAYOUT=\"$KEYMAP\"/"
dpkg-reconfigure -f noninteractive keyboard-configuration
invoke-rc.d keyboard-setup start
setsid sh -c 'exec setupcon -k --force <> /dev/tty1 >&0 2>&1'
udevadm trigger --subsystem-match=input --action=change

#
# Change locale
#
echo "Setting locale..."
LOCALE_LINE="$(grep "^$LOCALE " /usr/share/i18n/SUPPORTED)"
ENCODING="$(echo $LOCALE_LINE | cut -f2 -d " ")"
echo "$LOCALE $ENCODING" > /etc/locale.gen
sed -i "s/^\s*LANG=\S*/LANG=$LOCALE/" /etc/default/locale
dpkg-reconfigure -f noninteractive locales
declare -x LANG="$LOCALE"

#
# Change timezone
#
echo "Setting timezone..."
rm /etc/localtime
echo "$TIMEZONE" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata
