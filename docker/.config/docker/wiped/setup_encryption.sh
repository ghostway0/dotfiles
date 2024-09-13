#!/bin/sh

ENCRYPTED_FILE=/dev/shm/encrypted_disk.img
ENCRYPTED_MOUNT=/home
DISK_SIZE=256M

if losetup | grep '/dev/loop0' > /dev/null 2>&1; then
    echo "Cleaning up previous loop device /dev/loop0..."
    if cryptsetup status encrypted_volume > /dev/null 2>&1; then
        echo "Closing previous encrypted volume..."
        cryptsetup luksClose encrypted_volume || echo "Failed to close encrypted_volume."
    fi
    losetup -d /dev/loop0 || echo "Failed to detach loop device."
fi

if losetup | grep '/dev/loop0' > /dev/null 2>&1; then
    echo "/dev/loop0 is still busy. Exiting."
    exit 1
fi

KEY=$(head -c 32 /dev/urandom | base64)

dd if=/dev/zero of=$ENCRYPTED_FILE bs=1M count=100
losetup /dev/loop0 $ENCRYPTED_FILE

echo $KEY | cryptsetup luksFormat /dev/loop0 -d -

echo $KEY | cryptsetup luksOpen /dev/loop0 encrypted_volume -d -

mkfs.ext4 /dev/mapper/encrypted_volume

mount /dev/mapper/encrypted_volume $ENCRYPTED_MOUNT
echo "/home ($DISK_SIZE) is encrypted, and now your home. good luck!"

export HOME=$ENCRYPTED_MOUNT
cd $ENCRYPTED_MOUNT

/bin/sh

cd /

echo "cleaning up..."
umount $ENCRYPTED_MOUNT || (echo "failed to unmount $ENCRYPTED_MOUNT." && exit 1)
cryptsetup luksClose encrypted_volume || (echo "failed to close encrypted volume." && exit 1)
losetup -d /dev/loop0 || (echo "failed to detach loop device." && exit 1)
rm -f $ENCRYPTED_FILE || (echo "failed to remove encrypted file." && exit 1)

echo "success! your secrets are safe for one more day..."
