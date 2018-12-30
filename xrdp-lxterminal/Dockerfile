# docker base
FROM unilynx/phusion-baseimage-1804
MAINTAINER Carlos Hernandez <carlos@techbyte.ca>

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################
# Set correct environment variables
ENV LC_ALL=C.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 TERM=xterm APP_NAME=xrdp-lxterminal


# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

#########################################
##         RUN INSTALL SCRIPT          ##
#########################################
COPY startapp.sh /startapp.sh
COPY ./files/ /tmp/
RUN chmod +x /tmp/install/install.sh && /tmp/install/install.sh && rm -r /tmp/install
