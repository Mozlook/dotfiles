-- Copied to env.lua by install.sh when an NVIDIA GPU is detected.
-- Required by hyprland.lua (as env.lua).
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.config({
    cursor = {
        no_hardware_cursors = true,
    },
})
