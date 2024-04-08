#!/bin/bash
####
# COPYRIGHT AGREEMENT
#
# This program is freeware for personal use only.
# You may modify the program for personal use.
# You may distribute the unmodified program for non-commercial purposes.
# You may NOT distribute the program after you modify it.
# After modification, leave the text "https://github.com/vsnegupal/pzct" next to shebang in your script.
#
# Contact: https://t.me/vsnegupal vsnegupal@gmail.com
# 2022-2024, by Roman Fuks, Novosibirsk, Russia
###
#
MY_PATH="$(dirname -- "${BASH_SOURCE[0]}")"	# relative
MY_PATH="$(cd -- "$MY_PATH" && pwd)"		# absolutized and normalized
if [[ -z "$MY_PATH" ]] ; then
  echo -e "Error: directory $MY_PATH is inaccessible for some reason."
	# error; for some reason, the path is not accessible
	# to the script (e.g. permissions re-evaled after suid)
  exit 1
fi
#
PIDFILE="$MY_PATH"/pzct.pid
[ -f $PIDFILE ] && { echo "Seems pzct is already running with PID $(cat $PIDFILE)"; exit 0; }
echo $$ > $PIDFILE
trap "rm -f $PIDFILE" EXIT 2 3 15 SIGTSTP
#
IFS=$'\n\t'
#
#set -u
#set -o pipefail
#set -x
#set -e
#
func_checkperms() {
  local PERMS=$1
  local TARGET=$2
  for ((chpcount=0; chpcount<${#PERMS}; chpcount++)); do
    case "${PERMS:$chpcount:1}" in
      e)
        if [ ! -e "$TARGET" ]; then
          echo "Error: $TARGET not exists."
          return 1
        fi
        ;;
      r)
        if [ ! -r "$TARGET" ]; then
          echo "Error: $TARGET is not readable."
          return 1
        fi
        ;;
      w)
        if [ ! -w "$TARGET" ]; then
          echo "Error: $TARGET is not writable."
          return 1
        fi
        ;;
      x)
        if [ ! -x "$TARGET" ]; then
          echo "Error: $TARGET is not executable."
          return 1
        fi
        ;;
      *)
        echo "Error: unknown argument ${PERMS:$chpcount:1}"
        return 1
        ;;
    esac
  done
  return 0
  } # end of func_checkperms
#func_checkperms erwx "$TARGET" || return
#
if func_checkperms er "$MY_PATH"/pzct.conf; then
  echo -e "$MY_PATH/pzct.sh will use $MY_PATH/pzct.conf"
  source "$MY_PATH"/pzct.conf
fi
#
# simple menu entries and functionalities
func_version() { echo -e "pzct, Project Zomboid Command Tool.  Version 1.1, 19-04-2024.\n\n  This program is freeware for personal use only.\n\n  Special thanks to:\n  joljaycups from Discord for help with func_message"; exit 0; }
func_usage() { echo "Usage: pzct start | quit | backup | checkmods | restart | log | help will show you the full list"; exit 0; }
func_server-console_backup() { cp -v "$Zomboid_DIR"/server-console.txt "$pzbackup_DIR"/server-console_"$(date +%F-%H:%M)".txt; }
func_log() { rm -f $PIDFILE; local DEFAULT=25; tail --lines ${1-$DEFAULT} -f "$Zomboid_DIR"/server-console.txt; }	#usable but rework is needed
#

func_pid() {
  PID=$(pgrep --full "ProjectZomboid64")
  RETCODE="$?"
  [ -z "$PID" ] && PID="Seems the server isn't running. Operation aborted."\
    || MSG_IF_RUNNING="Seems the server is running with PID "$PID". You should stop it first. Operation aborted.";
  echo "$PID"
  return $RETCODE;
  } # end of func_pid
#
func_kill() {
  func_pid &>/dev/null;
  local NTFCTN="$PID"
  if [ $RETCODE -eq 0 ]; then
    timer=0
    kill -9 $PID
    while $(kill -0 $PID &>/dev/null); do
      sleep 1
      timer=$(( $timer + 1 ));
    done
    NTFCTN="Process with PID $PID killed successfully in $timer seconds."	#this command was added just for clarity
    func_server-console_backup;
  fi
  echo "$NTFCTN"
  exit 0;
  } # end of func_kill
#
func_message() {

  func_checkperms ex "$RCON" || return
  func_checkperms er "$RCONYAML" || return

  if [ $1 == "-m" ]; then
    shift;
  fi
  local MESSAGE="$*"
  echo -e \'servermsg \"$MESSAGE\"\' | xargs "$RCON" -c "$RCONYAML" &>/dev/null;	#Thanks again joljaycups
  } # end of func_message
