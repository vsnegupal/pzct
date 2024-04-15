#!/bin/bash
#
# COPYRIGHT AGREEMENT
# This program is freeware for personal use only.
# You may modify the program for personal use.
# You may distribute the unmodified program for non-commercial purposes.
# You may NOT distribute the program after you modify it.
# After modification, leave the text "https://github.com/vsnegupal/pzct" next to shebang in your script.
# Contact: https://t.me/vsnegupal vsnegupal@gmail.com
# 2022-2024, by Roman Fuks, Novosibirsk, Russia
#
function_version() { echo -e " pzct, Project Zomboid Console (or Command) Tool\n by Roman Fuks, Novosibirsk, Russia\n Version 1.1 \"Angara-A5\", 04-2024.\n\n This program is freeware for personal use only.\n\n Special thanks:\n  to some M.\n  to my friends Vadim and Rostislav\n  to joljaycups for help with \"message\" function\n  to the people who haven't left my \"The Camp\" server in two years\n"; }
#
MY_PATH="$(dirname -- "${BASH_SOURCE[0]}")"	# relative
MY_PATH="$(cd -- "$MY_PATH" && pwd)"		# absolutized and normalized
[ -z "$MY_PATH" ] && { echo -e "[PZCT]_$(date +%H:%M:%S): Directory $MY_PATH is not accessible for some reason."; exit 0; }
#
PIDFILE="$MY_PATH/pzct.pid"
trap "rm -f $PIDFILE" 1 2 8 9 13 15 20 23 
#
checkperms() { # function
local PERMS=$1
local TARGET=$2
for ((chpcount=0; chpcount<${#PERMS}; chpcount++)); do
	case "${PERMS:$chpcount:1}" in
		e) [ -e "$TARGET" ] || { echo "[PZCT]_$(date +%H:%M:%S): $TARGET not exists."; return 1; } ;;
		r) [ -r "$TARGET" ] || { echo "[PZCT]_$(date +%H:%M:%S): $TARGET is not readable."; return 1; } ;;
		w) [ -w "$TARGET" ] || { echo "[PZCT]_$(date +%H:%M:%S): $TARGET is not writable."; return 1; } ;;
		x) [ -x "$TARGET" ] || { echo "[PZCT]_$(date +%H:%M:%S): $TARGET is not executable."; return 1; } ;;
		*) { echo "[PZCT]_$(date +%H:%M:%S): Unknown argument ${PERMS:$chpcount:1}"; return 1; } ;;
	esac
