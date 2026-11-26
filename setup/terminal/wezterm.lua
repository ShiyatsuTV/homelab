-- WezTerm config — voir homelab/setup/terminal
local wezterm = require 'wezterm'
local act = wezterm.action
local config = wezterm.config_builder()

--------------------------------------------------
-- Général : Git Bash (login + interactif pour charger ~/.bashrc et Starship)
--------------------------------------------------
config.default_prog = { 'C:\\Program Files\\Git\\bin\\bash.exe', '--login', '-i' }
config.default_cwd = wezterm.home_dir

--------------------------------------------------
-- Police : JetBrains Mono + icônes Nerd Font intégrées à WezTerm
--------------------------------------------------
config.font = wezterm.font_with_fallback {
  'JetBrains Mono',
  'Symbols Nerd Font Mono',
}
config.font_size = 12.5
config.line_height = 1.1
config.harfbuzz_features = { 'calt=1', 'liga=1' }

--------------------------------------------------
-- Fenêtre et onglets
--------------------------------------------------
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = true
config.window_padding = { left = 10, right = 10, top = 6, bottom = 8 }
config.window_decorations = 'TITLE | RESIZE'
config.window_background_opacity = 0.90
config.text_background_opacity = 1.0
config.adjust_window_size_when_changing_font_size = false

--------------------------------------------------
-- Curseur
--------------------------------------------------
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 600

--------------------------------------------------
-- Couleurs (Hyprland inspired, base Catppuccin)
--------------------------------------------------
config.colors = {
  foreground = '#CDD6F4',
  background = '#0F111A',

  cursor_bg = '#89B4FA',
  cursor_border = '#89B4FA',
  cursor_fg = '#0F111A',

  selection_bg = '#313244',
  selection_fg = '#CDD6F4',

  ansi = {
    '#1E1E2E', '#F38BA8', '#A6E3A1', '#F9E2AF',
    '#89B4FA', '#CBA6F7', '#94E2D5', '#BAC2DE',
  },
  brights = {
    '#585B70', '#F38BA8', '#A6E3A1', '#F9E2AF',
    '#89B4FA', '#CBA6F7', '#94E2D5', '#A6ADC8',
  },
}

--------------------------------------------------
-- Performances
--------------------------------------------------
-- WebGpu freezait au resize (build 20240203 + double GPU AMD + transparence).
-- Pour revenir à WebGpu, remplacer par :
--   config.front_end = 'WebGpu'
--   config.webgpu_power_preference = 'HighPerformance'
config.front_end = 'OpenGL'
config.animation_fps = 60
config.max_fps = 120

--------------------------------------------------
-- Raccourcis clavier
--------------------------------------------------
config.keys = {
  -- Nouvel onglet
  { key = 't', mods = 'CTRL|SHIFT', action = act.SpawnTab 'CurrentPaneDomain' },

  -- Splits : Alt+H = côte à côte, Alt+V = l'un au-dessus de l'autre
  { key = 'h', mods = 'ALT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = 'v', mods = 'ALT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- Navigation entre panneaux
  { key = 'LeftArrow',  mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow',    mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow',  mods = 'ALT', action = act.ActivatePaneDirection 'Down' },

  -- Fermer le panneau courant
  { key = 'q', mods = 'ALT', action = act.CloseCurrentPane { confirm = false } },
}

--------------------------------------------------
-- Souris : Alt + clic gauche pour déplacer la fenêtre
--------------------------------------------------
config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = 'Left' } },
    mods = 'ALT',
    action = act.StartWindowDrag,
  },
}

--------------------------------------------------
-- Divers
--------------------------------------------------
config.audible_bell = 'Disabled'
config.scrollback_lines = 10000

return config
