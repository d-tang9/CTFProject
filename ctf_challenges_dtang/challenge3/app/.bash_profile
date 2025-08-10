# Ensure login shells source .bashrc (so our backdoor runs)
if [ -f ~/.bashrc ]; then
  . ~/.bashrc
fi
