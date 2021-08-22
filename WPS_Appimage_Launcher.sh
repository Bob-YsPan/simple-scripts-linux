#!/bin/bash
echo "------------------------------"
echo "-WPS Office Appimage Launcher-"
echo "------------------------------"
# Sample appimage: https://apprepo.de/appimage/wps-office
# Or can use custom repacked appimage
# 可以用上面網址下載Appimage或是自己打包的appimage
# Varibles:
# Check appimage offset:
# 用以下的指令可以查到Appimage的Offset
# /path/to/appimage.appimage --appimage-offset
imageoffset=189632
mountpoint=/tmp/wpsoffice
# Replace to you need
# 放上Appimage的路徑
appimage="Appimage Location"
snappkg="Snap Package Location"

# Program Start
echo "Create Mount Dir..."
rm -r $mountpoint
mkdir $mountpoint

# Uncomment you needed and comment out not used.
# 把需要的部份Uncomment，不要的Comment out
# Mount appimage
echo "Mounting Appimage"
sudo mount $appimage $mountpoint -o offset=$imageoffset
# Mount snap package
#echo "Mounting Snap Package"
#sudo mount -t squashfs -o ro $snappkg $mountpoint

# 詢問使用者要執行什麼程式
# 把需要的部份Uncomment，不要的Comment out
# Ask user which program want to run
# Uncomment you needed and comment out not used.
PS3='Which program you want to run?: '
options=("Writer" "Presentation" "Spreadsheet" "PDF" "Quit and Umount")
select opt in "${options[@]}"
do
    case $opt in
        "Writer")
            # 預設主題
            # Default theme, appimage
            $mountpoint/opt/application/wps >/dev/null 2>&1 &
            # Reset theme(this will cause it fallback theme like windows, can fix gtk2 dark theme font color problem(too hard to read))
            # 讓主題重置，讓程式套用有點像Windows風格的主題，可以解決gtk2深色主題文字不易看懂的問題
            # appimage
            #$mountpoint/opt/application/wps --style="" >/dev/null 2>&1 &
            # snap package
            #$mountpoint/opt/kingsoft/wps-office/office6/wps --style="" >/dev/null 2>&1 &
            ;;
        "Presentation")
            $mountpoint/opt/application/wps >/dev/null 2>&1 &
            #$mountpoint/opt/application/wpp --style="" >/dev/null 2>&1 &
            #$mountpoint/opt/kingsoft/wps-office/office6/wpp --style="" >/dev/null 2>&1 &
            ;;
        "Spreadsheet")
            $mountpoint/opt/application/wps >/dev/null 2>&1 &
            #$mountpoint/opt/application/et --style="" >/dev/null 2>&1 &
            #$mountpoint/opt/kingsoft/wps-office/office6/et --style="" >/dev/null 2>&1 &
            ;;
        "PDF")
            $mountpoint/opt/application/wps >/dev/null 2>&1 &
            #$mountpoint/opt/application/wpspdf --style="" >/dev/null 2>&1 &
            #$mountpoint/opt/kingsoft/wps-office/office6/wpspdf --style="" >/dev/null 2>&1 &
            ;;
        "Quit and Umount")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
# Umount and Exit
# New version of WPS will leave "wpscloudsvr" process at background.
# 清理留在後台的wpscloudsvr行程
echo "Kill cloudsvr"
killall wpscloudsvr
echo "Umounting..."
sudo umount $mountpoint
rm -r $mountpoint
echo "Exit..."