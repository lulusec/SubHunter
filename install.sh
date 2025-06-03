#!/bin/bash

echo "[*] Aktualizujem balíčky..."
sudo apt update -y

install_tool() {
    local tool="$1"
    if command -v "$tool" >/dev/null 2>&1; then
        echo "[✓] $tool je už nainštalovaný."
    else
        echo "[*] Inštalujem $tool..."
        sudo apt install -y "$tool"
        if command -v "$tool" >/dev/null 2>&1; then
            echo "[+] $tool bol úspešne nainštalovaný."
        else
            echo "[!] Nepodarilo sa nainštalovať $tool."
        fi
    fi
}

install_tool assetfinder
install_tool subfinder
install_tool amass
install_tool jq
install_tool sublist3r

echo "[✓] Hotovo."
