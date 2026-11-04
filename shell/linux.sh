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

