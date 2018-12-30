#!/bin/bash

#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

# Configure user nobody to match unRAID's settings
export DEBIAN_FRONTEND="noninteractive"
usermod -u 99 nobody
usermod -g 100 nobody
usermod -m -d /nobody nobody
usermod -s /bin/bash nobody
usermod -a -G adm,sudo nobody
echo "nobody:PASSWD" | chpasswd

# Disable SSH
rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

#########################################
##    REPOSITORIES AND DEPENDENCIES    ##
#########################################

# Install Dependencies
apt-get update -qq
# Install general
apt-get install -qy --force-yes --no-install-recommends wget \
                            				unzip

# Install window manager and x-server
apt-get install -qy --force-yes --no-install-recommends xorgxrdp \
                                                        xrdp \
                                                        openbox \
                                                        lxterminal \
							tzdata

#Create pulse audio modules - ugly but this is 18.04
#installer for pulse audio module
apt-get install -qy --force-yes xrdp-pulseaudio-installer
patch /usr/sbin/xrdp-build-pulse-modules /tmp/xrdp-build-pulse-modules.diff.patch
/usr/sbin/xrdp-build-pulse-modules
mkdir -p /tmp/modules
cp /var/lib/xrdp-pulseaudio-installer/* /tmp/modules
apt -qy autoremove xrdp-pulseaudio-installer

#install Pulseaudio
apt-get install -qy pulseaudio

#########################################
##             INSTALLATION            ##
#########################################

# User directory
mkdir /nobody
mkdir -p /nobody/.config/openbox
mkdir /nobody/.cache
mkdir /var/run/xrdp/
mkdir /var/run/xrdp/sockdir
chmod 777 /var/run/xrdp/sockdir

#Test wavfile for pulse audio for use with paplay
cp /tmp/piano2.wav /nobody/

# openbox config
cp /tmp/openbox/rc.xml /nobody/.config/openbox/rc.xml

#Create session auto disconnect
sed -i.bak -e "s/KillDisconnected\=false/KillDisconnected\=true/gi" /etc/xrdp/sesman.ini
sed -i -e "s/DisconnectedTimeLimit\=0/DisconnectedTimeLimit\=60/" /etc/xrdp/sesman.ini

#copy xrdp sound modules
mkdir -p /var/lib/xrdp-pulseaudio-installer
cp /tmp/modules/* /var/lib/xrdp-pulseaudio-installer

#reset everything that is in nobody ownership
chown -R nobody:users /nobody

#########################################
##  FILES, SERVICES AND CONFIGURATION  ##
#########################################

# config
cat <<'EOT' > /etc/my_init.d/00_config.sh
#!/bin/bash
export DEBIAN_FRONTEND="noninteractive"
if [[ $(cat /etc/timezone) != $TZ ]] ; then
  echo "$TZ" > /etc/timezone
  dpkg-reconfigure -f noninteractive tzdata
fi
EOT

# user config
cat <<'EOT' > /etc/my_init.d/01_user_config.sh
#!/bin/bash

USERID=${USER_ID:-99}
GROUPID=${GROUP_ID:-100}
groupmod -g $GROUPID users
usermod -u $USERID nobody
usermod -g $GROUPID nobody
usermod -d /nobody nobody
usermod -a -G adm,sudo,fuse nobody
chown -R nobody:users /nobody/ 
EOT

# app config
cat <<'EOT' > /etc/my_init.d/02_app_config.sh
#!/bin/bash

APPNAME=${APP_NAME:-"GUI_APPLICATION"}

sed -i -e "s#GUI_APPLICATION#$APPNAME#" /etc/xrdp/xrdp.ini

if [[ -e /startapp.sh ]]; then 
    chown nobody:users /startapp.sh
    chmod +x /startapp.sh
fi
EOT

# xrdp
mkdir -p /etc/service/xrdp
cat <<'EOT' > /etc/service/xrdp/run
#!/bin/bash
exec 2>&1
RSAKEYS=/etc/xrdp/rsakeys.ini

    # Check for rsa key
    [ -f /usr/share/doc/xrdp/rsakeys.ini ] && rm /usr/share/doc/xrdp/rsakeys.ini
    ln -s $RSAKEYS /usr/share/doc/xrdp/rsakeys.ini
    if [ ! -f $RSAKEYS ]; then
        echo "Generating xrdp RSA keys..."
        (umask 077 ; xrdp-keygen xrdp $RSAKEYS)
        chown root:root $RSAKEYS
        if [ ! -f $RSAKEYS ] ; then
	        echo "could not create $RSAKEYS"
            exit 1
        fi
    fi
    [ -f /var/run/xrdp/xrdp.pid ] && rm /var/run/xrdp/xrdp.pid
    echo "Starting xrdp!"

exec /usr/sbin/xrdp --nodaemon
EOT

# xrdp-sesman
mkdir -p /etc/service/xrdp-sesman
cat <<'EOT' > /etc/service/xrdp-sesman/run
#!/bin/bash
exec 2>&1
    echo "Starting xrdp-sesman!"

exec /usr/sbin/xrdp-sesman --nodaemon
EOT

# Open-box User nobody autostart
cat <<'EOT' > /nobody/.config/openbox/autostart
# Programs that will run after Openbox has started

xsetroot -solid black -cursor_name left_ptr
if [ -e /startapp.sh ]; then 
    echo "Starting X app..."
    exec /startapp.sh
fi
EOT

cat <<'EOT' > /nobody/.xsessionrc
exec /usr/bin/openbox-session
EOT


chmod +x /nobody/.config/openbox/autostart
chown -R nobody:users /nobody/ 
chmod -R +x /etc/service/ /etc/my_init.d/ 

#########################################
##                 CLEANUP             ##
#########################################

# Clean APT install files
apt-get autoremove -y 
apt-get clean -y
rm -rf /var/lib/apt/lists/* /var/cache/* /var/tmp/* /tmp/openbox /tmp/modules
