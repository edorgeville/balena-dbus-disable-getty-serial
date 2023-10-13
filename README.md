# balena-dbus-disable-getty-serial
## Disable the getty serial console in balenaOS development

### TL;DR
Copy the `serial-killer` folder to your project, as well as the corresponding `docker-compose.yml` section.  
Don't forget to enable UART in the fleet configuration GUI or by running the command `balena env add BALENA_HOST_CONFIG_enable_uart 1`. Failure to do this will result in `/dev/serial0` to be missing completely.

### Introduction
The development variant of balenaOS comes with the following features:
> - Passwordless SSH access to the host OS
> - Access to the Docker socket
> - **Serial and console logging and interactive login**
> - Local mode functionality

https://www.balena.io/docs/learn/welcome/production-plan/#development-images

This behavior is not always desirable, in some applications a developer might need access to this serial port.  
Running `systemctl | grep getty` on the host reveals different getty related services.  
One of those services, `serial-getty@serial0.service`, binds to `/dev/ttyS0` (a.k.a. `/dev/serial0`).
The service can be disabled running the following on the host:
```bash
mount -o remount,rw /
systemctl mask serial-getty@serial0.service
reboot
```
Unfortunately, running this command at scale (with multiple development boards) isn't practical.  

### Solution
This repository demonstrates how a user can disable the service from a docker container, without the need to run commands on the host.
This is achieved by leveraging the dbus socket that can be exposed inside the container thanks to a custom balena label (see `docker-compose.yml`).  
When `start.sh` is executed, it sends two dbus commands. One is to mask the getty service, the other is to stop it. Masking is done to prevent the service from being started again by another service running on the host, for example.  
After running those two commands, the service is fully stopped, and the user's application can use the serial port without disturbance.

### Documentation
- Disabling the service from the host: https://forums.balena.io/t/disable-console-over-serial-in-dev-on-rpi3/1412/6
- Sending dbus commands from a container: https://www.balena.io/docs/learn/develop/runtime/#rebooting-the-device
- dbus-send man page with example usage: https://linux.die.net/man/1/dbus-send#:~:text=here%20is%20an%20example%20invocation%3A
- systemd dbus API: https://www.freedesktop.org/wiki/Software/systemd/dbus/
