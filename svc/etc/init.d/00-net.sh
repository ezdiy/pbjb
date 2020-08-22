#!/bin/sh
ifconfig lo up 127.0.0.1

# cca 100 seconds to drop dead tcp sessions
sysctl -w net.ipv4.tcp_retries2=9
