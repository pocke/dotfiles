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

# for ibus
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
ibus-daemon -drx

xset r rate 250 30
xset m 10 4

xmodmap .Xmodmap
xinput --disable "SynPS/2 Synaptics TouchPad"

exec awesome
# exec gnome-session
# exec startkde
#xfwm4&
# exec startxfce4
# ...or the Window Manager of your choice
