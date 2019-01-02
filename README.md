# Containers
A set of GUI containerised applications built upon from a common base architecture. The base operating system is Phusion 18.04 and GUI is represented through the use of xorgxrdp such that a remote desktop application can be utilised to the container. The xrdp-base container is fundamentally just the underlying operating system build and includes audiopulse and its associated modules for audio through the xrdp session rather than using other mechanisms. The xrdp-base runs lxterminal session.

The script files included in each of the containers enabling building and creating a new container for each of the applications. eg. xrdp-base create script creates a container called xrdp-lxterminal as the application. You will need to pass in an environmental variables to the container. Common variables are:

1. Timezone;
2. xsession WIDTH and HEIGHT; and
3. the conatinerise X display name - APP_NAME.

Don;t forget that if your wanting sound that pulseaudio daemon must be running on the host. eg. pulseaudio --start -D shoudl do that if its not already running.
