# x735-Systemd-service
This is the safe shutdown script for x735;

NOTE:

Tested this shell script Raspberry Pi Os 64 bit '2020-08-20-raspios-buster-arm64.img' version;

How to use?

* step 1:
> wget https://raw.githubusercontent.com/linus307/x735-Systemd-service/master/x735.sh

> sudo chmod +x x735.sh

> sudo bash x735.sh

* step 2:

> printf "%s\n" "alias x730off='sudo x730shutdown.sh'" >> ~/.bashrc

* step 3:

> sudo reboot

* how to safe shut down, run the following comamdn:
> x735off
