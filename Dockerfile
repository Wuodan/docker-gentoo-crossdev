# name the portage image
FROM gentoo/portage as portage

FROM gentoo/stage3-amd64-hardened

# copy the entire portage volume
COPY --from=portage /usr/portage /usr/portage

# configure portage
ADD make.conf /etc/portage/make.conf
# configure crossdev overlay
ADD crossdev.conf /etc/portage/repos.conf/

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
# install crossdev and qemu
	emerge -q sys-devel/crossdev app-emulation/qemu
