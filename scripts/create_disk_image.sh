#!/bin/bash

set -e

BLACK="$(tput setaf 0)"
RED="$(tput setaf 1)"
GREEN="$(tput setaf 2)"
YELLOW="$(tput setaf 3)"
BLUE="$(tput setaf 4)"
MAGENTA="$(tput setaf 5)"
CYAN="$(tput setaf 6)"
WHITE="$(tput setaf 7)"
DEFAULT="$(tput setaf 9)"

TARGET=$1
DISK_SIZE=$2

STAGE2_LOCATION=480

DISK_TOTAL_SECTORS=$(( (${DISK_SIZE} + 511) / 512 ))

DISK_PART1_BEGIN=2048
DISK_PART1_END=$(( DISK_TOTAL_SECTOR - 1 ))

echo "${CYAN}Generating Hard Disk Image ${YELLOW}${TARGET} (${DISK_TOTAL_SECTORS} sectors) ($((${DISK_SIZE} / 1024)) KiB)"
dd if=/dev/zero of=$TARGET bs=512 count=${DISK_TOTAL_SECTOR}

echo "${CYAN}Creating Partitions"
parted -s $TARGET mklabel msdos
parted -s $TARGET mkpart primary ${DISK_PART1_BEGIN}s ${DISK_PART1_END}s
parted -s $TARGET set 1 boot on

STAGE2_SIZE=$(stat -c%s ${BUILD_DIR}/stage2.bin)