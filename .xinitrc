#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# for fcitx
export GTK_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
export QT_IM_MODULE=fcitx
export DefaultIMModule=fcitx
fcitx

xset r rate 250 30
xset m 10 2

xmodmap .Xmodmap


tpset() { xinput set-prop "TPPS/2 IBM TrackPoint" "$@"; }

tpset "Evdev Wheel Emulation" 1
tpset "Evdev Wheel Emulation Button" 2
tpset "Evdev Wheel Emulation Timeout" 200
tpset "Evdev Wheel Emulation Axes" 6 7 4 5
tpset "Device Accel Constant Deceleration" 0.95

/usr/bin/start-pulseaudio-x11

exec awesome
# exec gnome-session
# exec startkde
#xfwm4&
# exec startxfce4
# ...or the Window Manager of your choice