done
} # end of checkperms
# usage: checkperms erwx "$TARGET" || return
#
checkperms er $(echo "$MY_PATH") || return
checkperms erx "$MY_PATH/pzct.sh" || return
checkperms er "$MY_PATH/pzct.conf" || return
#echo -e "Script:    $MY_PATH/pzct.sh\nConf file: $MY_PATH/pzct.conf" # verbose mode
source "$MY_PATH/pzct.conf"
#
log() { local DEFAULT=60; tail --lines ${1-$DEFAULT} -f "$Zomboid_DIR/server-console.txt"; }	#usable but rework is needed
#
pid() { # function
	PID=$(pgrep --full "ProjectZomboid64")
	if [ -z $PID ]; then
		echo -e "[PZCT]_$(date +%H:%M:%S): Seems the server isn't running."
		return 1
	else
		echo "[PZCT]_$(date +%H:%M:%S): Seems the server is running with PID $PID."
	fi
} # end of pid
#
backup_server-console() { # function 
checkperms erw "$Zomboid_DIR/server-console.txt" || return
checkperms ew "$pzbackup_DIR" || return
if [ -s "$Zomboid_DIR/server-console.txt" ]; then
	cp -v "$Zomboid_DIR/server-console.txt" "$pzbackup_DIR/server-console_$(date +%F-%H:%M).txt"
	wait
	cat /dev/null > "$Zomboid_DIR/server-console.txt"
fi
} # end of backup_server-console
#
function_kill() { # function
pid
if [ $? -eq 0 ]; then
	PID=$(pgrep --full "ProjectZomboid64")
	killtimer=0
	kill -9 $PID &>/dev/null
	while $(kill -0 $PID &>/dev/null); do
		sleep 1
		killtimer=$(( $killtimer + 1 ))
	done
	echo "[PZCT]_$(date +%H:%M:%S): Process with PID $PID killed successfully in $killtimer seconds."	#this command was added just for clarity
	backup_server-console &>/dev/null
fi
} # end of kill
#
#paranoid() {
#checkperms erw "$Zomboid_DIR/server-console.txt" || return
#} # end of paranoid
#
message() { # function
checkperms ex "$RCON" || return
checkperms er "$RCONYAML" || return
pid &>/dev/null
if [ $? -eq 0 ]; then  
	local MESSAGE=$(echo $* | cut -d" " -f2-) # it works
	#local MESSAGE=$(echo $* | sed -E 's/--m(essage)?//') # it works
	#local MESSAGE=$(echo $* | sed 's/^[^ ]* //') # also works but not tested
	#echo "$MESSAGE"
	echo -e \'servermsg \" $MESSAGE\"\' | xargs "$RCON" -c "$RCONYAML" &>/dev/null	#Thanks again joljaycups
	#[ $PARANOID = 1 ] && paranoid
fi
} # end of message
#
players() { # function
checkperms ex "$RCON" || return
checkperms er "$RCONYAML" || return
pid &>/dev/null
if [ $? -eq 0 ]; then
	"$RCON" -c "$RCONYAML" players
	#[ $PARANOID = 1 ] && paranoid
fi
} # end of players
#
thunder() { # function	# I love thunder sounds, and I will make everyone love it.
checkperms ex "$RCON" || return
checkperms er "$RCONYAML" || return
pid &>/dev/null
if [ $? -eq 0 ]; then
	list_players=$(players)
	mapfile -t array < <(echo "$list_players" | tail -n +2 | sed 's/^.*-//')
	#echo ${array[@]}						# Actually, when you run "thunder username" from command line, it doesn't sound only for the specified player, but for everyone.
	if [ ${#array[@]} -gt 0 ]; then					# However, there is no "all" option for rcon, and you have to specify an username. Therefore, we pick a random one.
		#echo ${#array[@]}					# It won't work if server is empty, because there's no usernames. I made a haiku about it:
		random_index=$(( $RANDOM % ${#array[@]} ))		# "Thunder sounds for all,
		random_element=${array[$random_index]}			# But only if someone hear.
		"$RCON" -c "$RCONYAML" "thunder $random_element"	# How poetic this is!"
		#[ $PARANOID = 1 ] && paranoid
	fi
fi
} # end of thunder
#
serverupdate() { # function
[ -e $PIDFILE ] && { echo "Seems pzct is already running with PID $(cat $PIDFILE)"; exit 0; }
echo $$ > $PIDFILE
#
checkperms erw "$pzserver_DIR" || return
checkperms erw "$pzbackup_DIR" || return
checkperms er "$steamcmd_DIR" || return
checkperms ex "$steamcmd_DIR/steamcmd.sh" || return
pid
if [ -z $PID ]; then
	cp -v "$pzserver_DIR"/ProjectZomboid64.json "$pzbackup_DIR" && \
	"$steamcmd_DIR/steamcmd.sh" +force_install_dir "$pzserver_DIR" +login anonymous +app_update 380870 validate +quit && \
	cp -v "$pzbackup_DIR"/ProjectZomboid64.json "$pzserver_DIR" && \
	rm -f $PIDFILE
fi
} # end of serverupdate
#
# the serious shit starts below
#
quit() { # function
[ -e $PIDFILE ] && { echo "Seems pzct is already running with PID $(cat $PIDFILE)"; exit 0; }
echo $$ > $PIDFILE
#
checkperms ex "$RCON" || return
checkperms er "$RCONYAML" || return
pid
if [ $? -eq 0 ]; then
	if [ -f "$MY_PATH/update.monitor" ]; then
		rm -f "$MY_PATH/update.monitor"
	fi
# rework is needed
	if [ "$#" -eq 1 -o "$2" = "" ]; then
		#arrays
        	arr_sec=($DELAY1 $DELAY2)
### INGAME NOTIFICATIONS BELOW
		arr_msg=(
			"Server restarts in $DELAY1 seconds. Take a safe position."
			"Server restarts in $DELAY2 seconds. Reconnect in 3 minutes."
			)
		#end of arrays
#
		echo -e "[PZCT]_$(date +%H:%M:%S): The quit command starts executing."
		for qcount in ${!arr_sec[@]}; do
			thunder
			message ${arr_msg[$qcount]}
			sleep ${arr_sec[$qcount]}
		done &
		for ((concount=$DELAY1; concount>=0; concount--)); do echo -ne "[PZCT]_$(date +%H:%M:%S): Performing quit in $concount seconds, press Ctrl+C to abort.\r"; sleep 1; done
#
	elif [ "$#" -ge 2 -a "$2" != "-now" ]; then
		echo "[PZCT]_$(date +%H:%M:%S): Unknown parameter \""$2"\". Operation aborted."
		exit 0
	elif [ "$2" = "-now" ]; then
		echo "[PZCT]_$(date +%H:%M:%S): With -now option, the server will be stopped immediately without any notifications."
	fi
# end of rework is needed
	"$RCON" -c "$RCONYAML" quit &>/dev/null && echo "[PZCT]_$(date +%H:%M:%S): 'Quit' command has been sent."
	#[ $PARANOID = 1 ] && paranoid
	while $(kill -0 $PID &>/dev/null); do
		sleep 1
	done
	echo -e "[PZCT]_$(date +%H:%M:%S): The server has been stopped."
	backup_server-console &>/dev/null
	rm -f $PIDFILE
fi
} # end of quit
#
backup() { # function
[ -e $PIDFILE ] && { echo "Seems pzct is already running with PID $(cat $PIDFILE)"; exit 0; }
echo $$ > $PIDFILE
#
if [ ! -e "$pzbackup_DIR" ]; then
	mkdir "$pzbackup_DIR"
fi
#
	backup_dirs() { # function
	if [ -n "$(which pv 2>/dev/null)" -a -n "$(which pbzip2 2>/dev/null)" ]; then
		#Advanced option for the CLI, shows archiving progress, takes less time due to the use of pbzip2. Requires pbzip2 and pv installed.
		EXTENSION=bz2
		tar cf - "$1" -P | pv -s $(du -sb "$1" | awk '{print $1}') | pbzip2 > "$2"
	else
		EXTENSION=gz
		tar -cvzf "$2" "$1"	#it's highly likely to work for everyone
	fi
	} # end of backup_dirs
#
checkperms er "$Zomboid_DIR" || return
checkperms erw "$pzbackup_DIR" || return
pid >/dev/null
if [ -z $PID ]; then
	backup_server-console &>/dev/null
	backup_dirs "" "" &>/dev/null # some workaround
	backup_dirs "$Zomboid_DIR/Logs" "$pzbackup_DIR/Logs_$(date +%F-%H:%M).tar.$EXTENSION" && \
	rm -vrf "$Zomboid_DIR/Logs/*" && \
	backup_dirs "$Zomboid_DIR" "$pzbackup_DIR/Zomboid_backup_$(date +%F-%H:%M).tar.$EXTENSION" && \
	echo -e "[PZCT]_$(date +%H:%M:%S): The backup was done."
	rm -f $PIDFILE
fi
} # end of backup
#
function_start() { # function
[ -e $PIDFILE ] && { echo "Seems pzct is already running with PID $(cat $PIDFILE)"; exit 0; }
echo $$ > $PIDFILE
#
checkperms er "$pzserver_DIR" || return
checkperms ex "$pzserver_DIR/start-server.sh" || return
pid &>/dev/null
if [ -z $PID ]; then
	if [ $VAR_FILES -eq 1 ]; then
		checkperms er "$pzbackup_DIR" || return
		checkperms erw "$Zomboid_DIR" || return
		echo -e "[PZCT]_$(date +%H:%M:%S): service option VAR_FILES = $VAR_FILES"
		cp -v "$pzbackup_DIR/ProjectZomboid64.json" "$pzserver_DIR" && \
		cp -v -t "$Zomboid_DIR/Server" "$pzbackup_DIR/servertest_SandboxVars.lua" "$pzbackup_DIR/servertest.ini"
	else
		sleep 1
	fi	
	backup_server-console &>/dev/null
	echo -e "[PZCT]_$(date +%H:%M:%S): Starting the server."
	nohup $pzserver_DIR/start-server.sh &>/dev/null &
	disown $!
	while [ -z $PID ]; do 
		pid &>/dev/null
	done
	echo -e "[PZCT]_$(date +%H:%M:%S): Server started with PID $PID"
	touch "$MY_PATH/update.monitor"
	rm -f $PIDFILE
fi
} # end of function_start
#
restart() { # function
pid &>/dev/null
if [ $? -eq 0 ]; then
	quit "quit" || return
	backup || return
	function_start || return
fi
} # end of restart
#
checkmods() { # function
[ -e $PIDFILE ] && { echo "Seems pzct is already running with PID $(cat $PIDFILE)"; exit 0; }
echo $$ > $PIDFILE
#
checkperms ex "$RCON" || return
checkperms er "$RCONYAML" || return
checkperms er "$Zomboid_DIR" || return
checkperms er "$Zomboid_DIR/server-console.txt" || return
pid &>/dev/null
if [ $? -eq 0 ]; then
	if [ -f "$MY_PATH/update.monitor" ]; then
		cat /dev/null > "$MY_PATH/update.monitor"
		# the easiest and the same time effective check is
		$RCON -c $RCONYAML checkModsNeedUpdate &>/dev/null & sleep 1 # need to adjust sleep N if not working correctly
		tail -n 5 "$Zomboid_DIR/server-console.txt" > "$MY_PATH/update.monitor" # need to adjust -n option if not working correctly
		local VARUPDMON=$(cat "$MY_PATH/update.monitor")
		#echo "$VARUPDMON"
		case "$VARUPDMON" in
			*"CheckModsNeedUpdate: Mods need update"*)
				local chmcount=0
				while [ $chmcount -ge 10 ]; do
					echo -ne "[PZCT]_$(date +%H:%M:%S): Mods need update. Performing restart in $chmcount seconds, press Ctrl+C to abort.\r"
					((chmcount--))
					sleep 1; done;
				echo -e "\n"
				rm -f "$MY_PATH/update.monitor"
				#[ $PARANOID = 1 ] && paranoid
				rm -f "$PIDFILE"
				restart
				;;
			*"CheckModsNeedUpdate: Mods updated"*)
				echo -e "[PZCT]_$(date +%H:%M:%S): Mods updated. Nothing to do."
				rm -f "$PIDFILE"
				#[ $PARANOID = 1 ] && paranoid
				;;
		esac
	else
	# File "$MY_PATH/update.monitor" doesn't exist.
	# According to the script logic, this can be only if quit or start is in progress.
		echo -e "[PZCT]_$(date +%H:%M:%S): File $MY_PATH/update.monitor doesn't exist.\n In some cases, checking for updates may be suspended.\n If server is running normally, try \"touch ${MY_PATH}/update.monitor\"\n Operation aborted."
	fi
fi
} # end of checkmods
#
function_help() { # function
echo -e "  usage: pzct --command
    --b or --backup		perform a backup
    --chm or --checkmods	check if mods need update
    --help			show this message
    --kill			immediately terminate the server process (without using rcon)
    --l N or --log N		display the last N lines of server-console.txt
				and then monitors the file (25 lines by default)

    --m text or --message text	displays the message \"text\" in chat and in the middle of the screen
    --p or --players		list all connected players (if any)
    --pid			just show PID of the server process (if it's running)
    --q or --quit		send the \"quit\" command to the server using rcon
				with chat notifications and 120 seconds delay

    --q -now or --quit -now	send the same command immediately without notifications
    --r or --restart		sequentially execute quit, backup and start
				done mostly for cron

    --s or --start		run the start-server.sh script in the background
    --serverupdate		update the server application with steamcmd.sh
    --t or --thunder		thunder sounds for everyone
    --version			show the version of pzct\n";
} # end of help
#
# menu section
case $1 in
 --b | --backup) backup;;
 --chm | --checkmods) checkmods;;
 --help) function_help;;
 --kill) function_kill;;
 --l | --log) log $2;;
 --m | --message) message $*;;
 --p | --players) players;;
 --pid) pid;;
 --q | --quit) quit $@;;
 --r | --restart) restart;;
 --s | --start) function_start;;
 --serverupdate) serverupdate;;
 --t | --thunder) thunder;;
 --version) function_version;;
 *) echo -e "  pzct: You must specify one of the commands.\n  Run \"pzct --help\" to view the commands list." && exit 0; ;;
esac
[ -e $PIDFILE ] && rm -f $PIDFILE;
exit 0