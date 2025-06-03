#!/bin/bash

# SubHunter - Subdomain enumeration tool wrapper
# Author: Your Name
# Date: 2025

print_banner() {
cat << "EOF"
 ____  _   _ ____  _   _ _   _ _   _ _____ _____ ____  
/ ___|| | | | __ )| | | | | | | \ | |_   _| ____|  _ \ 
\___ \| | | |  _ \| |_| | | | |  \| | | | |  _| | |_) |
 ___) | |_| | |_) |  _  | |_| | |\  | | | | |___|  _ < 
|____/ \___/|____/|_| |_|\___/|_| \_| |_| |_____|_| \_\
            Subdomain Enumeration Framework
EOF
echo ""
}

print_help() {
    echo "Usage: $0 -d <domain>"
    echo ""
    echo "Options:"
    echo "  -d <domain>   Target domain to enumerate subdomains"
    echo "  -h            Show this help message"
}

if [[ $# -eq 0 ]]; then
    print_help
    exit 1
fi

while getopts ":d:h" opt; do
    case ${opt} in
        d )
            DOMAIN=$OPTARG
            ;;
        h )
            print_help
            exit 0
            ;;
        \? )
            echo "Invalid option: -$OPTARG" >&2
            print_help
            exit 1
            ;;
        : )
            echo "Option -$OPTARG requires an argument." >&2
            print_help
            exit 1
            ;;
    esac
done

if [[ -z "$DOMAIN" ]]; then
    echo "Error: No domain provided."
    print_help
    exit 1
fi

print_banner

echo "[*] Starting subdomain enumeration for: $DOMAIN"
mkdir -p results
OUTFILE="results/subdomains_$DOMAIN.txt"
TMPFILE=$(mktemp)

echo "[+] Running assetfinder..."
assetfinder -subs-only "$DOMAIN" >> "$TMPFILE"

echo "[+] Running subfinder..."
subfinder -d "$DOMAIN" >> "$TMPFILE"

echo "[+] Running sublist3r..."
sublist3r -d "$DOMAIN" -o temp_sublist3r.txt >/dev/null 2>&1
cat temp_sublist3r.txt >> "$TMPFILE"
rm -f temp_sublist3r.txt

echo "[+] Fetching from crt.sh..."
curl -s "https://crt.sh/?q=$DOMAIN&output=json" | jq . | grep name | cut -d":" -f2 | grep -v "CN=" | cut -d'"' -f2 | awk '{gsub(/\\n/,"\n");}1;' >> "$TMPFILE"

echo "[*] Sorting and removing duplicates..."
sort -u "$TMPFILE" > "$OUTFILE"
rm -f "$TMPFILE"

echo "[+] Subdomain enumeration completed. Results saved in $OUTFILE"
