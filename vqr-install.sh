#!/bin/bash

LATEST_RELEASE="0.17.2.3"

upgradeDistr() {
    sudo apt update
    sudo apt upgrade -y
	sudo apt autoclean
	sudo apt-autoremove
}

checkPrevInstall() {
    if [ -f vqr-cli  ]; then
        version=$(./vqr-cli --version)
        curr_ver=${version: -8}
        if [ "$curr_ver" != $LATEST_RELEASE ]; then
            echo Update to latest version ...
            ./vqr-cli stop
            sleep 2
            installLatestRelease
        else
            echo You have latest version
            exit
        fi
    else
        echo Install latest version
        sudo apt install wget
        installLatestRelease
    fi
}

installLatestRelease() {
    github_url="https://github.com/vovanchik-net/vqr/releases/download/"$LATEST_RELEASE
    github_tar="vqr-$LATEST_RELEASE-x86_64-linux-gnu.tar.gz"
    wget $github_url"/"$github_tar
    tar -xvf $github_tar
    rm $github_tar
    ./vqrd -daemon
    sleep 2
    ./vqr-cli --version
}

installTelegramSend () {
	printf"#!/bin/bash
	#
	# script for sending TEXT/FILE to Telegram
	#
	# Usage: telegram-send "<text>" or "</path/to/file>"
	# ..."folder non-exist" errors may be ignored
	#
	SEND_ME=$1
	TG_BOT_ID="<TOKEN>"
	TG_CHAT_ID="<ID>"
	#
	# Sending text-message
	curl --socks5-basic \
	-X POST https://api.telegram.org/bot$TG_BOT_ID/sendMessage \
	-d chat_id=$TG_CHAT_ID -d text="$SEND_ME"
	#
	# sending file-message
	cat "$SEND_ME" > /tmp/tg-export && \
	curl --socks5-basic \
	-s -X POST https://api.telegram.org/bot$TG_BOT_ID/sendDocument
	-F chat_id=$TG_CHAT_ID -F document=@/tmp/tg-export
	#
	# cleaning
	rm -f /tmp/tg-export" > /dev/null > /usr/bin/telegram-send

	chmod +x /usr/bin/telegram-send && \
	chown root:root /usr/bin/telegram-send
}

installAutoSendFunds () {
	printf"#!/bin/bash
	#
	STACK="400"
	AMOUNT="20"
	SEND_TO="<ADDRESS>"
	#
	get_balance=$(./vqr-cli getbalance)
	balance=$((${get_balance%.*} - $STACK))
	if [ $balance \> $AMOUNT ]; then
		tx=$(./vqr-cli $SEND_TO $AMOUNT)
		telegram-send "$tx"
		else
			#telegram-send $balance
			exit
	fi" > /dev/null > vqr-send.sh
	#
	# Add script to crontab (Run every 1 hour)
	crontab -l | { cat; echo "* 1 * * * /$HOME/vqr-send.sh >/dev/null 2>&1"; } | crontab -
	#
	# Send test message to Telegram
	telegram-send "Working ..."
}

Main() {
    upgradeDistr
    checkPrevInstall
	installTelegramSend
	installAutoSendFunds
}

Main "$1"
