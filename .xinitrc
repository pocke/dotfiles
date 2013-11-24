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

#export LANG='ja_JP.utf8'

export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
ibus-daemon -drx

xmodmap .Xmodmap
xinput --disable "SynPS/2 Synaptics TouchPad"

#export VTE_CJK_WIDTH=1

exec awesome
# exec gnome-session
# exec startkde
#xfwm4&
# exec startxfce4
# ...or the Window Manager of your choice
