#!/bin/bash

PORT1=26379
PORT2=26380
PORT3=26381
SENTINEL_CONF=./sentinel-shard1.conf
SENTINEL_PORT=`grep port $SENTINEL_CONF | awk '{print $2}'`

start() {
  echo -n "Starting Redis server: "
  redis-server --port ${PORT1} &
  redis-server --port ${PORT2} --slaveof 127.0.0.1 ${PORT1} &
  redis-server --port ${PORT3} --slaveof 127.0.0.1 ${PORT1} &

  redis-sentinel $SENTINEL_CONF
}

stop() {
  echo "Save and Quit Redis server... "
  redis-cli -h localhost -p $PORT1 SHUTDOWN
  redis-cli -h localhost -p $PORT2 SHUTDOWN
  redis-cli -h localhost -p $PORT3 SHUTDOWN

  redis-cli -h localhost -p $SENTINEL_PORT SHUTDOWN
}

info() {
  echo "== redis-shard1 :1"
  redis-cli -h localhost -p $PORT1 INFO | grep role
  echo "== redis-shard1 :2"
  redis-cli -h localhost -p $PORT2 INFO | grep role
  echo "== redis-shard1 :3"
  redis-cli -h localhost -p $PORT3 INFO | grep role
  echo "== redis-shard1 :centinel"
  redis-cli -h localhost -p $SENTINEL_PORT INFO SENTINEL
}

1-down() {
  echo "Sleep 10s Redis server 01... "
  redis-cli -h localhost -p $PORT1 DEBUG sleep 10
}

2-down() {
  echo "Sleep 10s Redis server 02... "
  redis-cli -h localhost -p $PORT2 DEBUG sleep 10
}

3-down() {
  echo "Sleep 10s Redis server 03... "
  redis-cli -h localhost -p $PORT3 DEBUG sleep 10
}

# See how we were called.
case "$1" in
  start)
    start
  ;;
  monit_start)
    crash_clean
    start
  ;;
  stop)
    stop
  ;;
  restart)
    stop
    start
  ;;
  info)
    info
  ;;
  1-down)
    1-down
  ;;
  2-down)
    2-down
  ;;
  3-down)
    3-down
  ;;
  *)
    echo "Usage: $0 {start|stop|restart|info|1-down|2-down|3-down}"
esac

exit $RETVAL
