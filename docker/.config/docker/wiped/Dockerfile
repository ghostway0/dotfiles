FROM alpine:latest

DISK_SIZE=64M
SHM_SIZE=256M

RUN apk add --no-cache cryptsetup util-linux e2fsprogs minisign age

COPY setup_encryption.sh /usr/local/bin/setup_encryption.sh
RUN chmod +x /usr/local/bin/setup_encryption.sh

ENV HOME /home

ENTRYPOINT ["/usr/local/bin/setup_encryption.sh"]
CMD ["/bin/sh"]

