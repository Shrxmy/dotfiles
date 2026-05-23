# Linux-specific shell setup

# Ensure common admin/system paths exist if present
if command -v path_prepend >/dev/null 2>&1; then
  path_prepend /usr/sbin
  path_prepend /usr/bin
else
  [ -d /usr/sbin ] && export PATH="/usr/sbin:$PATH"
  [ -d /usr/bin ] && export PATH="/usr/bin:$PATH"
fi

# CUDA 12.9 (Linux-only, if installed)
if [ -d "/usr/local/cuda-12.9/bin" ]; then
  if command -v path_prepend >/dev/null 2>&1; then
    path_prepend /usr/local/cuda-12.9/bin
  else
    export PATH="/usr/local/cuda-12.9/bin:$PATH"
  fi
  export LD_LIBRARY_PATH="/usr/local/cuda-12.9/lib64${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
fi

if command -v path_dedupe >/dev/null 2>&1; then
  path_dedupe
  export PATH
fi
