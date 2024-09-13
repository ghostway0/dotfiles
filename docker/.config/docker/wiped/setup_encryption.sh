#!/bin/sh

ENCRYPTED_FILE=/dev/shm/encrypted_disk.img
ENCRYPTED_MOUNT=/home
DISK_SIZE=100M

KEY=$(head -c 32 /dev/urandom | base64)

dd if=/dev/zero of=$ENCRYPTED_FILE bs=1M count=100
losetup /dev/loop0 $ENCRYPTED_FILE

echo $KEY | cryptsetup luksFormat /dev/loop0 -d -

echo $KEY | cryptsetup luksOpen /dev/loop0 encrypted_volume -d -

mkfs.ext4 /dev/mapper/encrypted_volume

mount /dev/mapper/encrypted_volume $ENCRYPTED_MOUNT
echo "/home ($DISK_SIZE) is encrypted, and now your home. good luck!"

export HOME=/home
cd /home

exec /bin/sh

umount $ENCRYPTED_MOUNT
cryptsetup luksClose encrypted_volume
losetup -d /dev/loop0
rm $ENCRYPTED_FILE
echo "encrypted volume cleaned up and deleted."

