# Linux-specific shell setup

# Ensure common admin/system paths exist if present
if command -v path_prepend >/dev/null 2>&1; then
  path_prepend /usr/sbin
  path_prepend /usr/bin
else
  [ -d /usr/sbin ] && export PATH="/usr/sbin:$PATH"
  [ -d /usr/bin ] && export PATH="/usr/bin:$PATH"
fi

if command -v path_dedupe >/dev/null 2>&1; then
  path_dedupe
  export PATH
fi

# Run one app on the NVIDIA GPU (the session defaults to Intel, see zsh/zprofile). Plugged in only:
# Lenovo's Hybrid-Auto pulls the GPU on battery, which would crash the app.
nvrun() {
  __NV_PRIME_RENDER_OFFLOAD=1 __VK_LAYER_NV_optimus=NVIDIA_only __GLX_VENDOR_LIBRARY_NAME=nvidia \
    __EGL_VENDOR_LIBRARY_FILENAMES=/usr/share/glvnd/egl_vendor.d/10_nvidia.json VK_LOADER_DRIVERS_DISABLE= \
    "$@"
}
