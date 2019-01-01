# Builds a docker firefox
FROM okovwvrv/xrdp-base

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

# Set environment variables
ENV LC_ALL=C.UTF-8 LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 TERM=xterm
ENV TZ=Etc/UTC

# User/Group Id gui app will be executed as default are 99 and 100
ENV USER_ID=99
ENV GROUP_ID=100

# Gui App Name default is "GUI_APPLICATION"
ENV APP_NAME=xrdp-firefox

# Default resolution, change if you like
ENV WIDTH=1280
ENV HEIGHT=720

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################
RUN \
apt-get update && \
apt-get install -y \
firefox && \
apt-get -f install -y  

#########################################
##          GUI APP INSTALL            ##
#########################################

# Copy X app start script to right location
COPY startapp.sh /startapp.sh

#########################################
##         EXPORTS AND VOLUMES         ##
#########################################

# Place whater volumes and ports you want exposed here:
# Fix xrdp bug
RUN \
sed -i '3isysctl net.ipv6.conf.all.disable_ipv6=0\n' /etc/service/xrdp/run &&\
sed -i '4isysctl net.ipv6.conf.eth0.disable_ipv6=1\n' /etc/service/xrdp/run

