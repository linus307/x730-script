#x735 Powering on /reboot /shutdown from hardware
#!/bin/bash

echo '#!/bin/bash

SHUTDOWN=4
REBOOTPULSEMINIMUM=200
REBOOTPULSEMAXIMUM=600
echo "$SHUTDOWN" > /sys/class/gpio/export
echo "in" > /sys/class/gpio/gpio$SHUTDOWN/direction
BOOT=17
echo "$BOOT" > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio$BOOT/direction
echo "1" > /sys/class/gpio/gpio$BOOT/value

echo "X735 Shutting down..."

while [ 1 ]; do
  shutdownSignal=$(cat /sys/class/gpio/gpio$SHUTDOWN/value)
  if [ $shutdownSignal = 0 ]; then
    /bin/sleep 0.2
  else  
    pulseStart=$(date +%s%N | cut -b1-13)
    while [ $shutdownSignal = 1 ]; do
      /bin/sleep 0.02
      if [ $(($(date +%s%N | cut -b1-13)-$pulseStart)) -gt $REBOOTPULSEMAXIMUM ]; then
        echo "X730 Shutting down", SHUTDOWN, ", halting Rpi ..."
        sudo poweroff
        exit
      fi
      shutdownSignal=$(cat /sys/class/gpio/gpio$SHUTDOWN/value)
    done
    if [ $(($(date +%s%N | cut -b1-13)-$pulseStart)) -gt $REBOOTPULSEMINIMUM ]; then 
      echo "X730 Rebooting", SHUTDOWN, ", recycling Rpi ..."
      sudo reboot
      exit
    fi
  fi
done' | sudo tee /usr/local/bin/x735pwr.sh
sudo chmod +x /usr/local/bin/x735pwr.sh


#X735 full shutdown through Software

echo '#!/bin/bash

BUTTON=18

echo "$BUTTON" > /sys/class/gpio/export;
echo "out" > /sys/class/gpio/gpio$BUTTON/direction
echo "1" > /sys/class/gpio/gpio$BUTTON/value

SLEEP=${1:-4}

re='^[0-9\.]+$'
if ! [[ $SLEEP =~ $re ]] ; then
   echo "error: sleep time not a number" >&2; exit 1
fi

echo "X735 Shutting down..."
/bin/sleep $SLEEP

#restore GPIO 18
echo "0" > /sys/class/gpio/gpio$BUTTON/value' | sudo tee /usr/local/bin/x735shutdown.sh
sudo chmod +x /usr/local/bin/x735shutdown.sh


#X735 Systemd service

echo '[Unit]
Description=Startup Script
After=reboot.target

[Service]
Type=simple
ExecStart=/bin/bash /usr/local/sbin/x735pwr.sh

[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/shutdown_x735.service

sudo systemctl enable shutdown_x735
