# named portage image
FROM gentoo/portage:latest as portage
FROM gentoo/stage3-amd64-hardened:latest

# copy the entire portage volume
COPY --chown=portage:portage --from=portage /usr/portage /usr/portage

# configure portage and crossdev overlay
COPY host-files/ /

# configure portage
RUN echo -e '\n\
# custom\n\
MAKEOPTS="-j8"\n\
EMERGE_DEFAULT_OPTS="${EMERGE_DEFAULT_OPTS} --jobs=8 --load-average=8"\n\
GENTOO_MIRRORS="http://mirror.netcologne.de/gentoo/ http://linux.rz.ruhr-uni-bochum.de/download/gentoo-mirror/ http://ftp-stud.hs-esslingen.de/pub/Mirrors/gentoo/"' >> /etc/portage/make.conf && \
# chown crossdev overlay
	chown -R portage:portage /usr/local/portage-crossdev && \
# install crossdev, qemu and distcc
# install layman for wuodan profiles
# install vim cause nano sucks hard
	emerge --quiet	app-emulation/qemu \
					app-editors/vim \
					app-portage/layman \
					sys-devel/crossdev \
					sys-devel/distcc && \
# cleanup
	rm -rf /usr/portage/distfiles/*
