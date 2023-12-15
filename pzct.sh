#!/bin/bash
###
# COPYRIGHT AGREEMENT
#
# This program is freeware for personal use only.
# You may modify the program for personal use.
# You may distribute the unmodified program for non-commercial purposes.
# You may NOT distribute the program after you modify it.
# In case of modification, leave a link to my authorship of the original program,
# which must include the following text: "https://github.com/vsnegupal/pzct"
#
# Contact: https://t.me/vsnegupal vsnegupal@gmail.com
# 2022-2024, by Roman Fuks, Novosibirsk, Russia
###
#
PIDFILE=~/pzct.pid
[[ -f $PIDFILE ]] && { echo "Seems pzct is already running, PID $(cat $PIDFILE)"; exit 0; }
echo $$ > $PIDFILE
trap "rm -f $PIDFILE" EXIT 2 3 15 SIGTSTP
#
IFS=$'\n\t'
#
set -u
#set -o pipefail
#set -x
#set -e
#
SERVDIR=/path/to/pzserver                      # e.g. /home/user/pzserver
ZDIR=/path/to/Zomboid                          # e.g. /home/user/Zomboid
LOGFILE=/path/to/Zomboid/server-console.txt    # e.g. /home/user/Zomboid/server-console.txt
BAKDIR=/path/to/backup/storage                 # e.g. /home/user/backup
CMDDIR=/path/to/steamcmd                       # e.g. /home/user/steamcmd
RCON=/path/to/rcon/executable                  # e.g. /home/user/rcon or /home/user/rcon-cli
RCONYAML=/path/to/rcon.yaml                    # e.g. /home/user/rcon.yaml
#
# simple menu entries and functionalities
func_self-edit() { mcedit ${BASH_SOURCE[0]}; exit 0; }
func_version() { echo -e "pzct, Project Zomboid Command Tool.  Version 0.9.1, 12-12-2023.\n\n  This program is freeware for personal use only.\n\n  Special thanks to:\n  joljaycups from Discord for help with func_message"; exit 0; }
func_usage() { echo "Usage: pzct start | quit | backup | kill | restart | log | help will show you the full list"; exit 0; }
func_server-console_backup() { cp -v "$LOGFILE" $BAKDIR/logs/log_$(date +%F-%H:%M).txt; }
func_log() { rm -f $PIDFILE; local DEFAULT=25; tail --lines ${1-$DEFAULT} -f "$LOGFILE"; } #usable but rework is needed
#
func_pid() {
  PID=$(pgrep --full "ProjectZomboid64")
  RETCODE="$?"
  [[ -z $PID ]] && PID="Seems the server isn't running. Operation aborted."\
    || MSG_IF_RUNNING="Seems the server is running with PID "$PID". You should stop it first. Operation aborted.";
  echo "$PID"
  return $RETCODE;
  } # end of func_pid
#
func_kill() {
  func_pid &>/dev/null;
  local NTFCTN="$PID"
  if [[ $RETCODE == 0 ]]; then
    timer=0
    kill -9 $PID
    while $(kill -0 $PID &>/dev/null); do
      sleep 1
      timer=$(( $timer + 1 ));
    done
    NTFCTN="Process with PID "$PID" killed successfully in $timer seconds." #this command was added just for clarity
    func_server-console_backup;
  fi
  echo "$NTFCTN"
  exit 0;
  } # end of func_kill
#
func_message() {
  #local RCONYAML=
  if [[ $1 == "-m" ]]; then
    shift;
  fi
  local MESSAGE="$*"
  echo -e \'servermsg \"$MESSAGE\"\' | xargs $RCON -c $RCONYAML &>/dev/null;
  } # end of func_message
#
func_quit() {
  #local RCONYAML=
  func_pid &>/dev/null;
  if [[ $? == 0 ]]; then
    if [[ "$#" -eq 1 || "$2" == "" ]]; then
      #arrays
        arr_sec=(110 10)
        arr_msg=(
          "The server will be restarted in 2 minutes. Take a safe position."
          "The server will restart in 10 seconds. Connect again in 5 minutes."
        )
        arr_not=(
          "The first notification was sent."
          "The second notification was sent."
        )
      #end of arrays
#
      for i in ${!arr_sec[@]}; do
        func_message ${arr_msg[$i]};
        echo "${arr_not[$i]}" >&2;
        sleep ${arr_sec[$i]};
      done
#
    elif [[ "$#" -ge 2 && "$2" != "--now" ]]; then
      echo "Unknown parameter \""$2"\". Operation aborted."; exit 0;
    elif [[ "$2" == "--now" ]]; then
      echo "With --now option, the server will be stopped immediately without any notifications.";
    fi
#
    $RCON -c $RCONYAML quit &>/dev/null && echo "'Quit' command has been sent" >&2
    while $(kill -0 $PID &>/dev/null); do
      sleep 1;
    done;
    func_server-console_backup;
  else
    echo "$PID";
  fi
  exit 0;
  } # end of func_quit
