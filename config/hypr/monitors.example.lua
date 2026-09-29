-- Fallback per-host monitor layout. install.sh copies this to monitors.lua
-- when it can't auto-detect outputs. Edit to taste after first login:
--   hyprctl monitors        # list connected outputs + modes
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
