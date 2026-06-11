#!/bin/bash

# VMware 共享資料夾管理腳本 (使用 vmhgfs-fuse)
# 掛載點: /tmp/shared

SHARE_PATH="/tmp/shared"
VMHGFS_FUSE="/usr/bin/vmhgfs-fuse"

# 顏色輸出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 函數：顯示標題
show_header() {
    clear
    echo -e "${BLUE}"
    echo "VMware 共享資料夾管理工具"
    echo "掛載點: $SHARE_PATH"
    echo -e "${NC}"
    echo
}

# 函數：檢查 vmhgfs-fuse 是否存在
check_vmhgfs_fuse() {
    if [ ! -x "$VMHGFS_FUSE" ]; then
        echo -e "${RED}錯誤：找不到 vmhgfs-fuse！${NC}"
        echo "請確保已安裝 open-vm-tools-desktop 並重啟系統"
        echo "安裝指令："
        echo "  Ubuntu/Debian: sudo apt install open-vm-tools-desktop"
        echo "  CentOS/RHEL: sudo yum install open-vm-tools-desktop"
        exit 1
    fi
}

# 函數：掛載共享資料夾
mount_share() {
    echo -e "${YELLOW}正在掛載 VMware 共享資料夾...${NC}"
    
    # 檢查 fuse 是否載入
    if ! lsmod | grep -q fuse; then
        echo -e "${YELLOW}載入 FUSE 模組...${NC}"
        sudo modprobe fuse
    fi
    
    # 建立掛載點
    if [ ! -d "$SHARE_PATH" ]; then
        sudo mkdir -p "$SHARE_PATH"
        if [ $? -ne 0 ]; then
            echo -e "${RED}錯誤：無法建立掛載點 $SHARE_PATH${NC}"
            exit 1
        fi
    fi
    
    # 設定掛載點權限
    sudo chown $(whoami):$(whoami) "$SHARE_PATH"
    sudo chmod 755 "$SHARE_PATH"
    
    # 檢查是否已掛載
    if mountpoint -q "$SHARE_PATH"; then
        echo -e "${YELLOW}共享資料夾已掛載，跳過...${NC}"
        return 0
    fi
    
    # 【徹底修正】直接在 sudo 指令中執行 id -u，避免變數賦值
    USER_UID=$(id -u)
    echo "使用者 UID: $USER_UID"
    echo "執行指令：sudo $VMHGFS_FUSE .host:/ $SHARE_PATH -o allow_other -o uid=$USER_UID -o subtype=vmhgfs-fuse"
    
    sudo bash -c "$VMHGFS_FUSE .host:/ '$SHARE_PATH' -o allow_other -o uid=$USER_UID -o subtype=vmhgfs-fuse"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ 共享資料夾已成功掛載到 $SHARE_PATH${NC}"
        echo -e "${GREEN}可用共享資料夾：${NC}"
        ls -la "$SHARE_PATH" | head -10
    else
        echo -e "${RED}✗ 掛載失敗！${NC}"
        echo "請檢查："
        echo "1. VMware Tools 是否已安裝 (open-vm-tools-desktop)"
        echo "2. VMware 中是否已設定共享資料夾"
        echo "3. FUSE 模組是否載入 (lsmod | grep fuse)"
        echo "4. 執行以下指令檢查：vmhgfs-fuse --version"
    fi
}

# 函數：卸載共享資料夾
umount_share() {
    echo -e "${YELLOW}正在卸載共享資料夾...${NC}"
    
    if mountpoint -q "$SHARE_PATH"; then
        sudo fusermount -u "$SHARE_PATH" 2>/dev/null || sudo umount "$SHARE_PATH" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ 共享資料夾已成功卸載${NC}"
        else
            echo -e "${RED}✗ 卸載失敗${NC}"
            echo "嘗試強制卸載..."
            sudo umount -f "$SHARE_PATH" 2>/dev/null
        fi
    else
        echo -e "${YELLOW}共享資料夾未掛載，無需卸載${NC}"
    fi
    
    # 清理掛載點（如果空的）
    if [ -d "$SHARE_PATH" ] && [ -z "$(ls -A "$SHARE_PATH" 2>/dev/null)" ]; then
        sudo rmdir "$SHARE_PATH" 2>/dev/null
        echo -e "${GREEN}✓ 掛載點已清理${NC}"
    fi
}

# 函數：檢查掛載狀態
check_status() {
    echo -e "${BLUE}=== 掛載狀態檢查 ===${NC}"
    if mountpoint -q "$SHARE_PATH"; then
        echo -e "${GREEN}✓ 已掛載${NC}"
        df -h "$SHARE_PATH" | tail -1
        echo
        echo -e "${GREEN}內容：${NC}"
        ls -la "$SHARE_PATH" | head -5
    else
        echo -e "${RED}✗ 未掛載${NC}"
        echo "請執行選項 1 進行掛載"
    fi
}

# 函數：顯示選單
show_menu() {
    echo -e "${BLUE}請選擇操作：${NC}"
    echo "1) 掛載 共享資料夾 → $SHARE_PATH"
    echo "2) 卸載 共享資料夾"
    echo "3) 檢查 掛載狀態"
    echo "4) 退出"
    echo
    read -p "請輸入選項 (1-4): " choice
}

# 主程式
main() {
    check_vmhgfs_fuse
    show_header
    
    while true; do
        show_menu
        
        case $choice in
            1)
                show_header
                mount_share
                read -p $'\n按 Enter 鍵繼續...'
                ;;
            2)
                show_header
                umount_share
                read -p $'\n按 Enter 鍵繼續...'
                ;;
            3)
                show_header
                check_status
                read -p $'\n按 Enter 鍵繼續...'
                ;;
            4)
                echo -e "${GREEN}感謝使用！${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}無效選項，請重新選擇！${NC}"
                sleep 1
                ;;
        esac
        
        show_header
    done
}

# 執行主程式
main
