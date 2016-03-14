#!/bin/bash

PORT11=26379
PORT12=26380
PORT13=26381
PORT21=26389
PORT22=26390
PORT23=26391
SENTINEL_CONF=./sentinel-shardALL.conf
SENTINEL_PORT=`grep port $SENTINEL_CONF | awk '{print $2}'`

start() {
  echo -n "Starting Redis server: "
  redis-server --port ${PORT11} &
  redis-server --port ${PORT12} --slaveof 127.0.0.1 ${PORT11} &
  redis-server --port ${PORT13} --slaveof 127.0.0.1 ${PORT11} &
  redis-server --port ${PORT21} &
  redis-server --port ${PORT22} --slaveof 127.0.0.1 ${PORT21} &
  redis-server --port ${PORT23} --slaveof 127.0.0.1 ${PORT21} &

  redis-sentinel $SENTINEL_CONF
}

stop() {
  echo "Save and Quit Redis server... "
  redis-cli -h localhost -p $PORT11 SHUTDOWN
  redis-cli -h localhost -p $PORT12 SHUTDOWN
  redis-cli -h localhost -p $PORT13 SHUTDOWN
  redis-cli -h localhost -p $PORT21 SHUTDOWN
  redis-cli -h localhost -p $PORT22 SHUTDOWN
  redis-cli -h localhost -p $PORT23 SHUTDOWN

  redis-cli -h localhost -p $SENTINEL_PORT SHUTDOWN
}

info() {
  echo "== redis-shard1 :1"
  redis-cli -h localhost -p $PORT11 INFO | grep role
  echo "== redis-shard1 :2"
  redis-cli -h localhost -p $PORT12 INFO | grep role
  echo "== redis-shard1 :3"
  redis-cli -h localhost -p $PORT13 INFO | grep role
  echo "== redis-shard2 :1"
  redis-cli -h localhost -p $PORT21 INFO | grep role
  echo "== redis-shard2 :2"
  redis-cli -h localhost -p $PORT22 INFO | grep role
  echo "== redis-shard2 :3"
  redis-cli -h localhost -p $PORT23 INFO | grep role
  echo "== redis-shardALL :centinel"
  redis-cli -h localhost -p $SENTINEL_PORT INFO SENTINEL
}

11-down() {
  echo "Sleep 10s Redis server shard1 01... "
  redis-cli -h localhost -p $PORT11 DEBUG sleep 10
}

12-down() {
  echo "Sleep 10s Redis server shard1 02... "
  redis-cli -h localhost -p $PORT12 DEBUG sleep 10
}

13-down() {
  echo "Sleep 10s Redis server shard1 03... "
  redis-cli -h localhost -p $PORT13 DEBUG sleep 10
}

21-down() {
  echo "Sleep 10s Redis server shard2 01... "
  redis-cli -h localhost -p $PORT21 DEBUG sleep 10
}

22-down() {
  echo "Sleep 10s Redis server shard2 02... "
  redis-cli -h localhost -p $PORT22 DEBUG sleep 10
}

23-down() {
  echo "Sleep 10s Redis server shard2 03... "
  redis-cli -h localhost -p $PORT23 DEBUG sleep 10
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
  11-down)
    11-down
  ;;
  12-down)
    12-down
  ;;
  13-down)
    13-down
  ;;
  21-down)
    21-down
  ;;
  22-down)
    22-down
  ;;
  23-down)
    23-down
  ;;
  *)
    echo "Usage: $0 {start|stop|restart|info|1-down|2-down|3-down}"
esac

exit $RETVAL
