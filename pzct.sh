#!/bin/bash
#
PIDFILE=~/pzct.pid
[[ -f $PIDFILE ]] && { echo "Seems pzct is already running, PID $(cat $PIDFILE)"; exit 0; }
echo $$ > $PIDFILE
trap "rm -f $PIDFILE" EXIT 2 3 15 SIGTSTP
#
IFS=$'\n\t'
#set -euo pipefail #-x #uncomment for debugging
#
SERVDIR=/opt/pzserver
ZDIR=/home/fuks/Zomboid
LOGFILE=/home/fuks/Zomboid/server-console.txt
BAKDIR=/opt/pzbackup
#
# simple menu entries and functionalities
#
func_self-edit() { mcedit ${BASH_SOURCE[0]}; exit 0; }
#
menu_entry_version() { echo -e "pzct, Project Zomboid Command Tool.  Version 0.9, 10-Sept-2023.\n\n  Copyright (C) 2022-2023 by Roman Fuks, Novosibirsk.\n\n  This program is free software.\n  You may distribute the program for non-commercial purposes;\n  you may modify the program for personal use;\n  you may NOT do both of these things at the same time.\n\n  In case of modification, leave a link to my authorship of the original program.\n\n  Contact:\n  https://t.me/vsnegupal\n  vsnegupal@gmail.com\n"; exit 0; }
#
menu_entry_usage() { echo "Usage: pzct start | quit | backup | log | kill | help will show you the full list"; exit 0; }
#
func_server-console_backup() { cp -v "$LOGFILE" $BAKDIR/logs/log_$(date +%F-%H:%M).txt; }
#
menu_entry_log() { rm -f $PIDFILE; local DEFAULT=25; tail --lines ${1-$DEFAULT} -f "$LOGFILE"; } #нужно доделать
#
func_pid() {
	PID=$(pgrep --full "ProjectZomboid64")
	RETCODE="$?"
	[[ -z $PID ]]\
		&& PID="Seems the server isn't running. Operation aborted."\
		|| MSG_IF_RUNNING="Seems the server is running with PID "$PID". You should stop it first. Operation aborted.";
	echo "$PID"
	return $RETCODE;
} # end of func_pid
#
menu_entry_kill() {
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
} # end of menu_entry_kill
#
menu_entry_message() {
	local RCONYAML=/usr/local/etc/rcon.yaml
	shift;
	MESSAGE="$*"
	echo -e \'servermsg \"$MESSAGE\"\' | xargs rcon -c /usr/local/etc/rcon.yaml &>/dev/null;
#	rcon -c $RCONYAML "servermsg \"$MESSAGE\"" &>/dev/null;
} # end of menu_entry_message
#
menu_entry_quit() {
  func_pid &>/dev/null;
  if [[ $? == 0 ]]; then
    if [[ "$#" -eq 1 || "$2" == "" ]]; then
      #arrays
      arr_sec=(5 100 5 10)
      arr_msg=(
        "Сервер будет перезагружен через 2 минуты. Примите безопасную позу."
        "The server will be restarted in 2 minutes. Take a safe position."
        "Сервер будет перезагружен через 15 секунд. Подключайтесь снова через 5 минут."
        "The server will restart in 10 seconds. Connect again in 5 minutes."
      )
      arr_not=(
        "Двухминутное уведомление на русском отправлено."
        "Двухминутное уведомление на английском отправлено."
        "Второе уведомление на русском отправлено."
        "Второе уведомление на английском отправлено."
      )
      #end of arrays
		
	for i in ${!arr_sec[@]}; do
		MSG=${arr_msg[$1]};
		menu_entry_message $MSG;
		echo "${arr_not[$1]}" >&2;
		sleep ${arr_sec[$1]};
	done
	
	elif [[ "$#" -ge 2 && "$2" != "--now" ]]; then
	  echo "Unknown parameter \""$2"\". Operation aborted."; exit 0;
	  
    elif [[ "$2" == "--now" ]]; then
	  echo "With --now option, the server will be stopped immediately without any notifications.";
	  
	fi
	
#    rcon -c $RCONYAML quit &>/dev/null && echo "Команда quit отправлена" >&2
#	  while $(kill -0 $PID &>/dev/null); do
#        sleep 1;
#      done;
#    func_server-console_backup;
	
  else
    echo "$PID";
  fi
  exit 0;
} # end of menu_entry_quit
#
menu_entry_backup() {
  
  func_backup_dirs() {
    tar cf - "$1" -P\
	  | pv -s $(du -sb "$1" | awk '{print $1}')\
	  | pbzip2 > "$2"
  }
  
  func_pid &>/dev/null;
    if [[ "$?" == "0" ]]; then
      echo "$MSG_IF_RUNNING"
	else
      func_server-console_backup;
      func_backup_dirs "$ZDIR/Logs" "$BAKDIR/logs/Logs_$(date +%F-%H:%M).tar.bz2"
      rm -vrf $ZDIR/Logs/*
      func_backup_dirs "$ZDIR" "/home/fuks/bak.tar.bz2"
      mv -v $BAKDIR/bak.tar.bz2 $BAKDIR/bak.tar.bz2_prev
      mv -v /home/fuks/bak.tar.bz2 $BAKDIR/bak.tar.bz2
    fi
	exit 0;
} # end of menu_entry_backup
#
menu_entry_start() {

  func_pid &>/dev/null;
#  echo $RETCODE
  if [[ "$RETCODE" == "0" ]]; then
      echo "$MSG_IF_RUNNING"
  else
      cp -v $BAKDIR/ProjectZomboid64.json $SERVDIR
      cp -v -t $ZDIR/Server $BAKDIR/servertest_SandboxVars.lua $BAKDIR/servertest.ini
      nohup $SERVDIR/start-server.sh &>/dev/null &
  fi
  exit 0;
} # end of menu_entry_start
#
menu_entry_serverupdate() {
  func_pid &>/dev/null;
  if [[ "$?" == "0" ]]; then
    echo "$MSG_IF_RUNNING"
  else
    local CMDDIR=/opt/steamcmd
    $CMDDIR/steamcmd.sh +force_install_dir $SERVDIR +login anonymous +app_update 380870 validate +quit &&
    cp -v $BAKDIR/ProjectZomboid64.json $SERVDIR
  fi
  exit 0;
} # end of menu_entry_serverupdate
#
menu_entry_help() {
  echo -e "\
  usage: pzct command [options]

  Commands:

  start                   run the start-server.sh script in the background

  -q, quit                send a quit command to the server using rcon
                          with chat notifications and a two-minute delay (can be modified)

  -q --now, quit --now    the same command will be sent immediately without notifications

  kill                    immediately terminate the server process (without using rcon)

  backup                  pack \"/Zomboid/Logs\" directory into an archive
                            and move it to a specific location,
                            then delete all files from \"/Zomboid/Logs\" directory.
                          After that, pack whole \"/Zomboid\" directory into an archive
                            and move it to a specific location.
                              (usually there are two of \"/Zomboid\" archives
                                - the last and the previous one)

  -l, log [N]             display the last N lines of server-console.txt
                            and then monitors the file
                              (25 lines by default)

  serverupdate            update the server application with steamcmd.sh

  -p, pid                 just show PID of the server process (if it's running)

  -u, usage               show a brief help on how to use this utility

  -v, version             show the program version and its brief description

  -h, help                show this message
  ";
  exit 0;
} # end of menu_entry_help
#

### menu section
case $1 in

  start) menu_entry_start;;

  -q | quit) menu_entry_quit $@;;

  backup) menu_entry_backup;;

  -l | log) menu_entry_log $2;;

  -p | pid) func_pid;;

  kill) menu_entry_kill;;

  serverupdate) menu_entry_serverupdate;;

  -u | usage) menu_entry_usage;;

  -h | help) menu_entry_help;;

  -v | version) menu_entry_version;;

  -se) func_self-edit;;
  
  -message | -m) menu_entry_message $*;;

  *) echo -e "pzct: You must specify one of the options.\nTry 'pzct usage' or 'pzct help' for more information.";;

esac
