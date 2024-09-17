FROM alpine:latest

RUN apk add --no-cache cryptsetup util-linux e2fsprogs minisign age git neovim openssh

COPY setup_encryption.sh /usr/local/bin/setup_encryption.sh
RUN chmod +x /usr/local/bin/setup_encryption.sh

ENV HOME=/home

ENTRYPOINT ["/usr/local/bin/setup_encryption.sh"]
CMD ["/bin/sh"]

