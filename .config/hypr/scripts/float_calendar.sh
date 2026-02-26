#!/bin/bash
# Ouvre un terminal flottant avec une vue calendrier
kitty --class kitty-calendar -e sh -c 'cal -y; read' &
sleep 0.3
hyprctl dispatch setfloating class:kitty-calendar
