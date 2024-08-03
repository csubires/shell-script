#!/bin/bash

pid=$(ps aux | grep /usr/bin/firefox | grep Sl | awk '{print $2}')


echo "PRESIONA ENTER PARA CERRAR FIREFOX"
echo "PID:${pid}, KILL:echo ${pid}"

read var1

kill -9 ${pid}
