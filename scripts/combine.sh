#!/usr/bin/env bash
# combine.sh - Recombines split ISO parts into the original bootable ISO and verifies SHA256.
# Compatible with macOS (Bash 3.2+) and Linux (Bash/Zsh).

set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DIR"

# Color helpers
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}===============================================${NC}"
echo -e "${BLUE}       AetherOS ISO Recombination Tool        ${NC}"
echo -e "${BLUE}===============================================${NC}"

# Check SHA256 tool availability
SHA_CMD=""
if command -v sha256sum &>/dev/null; then
    SHA_CMD="sha256sum"
elif command -v shasum &>/dev/null; then
    SHA_CMD="shasum -a 256"
fi

# Find all distinct target ISOs from available .part* files
TARGETS=()
for f in *.iso.part*; do
    [ -f "$f" ] || continue
    t="${f%.part*}"
    # Check if not already in TARGETS
    already_in=false
    for existing in "${TARGETS[@]}"; do
        if [ "$existing" = "$t" ]; then
            already_in=true
            break
        fi
    done
    if [ "$already_in" = false ]; then
        TARGETS+=("$t")
    fi
done

if [ ${#TARGETS[@]} -eq 0 ]; then
    echo -e "${RED}[-] Error: No .iso.part* files found in current directory!${NC}"
    echo "Please ensure the downloaded .iso.part* files are in the same folder as this script."
    exit 1
fi

echo -e "${YELLOW}[*] Detected ${#TARGETS[@]} target ISO(s) to process:${NC}"
for t in "${TARGETS[@]}"; do
    echo -e "    ${CYAN}• ${t}${NC}"
done

# Process each target ISO independently
for TARGET_ISO in "${TARGETS[@]}"; do
    echo -e "\n${BLUE}-----------------------------------------------${NC}"
    echo -e "${BLUE}Processing: ${TARGET_ISO}${NC}"
    echo -e "${BLUE}-----------------------------------------------${NC}"

    # Collect and sort parts strictly for this specific target ISO
    PARTS=()
    for p in "${TARGET_ISO}".part*; do
        [ -f "$p" ] || continue
        PARTS+=("$p")
    done

    if [ ${#PARTS[@]} -eq 0 ]; then
        echo -e "${RED}[-] No parts found for ${TARGET_ISO}, skipping.${NC}"
        continue
    fi

    echo -e "${YELLOW}[*] Found ${#PARTS[@]} split parts for ${TARGET_ISO}:${NC}"
    for p in "${PARTS[@]}"; do
        size=$(ls -lh "$p" | awk '{print $5}')
        echo "    -> $p ($size)"
    done

    # Verify parts first if sha256sum.txt is available
    if [ -f "sha256sum.txt" ] && [ -n "$SHA_CMD" ]; then
        echo -e "\n${YELLOW}[*] Verifying parts against sha256sum.txt...${NC}"
        all_parts_ok=true
        for p in "${PARTS[@]}"; do
            expected_hash=$(awk -v target="$p" '{
                fn = $2;
                sub(/^\*/, "", fn);
                if (fn == target) print $1;
            }' sha256sum.txt)
            if [ -n "$expected_hash" ]; then
                actual_hash=$($SHA_CMD "$p" | awk '{print $1}')
                if [ "$expected_hash" = "$actual_hash" ]; then
                    echo -e "    ${GREEN}[✓]${NC} $p: SHA256 matches"
                else
                    echo -e "    ${RED}[✗] ERROR: $p SHA256 MISMATCH!${NC}"
                    echo "        Expected: $expected_hash"
                    echo "        Actual:   $actual_hash"
                    all_parts_ok=false
                fi
            else
                echo -e "    ${YELLOW}[?]${NC} $p: No entry in sha256sum.txt (skipping hash check)"
            fi
        done

        if [ "$all_parts_ok" = false ]; then
            echo -e "\n${RED}[-] Aborting ${TARGET_ISO}: One or more parts are corrupted or incomplete.${NC}"
            echo "Please re-download the corrupted part(s) and try again."
            continue
        fi
    fi

    # Concatenate parts into target ISO
    echo -e "\n${YELLOW}[*] Merging parts into ${TARGET_ISO}...${NC}"
    cat "${PARTS[@]}" > "$TARGET_ISO"

    # Verify reassembled ISO
    if [ -f "sha256sum.txt" ] && [ -n "$SHA_CMD" ]; then
        echo -e "${YELLOW}[*] Verifying reassembled ISO integrity...${NC}"
        expected_iso_hash=$(awk -v target="$TARGET_ISO" '{
            fn = $2;
            sub(/^\*/, "", fn);
            if (fn == target) print $1;
        }' sha256sum.txt)
        if [ -n "$expected_iso_hash" ]; then
            actual_iso_hash=$($SHA_CMD "$TARGET_ISO" | awk '{print $1}')
            if [ "$expected_iso_hash" = "$actual_iso_hash" ]; then
                echo -e "${GREEN}[✓] Full ISO SHA256 matches! Reassembly was 100% successful.${NC}"
            else
                echo -e "${RED}[✗] ERROR: Reassembled ISO SHA256 does not match sha256sum.txt!${NC}"
                echo "    Expected: $expected_iso_hash"
                echo "    Actual:   $actual_iso_hash"
                exit 1
            fi
        fi
    fi

    FINAL_SIZE=$(ls -lh "$TARGET_ISO" | awk '{print $5}')
    echo -e "\n${GREEN}======================================================${NC}"
    echo -e "${GREEN} Successfully created: ${TARGET_ISO} (${FINAL_SIZE})${NC}"
    echo -e "${GREEN} Location: ${DIR}/${TARGET_ISO}${NC}"
    echo -e "${GREEN} Ready for flashing with balenaEtcher or booting in VM!${NC}"
    echo -e "${GREEN}======================================================${NC}"
done
