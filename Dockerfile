# name the portage image
FROM gentoo/portage as portage

FROM gentoo/stage3-amd64-hardened

ARG KERNEL_VERSION=4.17.7
ARG KERNEL_CONFIG_URL="https://raw.githubusercontent.com/pentoo/pentoo-livecd/master/livecd/amd64/kernel/config-${KERNEL_VERSION}"

# copy the entire portage volume
COPY --from=portage /usr/portage /usr/portage

# configure portage
COPY make.conf /etc/portage/make.conf
# configure crossdev overlay
COPY crossdev.conf /etc/portage/repos.conf/

# setup local_repo
RUN mkdir -p /usr/local/portage/{metadata,profiles} && \
	chown -R portage:portage /usr/local/portage && \
	echo 'localrepo' > /usr/local/portage/profiles/repo_name && \
	( \
		echo 'masters = gentoo' && \
		echo 'auto-sync = false' \
	) > /usr/local/portage/metadata/layout.conf && \
	( \
		echo '[localrepo]' && \
		echo 'location = /usr/local/portage' \
	) > /etc/portage/repos.conf/localrepo.conf && \
# create crossdev overlay
	mkdir -p /usr/local/portage-crossdev/{profiles,metadata} && \
	echo 'crossdev' > /usr/local/portage-crossdev/profiles/repo_name && \
	echo 'masters = gentoo' > /usr/local/portage-crossdev/metadata/layout.conf && \
	chown -R portage:portage /usr/local/portage-crossdev && \
# update portage
	emerge --sync --quiet && \
# install kernel sources for qemu
	mkdir -p /etc/portage/package.accept_keywords && \
	echo "=sys-kernel/gentoo-sources-${KERNEL_VERSION} ~amd64" >> \
		/etc/portage/package.accept_keywords/sys-kernel && \
	emerge -q "=sys-kernel/gentoo-sources-${KERNEL_VERSION}" && \
	ln -s /usr/src/linux-"${KERNEL_VERSION}"-gentoo /usr/src/linux && \
# install kernel config for qemu
	echo "${KERNEL_CONFIG_URL}" && \
	curl -o /usr/src/linux/.config "${KERNEL_CONFIG_URL}" && \
	cat /usr/src/linux/.config && \
# install crossdev and qemu
	emerge -q sys-devel/crossdev app-emulation/qemu
