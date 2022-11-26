#!/bin/bash

HEIGHT=15
WIDTH=40
CHOICE_HEIGHT=4
BACKTITLE="Rapids Install Script"
TITLE="Rapids Install Script"
MENU="Choose one of the following options:"

OPTIONS=(1 "Install Linux Depends then compile"
         2 "Already Have depends just compile linux"
         3 "Exit")

CHOICE=$(dialog --clear \
                --backtitle "$BACKTITLE" \
                --title "$TITLE" \
                --menu "$MENU" \
                $HEIGHT $WIDTH $CHOICE_HEIGHT \
                "${OPTIONS[@]}" \
                2>&1 >/dev/tty)

clear
case $CHOICE in
        1)
            cd depends
            sudo ./linux-depends.sh
            ;;
        2)
            cd build
            sudo ./compile-linux.sh
            ;;
        3)
            exit
            ;;
esac