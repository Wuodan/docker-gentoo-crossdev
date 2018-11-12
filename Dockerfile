# name the portage image
FROM gentoo/portage as portage

FROM gentoo/stage3-amd64-hardened

# copy the entire portage volume
COPY --from=portage /usr/portage /usr/portage

# configure portage and crossdev overlay
COPY host-files/ /

# chown crossdev overlay
RUN chown -R portage:portage /usr/local/portage-crossdev && \
# update portage
	emerge --sync --quiet && \
# install crossdev, qemu and distcc
# install vim cause nano sucks hard
	emerge --quiet	app-emulation/qemu \
					app-editors/vim \
					dev-vcs/git \
					sys-devel/crossdev \
					sys-devel/distcc