#
func_backup() {

  func_backup_dirs() {
    tar -cvzf "$2" "$1"    #it's highly likely to work for everyone
#
    #tar cf - "$1" -P\                               #Advanced option for the CLI, shows archiving progress, and the operation takes less time due to the use of pbzip2.
      #| pv -s $(du -sb "$1" | awk '{print $1}')\    #Requires pbzip2 and pv installed.
      #| pbzip2 > "$2"
    } # end of func_backup_dirs
#
  func_pid &>/dev/null;
  if [[ "$?" == "0" ]]; then
    echo "$MSG_IF_RUNNING"
  else
    func_server-console_backup;
    func_backup_dirs "$ZDIR/Logs" "$BAKDIR/logs/Logs_$(date +%F-%H:%M).tar.gz"
    rm -vrf $ZDIR/Logs/*
    func_backup_dirs "$ZDIR" "$HOME/bak.tar.gz"
    mv -v $BAKDIR/bak.tar.gz $BAKDIR/bak.tar.gz_prev
    mv -v $HOME/bak.tar.gz $BAKDIR/bak.tar.gz
  fi
  exit 0;
  } # end of func_backup
#
func_start() {
  func_pid &>/dev/null;
  #echo $RETCODE
  if [[ "$RETCODE" == "0" ]]; then
    echo "$MSG_IF_RUNNING"
  else
    #cp -v $BAKDIR/ProjectZomboid64.json $SERVDIR
    #cp -v -t $ZDIR/Server $BAKDIR/servertest_SandboxVars.lua $BAKDIR/servertest.ini
    nohup $SERVDIR/start-server.sh &>/dev/null &
  fi
  exit 0;
  } # end of func_start
#
func_serverupdate() {
  func_pid &>/dev/null;
  if [[ "$?" == "0" ]]; then
    echo "$MSG_IF_RUNNING"
  else
    #local CMDDIR=
    cp -v $SERVDIR/ProjectZomboid64.json $BAKDIR
    $CMDDIR/steamcmd.sh +force_install_dir $SERVDIR +login anonymous +app_update 380870 validate +quit &&
    cp -v $BAKDIR/ProjectZomboid64.json $SERVDIR
  fi
  exit 0;
  } # end of func_serverupdate
#
func_help() {
  echo -e "\
  usage: pzct command [options]

  Commands:

  start                   run the start-server.sh script in the background

  -q, quit                send a quit command to the server using rcon
                            with chat notifications and a two-minute delay (can be modified)

  -q --now, quit --now    the same command will be sent immediately without notifications

  kill                    immediately terminate the server process (without using rcon)

  backup                  pack \"/Zomboid/Logs\" directory into an archive and move it to a specific location,
                            then delete all files from \"/Zomboid/Logs\" directory.
                            After that, pack whole \"/Zomboid\" directory into an archive and move it to a specific location.
                            (usually there are two of \"/Zomboid\" archives - the last and the previous one)

  -l, log [N]             display the last N lines of server-console.txt and then monitors the file (25 lines by default)

  serverupdate            update the server application with steamcmd.sh

  -p, pid                 just show PID of the server process (if it's running)

  -u, usage               show a brief help on how to use this utility

  -v, version             show the program version and its brief description

  -h, help                show this message";
  exit 0;
  } # end of func_help
#
### menu section
#
  case $1 in
    start) func_start;;
    -q | quit) func_quit $@;;
    backup) func_backup;;
    -l | log) func_log $2;;
    -p | pid) func_pid;;
    kill) func_kill;;
    serverupdate) func_serverupdate;;
    -u | usage) func_usage;;
    -h | help) func_help;;
    -v | version) func_version;;
    -se) func_self-edit;;
    -m | message) func_message $*;;
    *) echo -e "pzct: You must specify one of the options.\nTry 'pzct usage' or 'pzct help' for more information.";;
  esac