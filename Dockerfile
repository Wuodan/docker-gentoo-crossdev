# name the portage image
FROM gentoo/portage as portage

FROM gentoo/stage3-amd64-hardened

# copy the entire portage volume
COPY --from=portage /usr/portage /usr/portage

# configure portage
COPY make.conf /etc/portage/make.conf
# configure crossdev overlay
COPY crossdev.conf /etc/portage/repos.conf/

# create crossdev overlay
RUN mkdir -p /usr/local/portage-crossdev/{profiles,metadata} && \
	echo 'crossdev' > /usr/local/portage-crossdev/profiles/repo_name && \
	echo 'masters = gentoo' > /usr/local/portage-crossdev/metadata/layout.conf && \
	chown -R portage:portage /usr/local/portage-crossdev && \
# update portage
	emerge --sync --quiet && \
# install crossdev and qemu
# install vim cause nano sucks hard
	emerge -q app-emulation/qemu app-editors/vim dev-vcs/git sys-devel/crossdev
