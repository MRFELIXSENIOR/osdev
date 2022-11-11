@echo off
if exist build\os_image.vhd del build\os_image.vhd
diskpart /s scripts/WINDOWS/disk_attach.txt

echo "Copying Files..."
copy test\file.txt Z:\
copy build\boot.bin Z:\
copy build\bootloader.bin Z:\

diskpart /s scripts/WINDOWS/disk_detach.txt