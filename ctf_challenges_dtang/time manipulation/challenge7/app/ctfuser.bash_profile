# Ensure login shells also load our breadcrumbs
if [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi
