docker run -dit -p 3389:3389 --shm-size 2g -e "TZ=Australia/Brisbane" --privileged --name testfirefox xrdp-firefox /sbin/my_init --skip-runit /bin/bash
