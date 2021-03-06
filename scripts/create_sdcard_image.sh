#!/bin/bash

MACHINE=odroid-c2
HOSTNAME=odroid-c2
DSTDIR=~/odroid-c2/upload
IMG=console
IMG_LONG="${IMG}-image-${MACHINE}"

if [ ! -d /media/card ]; then
    echo "Temporary mount point [/media/card] not found"
    exit 1
fi

if [ "x${1}" = "x" ]; then
    CARDSIZE=2
else
    if [ "${1}" -eq 1 ]; then
        CARDSIZE=1
    elif [ "${1}" -eq 2 ]; then
        CARDSIZE=2
    elif [ "${1}" -eq 4 ]; then
        CARDSIZE=4
    else
        echo "Unsupported card size: ${1}"
        exit 1
    fi
fi

if [ -z "${OETMP}" ]; then
    echo "OETMP environment variable not set"
    exit 1
fi

SRCDIR=${OETMP}/deploy/images/${MACHINE}

if [ ! -f "${SRCDIR}/${IMG_LONG}.tar.xz" ]; then
    echo "File not found: ${SRCDIR}/${IMG_LONG}.tar.xz"
    exit 1
fi

SDIMG=${MACHINE}-${IMG}-${CARDSIZE}gb.img

if [ -f "${DSTDIR}/${SDIMG}" ]; then
    rm ${DSTDIR}/${SDIMG}
fi

if [ -f "${DSTDIR}/${SDIMG}.xz" ]; then
    rm -f ${DSTDIR}/${SDIMG}.xz*
fi

echo -e "\n***** Creating the loop device *****"
LOOPDEV=`losetup -f`

echo -e "\n***** Creating an empty SD image file *****"
dd if=/dev/zero of=${DSTDIR}/${SDIMG} bs=1G count=${CARDSIZE}

echo -e "\n***** Partitioning the SD image file *****"
{
echo 8182,,,*
} | sfdisk ${DSTDIR}/${SDIMG}

echo "***** Attaching to the loop device *****"
sudo losetup -P ${LOOPDEV} ${DSTDIR}/${SDIMG}

echo "***** Copying the boot partition *****"
DEV=${LOOPDEV}
./copy_boot.sh ${DEV}

if [ $? -ne 0 ]; then
    sudo losetup -D
    exit
fi

echo "***** Copying the rootfs *****"
DEV=${LOOPDEV}p1
./copy_rootfs.sh ${DEV} ${IMG} ${HOSTNAME}

if [ $? -ne 0 ]; then
    sudo losetup -D
    exit
fi

echo "***** Detatching loop device *****"
sudo losetup -D

echo "***** Compressing the SD card image *****"
sudo xz -9 ${DSTDIR}/${SDIMG}

echo "***** Creating an md5sum *****"
cd ${DSTDIR}
md5sum ${SDIMG}.xz > ${SDIMG}.xz.md5
cd ${OLDPWD}

echo "***** Done *****"
