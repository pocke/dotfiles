local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.keys = {
  { key = "Enter", mods = "SHIFT", action = wezterm.action.SendString("\n") },
}

config.colors = {
  foreground = '#C0C0C0',
  background = '#2E373A',
  cursor_bg = '#FFFFFF',
  cursor_fg = '#2E373A',
  cursor_border = '#FFFFFF',

  -- Tango palette
  ansi = {
    '#2E3436', -- black
    '#CC0000', -- red
    '#4E9A06', -- green
    '#C4A000', -- yellow
    '#3465A4', -- blue
    '#75507B', -- magenta
    '#06989A', -- cyan
    '#D3D7CF', -- white
  },
  brights = {
    '#555753', -- bright black
    '#EF2929', -- bright red
    '#8AE234', -- bright green
    '#FCE94F', -- bright yellow
    '#729FCF', -- bright blue
    '#AD7FA8', -- bright magenta
    '#34E2E2', -- bright cyan
    '#EEEEEC', -- bright white
  },
}

config.window_background_opacity = 0.95
config.swallow_mouse_click_on_window_focus = true
config.use_ime = true

return config
