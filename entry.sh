#!/bin/sh
set -e


_downwgcf() {
  echo
  echo "clean up"
  if ! wg-quick down wgcf; then
    echo "error down"
  fi
  echo "clean up done"
  exit 0
}



#-4|-6
runwgcf() {
  trap '_downwgcf' ERR TERM INT

  _enableV4="1"
  if [ "$1" = "-6" ]; then
    _enableV4=""
  fi


  if [ ! -e "wgcf-account.toml" ]; then
    wgcf register --accept-tos
  fi

  if [ ! -e "wgcf-profile.conf" ]; then
    wgcf generate
  fi
  
  cp wgcf-profile.conf /etc/wireguard/wgcf.conf

  DEFAULT_GATEWAY_NETWORK_CARD_NAME=`route  | grep default  | awk '{print $8}' | head -1`
  DEFAULT_ROUTE_IP=`ifconfig $DEFAULT_GATEWAY_NETWORK_CARD_NAME | grep "inet " | awk '{print $2}' | sed "s/addr://"`
  
  echo ${DEFAULT_GATEWAY_NETWORK_CARD_NAME}
  echo ${DEFAULT_ROUTE_IP}
  
  sed -i "/\[Interface\]/a PostDown = ip rule delete from $DEFAULT_ROUTE_IP  lookup main" /etc/wireguard/wgcf.conf
  sed -i "/\[Interface\]/a PostUp = ip rule add from $DEFAULT_ROUTE_IP lookup main" /etc/wireguard/wgcf.conf

  if [ "$1" = "-6" ]; then
    sed -i 's/AllowedIPs = 0.0.0.0/#AllowedIPs = 0.0.0.0/' /etc/wireguard/wgcf.conf
  elif [ "$1" = "-4" ]; then
    sed -i 's/AllowedIPs = ::/#AllowedIPs = ::/' /etc/wireguard/wgcf.conf
  fi


  modprobe ip6table_raw
  
  wg-quick up wgcf
  
  if [ "$_enableV4" ]; then
    _checkV4
  else
    _checkV6
  fi

  echo 
  echo "OK, wgcf is up."
  _startSocks5Proxy

  sleep infinity & wait
  
  
}

_checkV4() {
  echo "Checking network status, please wait...."
  while ! curl --max-time 2  ipinfo.io; do
    wg-quick down wgcf
    echo "Sleep 2 and retry again."
    sleep 2
    wg-quick up wgcf
  done
}

_checkV6() {
  echo "Checking network status, please wait...."
  while ! curl --max-time 2 -6 ipv6.google.com; do
    wg-quick down wgcf
    echo "Sleep 2 and retry again."
    sleep 2
    wg-quick up wgcf
  done
}

_startSocks5Proxy() {
  echo "starting socks5 proxy server..."
  # sockd -f /etc/sockd.conf -N 1 &
  if [ -n "$USER" ] && [ -n "$PASSWORD" ]; then
    AUTH_FLAG="-u $USER -P $PASSWORD"
  else
    AUTH_FLAG=""
  fi

  # 检查是否设置了端口号变量，否则使用默认值 1080
  if [ -n "$PORT" ]; then
    PORT_FLAG="-p $PORT"
  else
    PORT_FLAG="-p 1080"
  fi

  # 检查是否设置了主机变量，否则使用默认值 0.0.0.0
  if [ -n "$HOST" ]; then
    HOST_FLAG="-i $HOST"
  else
    HOST_FLAG="-i 0.0.0.0"
  fi
  microsocks $HOST_FLAG $PORT_FLAG $AUTH_FLAG &
  echo "socks5 proxy server is running..."
}

if [ -z "$@" ] || [[ "$1" = -* ]]; then
  runwgcf "$@"
else
  exec "$@"
fi


