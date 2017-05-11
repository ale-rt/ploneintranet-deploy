FROM quaive/ploneintranet-base:gaia.4
MAINTAINER guido.stevens@cosent.net
RUN echo gaia > /etc/debian_chroot
RUN useradd -m -d /app app && echo "app:app" | chpasswd && adduser app sudo
CMD ["/bin/bash"]
