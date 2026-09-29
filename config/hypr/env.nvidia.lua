-- Copied to env.lua by install.sh when an NVIDIA GPU is detected.
-- Lua counterpart of env.nvidia.conf, required by hyprland.lua.
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")
hl.env("__NV_PRIME_RENDER_OFFLOAD", "1")
hl.env("__VK_LAYER_NV_optimus", "NVIDIA_only")
hl.config({
    cursor = {
        no_hardware_cursors = true,
    },
})
