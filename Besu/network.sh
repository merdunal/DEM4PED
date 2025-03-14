#!/bin/bash

# PID dosyasının saklanacağı dosya
PID_FILE="besu_network_pids.txt"

# BESU klasöründe yer alan genesis dosyasının yolu
GENESIS_FILE="genesis.json"

# Belirtilen portun RPC servisi için dinleme durumunu kontrol eden fonksiyon
wait_for_rpc() {
  local port=$1
  local retries=10
  local count=0
  echo "Port $port için RPC servisi bekleniyor..."
  while ! nc -z 127.0.0.1 $port; do
    sleep 1
    count=$((count+1))
    if [ $count -ge $retries ]; then
      echo "Port $port için RPC servisi aktif değil. Çıkılıyor."
      return 1
    fi
  done
  echo "Port $port aktif."
  return 0
}

start_network() {
  echo "Besu düğümleri başlatılıyor..."

  # Node-1 için (RPC port: 8545)
  besu --data-path=Node-1/data --genesis-file="$GENESIS_FILE" \
    --permissions-nodes-config-file-enabled --permissions-accounts-config-file-enabled \
    --rpc-http-enabled --rpc-http-api=ADMIN,ETH,NET,WEB3,PERM,IBFT,TXPOOL \
    --rpc-http-port=8545 \
    --host-allowlist="*" --rpc-http-cors-origins="*" --profile=ENTERPRISE &
  echo $! >> $PID_FILE
  sleep 5

  # Node-2 için (p2p: 30304, RPC: 8546)
  besu --data-path=Node-2/data --genesis-file="$GENESIS_FILE" \
    --permissions-nodes-config-file-enabled --permissions-accounts-config-file-enabled \
    --rpc-http-enabled --rpc-http-api=ADMIN,ETH,NET,WEB3,PERM,IBFT,TXPOOL \
    --host-allowlist="*" --rpc-http-cors-origins="*" \
    --p2p-port=30304 --rpc-http-port=8546 --profile=ENTERPRISE &
  echo $! >> $PID_FILE
  sleep 2

  # Node-3 için (p2p: 30305, RPC: 8547)
  besu --data-path=Node-3/data --genesis-file="$GENESIS_FILE" \
    --permissions-nodes-config-file-enabled --permissions-accounts-config-file-enabled \
    --rpc-http-enabled --rpc-http-api=ADMIN,ETH,NET,WEB3,PERM,IBFT,TXPOOL \
    --host-allowlist="*" --rpc-http-cors-origins="*" \
    --p2p-port=30305 --rpc-http-port=8547 --profile=ENTERPRISE &
  echo $! >> $PID_FILE
  sleep 2

  # Node-4 için (p2p: 30306, RPC: 8548)
  besu --data-path=Node-4/data --genesis-file="$GENESIS_FILE" \
    --permissions-nodes-config-file-enabled --permissions-accounts-config-file-enabled \
    --rpc-http-enabled --rpc-http-api=ADMIN,ETH,NET,WEB3,PERM,IBFT,TXPOOL \
    --host-allowlist="*" --rpc-http-cors-origins="*" \
    --p2p-port=30306 --rpc-http-port=8548 --profile=ENTERPRISE &
  echo $! >> $PID_FILE
  sleep 2

  echo "Düğümler başlatıldı. RPC servislerinin hazır olması bekleniyor..."

  wait_for_rpc 8545 || exit 1
  wait_for_rpc 8546 || exit 1
  wait_for_rpc 8547 || exit 1
  wait_for_rpc 8548 || exit 1

  echo "RPC servisleri hazır. Şimdi peer ekleme işlemleri yapılıyor..."

  # Peer ekleme işlemleri (örnek enode adreslerini, kendi düğüm enode bilgilerinize göre güncelleyin)
  curl -X POST --data '{"jsonrpc":"2.0","method":"admin_addPeer","params":["enode://ea7d6fe491b82cf1260752ddf0851c7ccc2824740feed568b019eb188833906dfb3cfdc343513cb75d0157afa1c98408a3012c142f2dc57105cc3595872b928b@127.0.0.1:30303"],"id":1}' http://127.0.0.1:8546
  curl -X POST --data '{"jsonrpc":"2.0","method":"admin_addPeer","params":["enode://ea7d6fe491b82cf1260752ddf0851c7ccc2824740feed568b019eb188833906dfb3cfdc343513cb75d0157afa1c98408a3012c142f2dc57105cc3595872b928b@127.0.0.1:30303"],"id":1}' http://127.0.0.1:8547
  curl -X POST --data '{"jsonrpc":"2.0","method":"admin_addPeer","params":["enode://ea7d6fe491b82cf1260752ddf0851c7ccc2824740feed568b019eb188833906dfb3cfdc343513cb75d0157afa1c98408a3012c142f2dc57105cc3595872b928b@127.0.0.1:30303"],"id":1}' http://127.0.0.1:8548
  curl -X POST --data '{"jsonrpc":"2.0","method":"admin_addPeer","params":["enode://dd9c3057bd7c111d43dd5948446b3250c713471a6dad67f7233b2f34474c793d73dd5413c28298fe40c292d5df0f3d2632705358da528ab5aab1abc3f4c21b3b@127.0.0.1:30304"],"id":1}' http://127.0.0.1:8547
  curl -X POST --data '{"jsonrpc":"2.0","method":"admin_addPeer","params":["enode://dd9c3057bd7c111d43dd5948446b3250c713471a6dad67f7233b2f34474c793d73dd5413c28298fe40c292d5df0f3d2632705358da528ab5aab1abc3f4c21b3b@127.0.0.1:30304"],"id":1}' http://127.0.0.1:8548
  curl -X POST --data '{"jsonrpc":"2.0","method":"admin_addPeer","params":["enode://7a2ae5e4d6cf55f5d0e41a7b3b85eb1b4b221d4f7667ea9d2e548a1b4ed608754288f1426c39d35daa0b7bc36ad2dbcb874f884e8b6da214578b3b53fdddf4c2@127.0.0.1:30305"],"id":1}' http://127.0.0.1:8548

  echo "Ağ kurulumu tamamlandı."
}

stop_network() {
  if [ -f "$PID_FILE" ]; then
    echo "Besu düğümleri durduruluyor..."
    while read pid; do
      kill $pid 2>/dev/null && echo "Process $pid durduruldu."
    done < $PID_FILE
    rm -f $PID_FILE
    echo "Ağ tamamen durduruldu."
  else
    echo "PID dosyası bulunamadı. Düğümlerin çalıştığından emin olun."
  fi
}

case "$1" in
  start)
    start_network
    ;;
  stop)
    stop_network
    ;;
  *)
    echo "Kullanım: $0 {start|stop}"
    exit 1
    ;;
esac
