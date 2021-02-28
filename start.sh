#! /bin/sh

# Reset RAK2245 PIN
SX1301_RESET_BCM_PIN=17
echo "out" >/sys/class/gpio/gpio$SX1301_RESET_BCM_PIN/direction
echo "0"   >/sys/class/gpio/gpio$SX1301_RESET_BCM_PIN/value
sleep 0.1
echo "1"   >/sys/class/gpio/gpio$SX1301_RESET_BCM_PIN/value
sleep 0.1
echo "0"   >/sys/class/gpio/gpio$SX1301_RESET_BCM_PIN/value

cd $SNAP_COMMON

if [ ! -e "local_conf.json" ]; then
  if grep -q eth0 /proc/net/dev; then
    DEV="eth0"
  else
    if grep -q wlan0 /proc/net/dev; then
      DEV="wlan0"
    else
      echo "Error: no network device found, exiting !!!"
	  exit 1
    fi
  fi
  GW_ID="$(ip link show ${DEV} | awk '/ether/ {print $2}' | \
	  awk -F\: '{print $1$2$3"FFFE"$4$5$6}' | \
	  tr '[:lower:]' '[:upper:]')"
  /usr/bin/echo -e "{\n\t\"gateway_conf\": {\n\t\t\"gateway_ID\": \"$GW_ID\",\n\t\t\"server_address\": \"localhost\",\n\t\t\"serv_port_up\": 1680,\n\t\t\"serv_port_down\": 1680,\n\t}\n}" >local_conf.json
fi

$SNAP/bin/lora_pkt_fwd