#
func_players() {

  func_checkperms ex "$RCON" || return
  func_checkperms er "$RCONYAML" || return

  func_pid &>/dev/null;

  if [ $? -eq 0 ]; then
    "$RCON" -c "$RCONYAML" players
  else
    echo "$PID";
  fi
  } # end of func_players
#
func_thunder() { # I love thunder sounds, and I will make everyone love it.

  func_checkperms ex "$RCON" || return
  func_checkperms er "$RCONYAML" || return

  func_pid &>/dev/null;
  if [ $? -eq 0 ]; then
    list_players=$(func_players)
    mapfile -t array < <(echo "$list_players" | tail -n +2 | sed 's/^.*-//')
    #echo ${array[@]}					# Actually, when you run "thunder username",
    if [[ ${#array[@]} -gt 0 ]]; then			# it doesn't sound only for the player
      #echo ${#array[@]}				# with the specified username, but for everyone.
      random_index=$(( $RANDOM % ${#array[@]} ))	# However, there is no "all" option for rcon-cli,
      random_element=${array[$random_index]}		# and you have to specify an username.
      "$RCON" -c "$RCONYAML" "thunder $random_element"	# Therefore, we pick a random one.
    fi							# It may not work sometimes, but mostly it works.
  else
    echo "$PID";
  fi
  } # end of func_thunder
#
func_quit() {

  func_checkperms ex "$RCON" || return
  func_checkperms er "$RCONYAML" || return

  func_pid &>/dev/null;
  if [ $? -eq 0 ]; then
    if [[ "$#" -eq 1 || "$2" == "" ]]; then
      #arrays
        arr_sec=(120 10) # if needed, change the values.
        arr_msg=(
### INGAME NOTIFICATIONS BELOW
          "Server restarts in ${arr_sec[0]} seconds. Take a safe position."
          "Server restarts in ${arr_sec[1]} seconds. Reconnect in 3 minutes."
        )
        arr_not=(
          "The first notification was sent."
          "The second notification was sent."
        )
      #end of arrays
#
      for qcount in ${!arr_sec[@]}; do
        func_thunder;
        func_message ${arr_msg[$qcount]};
        echo "${arr_not[$qcount]}" >&2;
        sleep ${arr_sec[$qcount]};
      done
#
    elif [[ "$#" -ge 2 && "$2" != "--now" ]]; then
      echo "Unknown parameter \""$2"\". Operation aborted."; exit 0;
    elif [[ "$2" == "--now" ]]; then
      echo "With --now option, the server will be stopped immediately without any notifications.";
    fi
#
    "$RCON" -c "$RCONYAML" quit &>/dev/null && echo "'Quit' command has been sent..." >&2
    while $(kill -0 $PID &>/dev/null); do
      sleep 1;
    done;
    echo -e "The server has been stopped...\n"
    func_server-console_backup;
  else
    echo "$PID";
  fi
  } # end of func_quit
#
func_backup() {

  func_backup_dirs() {
    if [ -n "$(which pv 2>/dev/null)" -a -n "$(which pbzip2 2>/dev/null)" ]; then
      #Advanced option for the CLI, shows archiving progress, takes less time due to the use of pbzip2. Requires pbzip2 and pv installed.
      EXTENSION=bz2
      tar cf - "$1" -P | pv -s $(du -sb "$1" | awk '{print $1}') | pbzip2 > "$2"
    else
      EXTENSION=gz
      tar -cvzf "$2" "$1";    #it's highly likely to work for everyone
    fi
    } # end of func_backup_dirs
#
  func_checkperms er "$Zomboid_DIR" || return
  func_checkperms erw "$pzbackup_DIR" || return

  func_pid &>/dev/null;
  if [ $? -eq 0 ]; then
    echo "$MSG_IF_RUNNING"
  else
    func_server-console_backup;
    func_backup_dirs "" "" &>/dev/null;
    func_backup_dirs "$Zomboid_DIR"/Logs "$pzbackup_DIR"/Logs_"$(date +%F-%H:%M)".tar."$EXTENSION"
    rm -vrf "$Zomboid_DIR"/Logs/*
    func_backup_dirs "$Zomboid_DIR" "$pzbackup_DIR"/Zomboid_backup_"$(date +%F-%H:%M)".tar."$EXTENSION"
    echo -e "The backup was done...\n"
  fi
  } # end of func_backup
#
func_start() {
  func_pid &>/dev/null;
  #echo $RETCODE
  if [[ "$RETCODE" == "0" ]]; then
    echo "$MSG_IF_RUNNING"
  else
    if [[ $FILES == "1" ]]; then
      echo -e "FILES = $FILES"

      func_checkperms er "$pzbackup_DIR" || return
      func_checkperms erw "$Zomboid_DIR" || return
      func_checkperms erw "$pzserver_DIR" || return

      cp -v "$pzbackup_DIR"/ProjectZomboid64.json "$pzserver_DIR"
      cp -v -t "$Zomboid_DIR"/Server "$pzbackup_DIR"/servertest_SandboxVars.lua "$pzbackup_DIR"/servertest.ini
    fi

    func_checkperms er "$pzserver_DIR" || return
    func_checkperms ex "$pzserver_DIR"/start-server.sh || return

    echo -e "Starting the server...\n"
    nohup "$pzserver_DIR"/start-server.sh &>/dev/null &
  fi
  exit 0;
  } # end of func_start
#
func_serverupdate() {
  func_pid &>/dev/null;
  if [ $? -eq 0 ]; then
    echo "$MSG_IF_RUNNING"
  else

    func_checkperms erw "$pzserver_DIR" || return
    func_checkperms erw "$pzbackup_DIR" || return
    func_checkperms er "$steamcmd_DIR" || return
    func_checkperms ex "$pzserver_DIR"/steamcmd.sh || return

    cp -v "$pzserver_DIR"/ProjectZomboid64.json "$pzbackup_DIR"
    "$steamcmd_DIR"/steamcmd.sh +force_install_dir "$pzserver_DIR" +login anonymous +app_update 380870 validate +quit &&
    cp -v "$pzbackup_DIR"/ProjectZomboid64.json "$pzserver_DIR"
  fi
  exit 0;
  } # end of func_serverupdate
#
#######

func_restart() { func_quit "quit" && func_backup && func_start; }

#######
#
func_checkmods() {

  func_checkperms ex "$RCON" || return
  func_checkperms er "$RCONYAML" || return
  func_checkperms er "$Zomboid_DIR" || return
  func_checkperms er "$Zomboid_DIR"/server-console.txt || return

  func_pid &>/dev/null;
  if [ $? -eq 0 ]; then
    MODSNEEDUPDATE=0
    "$RCON" -c "$RCONYAML" checkModsNeedUpdate &>/dev/null
    tail -n 0 -f "$Zomboid_DIR"/server-console.txt | while read LINE
      do
        echo $LINE
        case "$LINE" in
          *"CheckModsNeedUpdate: Mods need update"*)
            MODSNEEDUPDATE=1
            break
            ;;
          *"CheckModsNeedUpdate: Mods updated"*)
            echo -e "Nothing to do.\n"
            break
            ;;
        esac
      done
    if [[ "$MODSNEEDUPDATE" == "1"  ]]; then
      echo -e "Mods need to be updated. Performing restart in 10 seconds, press Ctrl+C to abort.\n"
      chmcount=0
      while [[ chmcount -lt 10 ]]; do
        ((chmcount++))
        echo -n "."
        sleep 1
      done
      #echo -e "\n"
      func_restart;
    fi
  else
    echo "$PID";
  fi
  exit 0;
  } # end of func_checkmods
#
func_help() {
  echo -e "\
  usage: pzct command [options]

  Commands:

  -b, backup			perform a backup

  -chm, checkmods		check if mods need update or not

  -h, help			show this message

  -k, kill			immediately terminate the server process (without using rcon)

  -l N, log N			display the last N lines of server-console.txt and then monitors the file (25 lines by default)

  -m text, message text		displays a message \"text\" in chat and in the middle of the screen

  -p, players			list all connected players

  -pid				just show PID of the server process (if it's running)

  -q, quit			send a quit command to the server using rcon
				with chat notifications and 120 seconds delay (can be modified)

  -q --now, quit --now		the same command will be sent immediately without notifications

  -r, restart			sequentially execute quit, backup and start, done mostly for cron

  -s, start			run the start-server.sh script in the background

  -serverupdate			update the server application with steamcmd.sh

  -t, thunder			thunder sounds for everyone

  -u, usage			show a brief help on how to use this utility

  -v, version			show the program version and its brief description\n";
  exit 0;
  } # end of func_help
#
### menu section
#
  case $1 in
    -b | backup) func_backup; exit 0;;
    -chm | checkmods) func_checkmods;;
    -h | help) func_help;;
    -k | kill) func_kill;;
    -l | log) func_log $2;;
    -m | message) func_message $*;;
    -p | players) func_players; exit 0;;
    -pid) func_pid;;
    -q | quit) func_quit $@; exit 0;;
    -r | restart) func_restart; exit 0;;
    -s | start) func_start;;
    -serverupdate) func_serverupdate;;
    -t | thunder) func_thunder; exit 0;;
    -u | usage) func_usage;;
    -v | version) func_version;;
    *) echo -e "pzct: You must specify one of the options.\nTry 'pzct usage' or 'pzct help' for more information.";;
  esac
