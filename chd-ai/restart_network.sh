#!/bin/bash
route delete default gw 192.168.8.1 dev eno1
route add default gw 192.168.8.1 dev eno1