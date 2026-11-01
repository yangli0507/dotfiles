local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.color_scheme = "rose-pine-moon"
config.font = wezterm.font("Hack Nerd Font")
config.font_size = 15.0
config.window_background_opacity = 0.8
config.macos_window_background_blur = 50
config.hide_tab_bar_if_only_one_tab = true
--config.window_decorations = "TITLE | RESIZE"

config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"
config.window_frame = {
  font = wezterm.font("Hack Nerd Font", { weight = "Bold" }),
}
config.window_padding = {
  left = 12,
  right = 12,
  top = 64, -- Pushes text down below the native buttons
  bottom = 12,
}

config.inactive_pane_hsb = {
  saturation = 0.0,
  brightness = 0.5,
}

config.keys = {
  -- Toggle Fullscreen Mode with Ctrl + Shift + F11
  {
    key = "F",
    mods = "CMD|SHIFT",
    action = wezterm.action.ToggleFullScreen,
  },
  {
    key = "H",
    mods = "CMD",
    action = wezterm.action.Hide,
  },
  {
    key = "H",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "V",
    mods = "CTRL|SHIFT",
    action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
  },
}
-- Dim unfocused windows so the focused one is obvious at a glance.
local UNFOCUSED_FOREGROUND_TEXT_HSB = { hue = 1.0, saturation = 0.25, brightness = 0.45 }
local UNFOCUSED_WINDOW_BACKGROUND_OPACITY = 0.62

-- get_config_overrides() hands back a copy, so the current value is never the
-- same table we last stored; compare the fields instead of the identity.
local function same_text_hsb(actual, expected)
  if actual == nil or expected == nil then
    return actual == expected
  end
  return actual.hue == expected.hue
    and actual.saturation == expected.saturation
    and actual.brightness == expected.brightness
end

wezterm.on("window-focus-changed", function(window)
  local overrides = window:get_config_overrides() or {}
  local text_hsb, opacity
  if not window:is_focused() then
    text_hsb = UNFOCUSED_FOREGROUND_TEXT_HSB
    opacity = UNFOCUSED_WINDOW_BACKGROUND_OPACITY
  end

  -- Only write when one of the two values we own actually changes; a redundant
  -- set_config_overrides() call would trigger another config reload.
  if same_text_hsb(overrides.foreground_text_hsb, text_hsb) and overrides.window_background_opacity == opacity then
    return
  end

  overrides.foreground_text_hsb = text_hsb
  overrides.window_background_opacity = opacity
  window:set_config_overrides(overrides)
end)

return config
