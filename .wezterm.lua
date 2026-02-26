local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.keys = {
  { key = "Enter", mods = "SHIFT", action = wezterm.action.SendString("\n") },
}

return config
