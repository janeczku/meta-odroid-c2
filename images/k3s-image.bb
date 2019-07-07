SUMMARY = "A k3s image"
HOMEPAGE = "http://www.jumpnowtek.com"

IMAGE_LINGUAS = "en-us"

inherit image

# TODO: Replace coreutils with busybox
CORE_OS = " \
    openssh openssh-keygen openssh-sftp-server \
    packagegroup-core-boot \
    tzdata-core \
    coreutils \
    util-linux \
"

KERNEL_EXTRA_INSTALL = " \
    kernel-modules \
    u-boot-scr \
"

K3S = " \
    k3s \
    k3s-init \
"

K3S_STORAGE = " \
    iscsi-initiator-utils \
    lvm2 \
"

ZEROCONF = " \
    avahi-daemon \
    avahi-utils \
    libnss-mdns \
"

WIREGUARD = " \
    wireguard-init \
    wireguard-module \
    wireguard-tools \
    firewall \
"

UPGRADER = " \
    root-upgrader \
"

EXTRA_TOOLS_INSTALL = " \
    bzip2 \
    curl \
    e2fsprogs-mke2fs \
    socat \
    ebtables \
    ethtool \
    iptables \
    iproute2 \
    grep \
    ifupdown \
    less \
    ntp \
    parted \
    procps \
    rndaddtoentcnt \
    rng-tools \
"

IMAGE_INSTALL += " \
    ${CORE_OS} \
    ${DEV_SDK_INSTALL} \
    ${EXTRA_TOOLS_INSTALL} \
    ${KERNEL_EXTRA_INSTALL} \
    ${ZEROCONF} \
    ${K3S_STORAGE} \
"

IMAGE_FILE_BLACKLIST += " \
    /etc/init.d/hwclock.sh \
 "

remove_blacklist_files() {
    for i in ${IMAGE_FILE_BLACKLIST}; do
        rm -rf ${IMAGE_ROOTFS}$i
    done
}

set_local_timezone() {
    ln -sf /usr/share/zoneinfo/Europe/Paris ${IMAGE_ROOTFS}/etc/localtime
}

disable_bootlogd() {
    echo BOOTLOGD_ENABLE=no > ${IMAGE_ROOTFS}/etc/default/bootlogd
}

create_opt_dir() {
    mkdir -p ${IMAGE_ROOTFS}/opt
}

ROOTFS_POSTPROCESS_COMMAND += " \
    remove_blacklist_files ; \
    set_local_timezone ; \
    disable_bootlogd ; \
    create_opt_dir ; \
"

export IMAGE_BASENAME = "k3s-image"
