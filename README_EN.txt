visit https://steamcommunity.com/sharedfiles/filedetails/?id=3217318300

Workshop ID: 3217318300
Mod ID: pzct

***

Greetings!
Meet pzct, which stands for Project Zomboid Console (or Command) Tool
pzct greatly simplifies the management of the LINUX PZ server, and most importantly,

pzct automatically restarts the server process if a mod update is required.

Below is the manual, following which you can quickly and easily start using pzct
with NO Linux experience.

If you are not beginner in Linux, you will probably figure it out yourself.

***

0. Preparation
For a better understanding, run the "echo $HOME" command.
You will see a string like "/home/some_name" or "/root" (if you are root).
$HOME is the variable, that contains path to the user's home directory.
If you see $HOME in a command, you don't have to change it.
If you see "/your/path/to/" or "/some/path/to/" or "/path/to" in this text
- you HAVE to change it to your own correct value.

***

Let's start. It is assumed that:
1. you already have steamcmd installed
2. you have already run the command in one line
"/some/path/to/steamcmd/steamcmd.sh +force_install_dir /your/path/to/pzserver +login anonymous +app_update 380870 validate +quit"
3. and that you can start the PZ server by running start-server.sh

If you NOT have steamcmd installed and so on, then search the Web for instructions on how to install it.
Once steamcmd is installed, you can try running the command from step 2
and then start the server by running /your/path/to/pzserver/start-server.sh

Also make sure that you already have wget, tar, mc, crond and crontab utilites on your system.
To do this, run the following commands:
"which wget", "which tar", "which mcedit", "which crond", "which crontab"
If you see answers like "/usr/bin/wget", "/usr/bin/tar", "/usr/bin/mcedit", "/usr/sbin/crond", "/usr/bin/crontab", you can go further.
If the answers are different and probably contain "no wget", "no tar", "no mcedit" and so on - you cannot go further.
You need to install the missing programs for your system. Look online for information on how to do this, or contact my Discord server.

***

1. Creating directories
Set up the pzct directory in your home folder and access it:
mkdir "$HOME"/pzct
mkdir "$HOME"/pzct/pzbackup
You should remain in "$HOME/pzct" during the manual. Run:
cd "$HOME"/pzct

***

2. Ungzipping two archives
Locate and copy pzct.tar.gz from mod directory to $HOME/pzct
Just run in one line
cp -v /your/path/to/pzserver/steamapps/workshop/content/108600/3217318300/mods/pzct/media/pzct*.tar.gz "$HOME"/pzct

Or download pzct:
wget https://github.com/vsnegupal/pzct/releases/download/v1.1/pzct-1.1-linux.tar.gz
(visit https://github.com/vsnegupal/pzct to get actual download link if this one is not available)

Download rcon:
wget https://github.com/gorcon/rcon-cli/releases/download/v0.10.3/rcon-0.10.3-amd64_linux.tar.gz
(visit https://github.com/gorcon/rcon-cli to get actual download link if this one is not available)

Extract the archives:
tar xvf rcon*.tar.gz --strip-components=1
tar xvf pzct*.tar.gz --strip-components=1

Optionally, you may delete some files:
rm -v ABOUT* CHANGELOG.md LICENSE rcon*.tar.gz pzct*.tar.gz
After that, the "$HOME/pzct" directory MUST contain the "pzbackup" directory and the files "pzct.conf", "pzct.sh", "rcon" and "rcon.yaml"

***

3. Filling out the configs
Open the pzct.conf file:
mcedit "$HOME"/pzct.conf

Specify the paths to the pzserver and Zomboid directories.
You should type a similar path:

pzserver_DIR=/your/path/to/pzserver
Zomboid_DIR=/your/path/to/Zomboid

Also you may specify the path to the steamcmd directory in the steamcmd_DIR line if you want to update the server using pzct.
Save and close the file pzct.conf

Open the rcon.yaml file:
mcedit "$HOME"/rcon.yaml

Fill in the address field in the format "host:port"

For beginners there's no other options but using pzct in the same OS they have the server running.
Then the host parameter should be specified as "localhost" or "127.0.0.1"

The port parameter is what is written in the
/your/path/to/Zomboid/Server/servertest.ini
file in the "RCONPort" parameter. Its default value is 27015.

Fill in the password field. It is specified in the same servertest.ini file in the "RCONPassword" parameter.
And set "log" empty, or rcon will place log file everywhere you will run commands.

Save and close the rcon.yaml
You should get a similar result:
default:
  address: "127.0.0.1:27015"
  password: "your_password"
  log: ""
  type: "" # rcon, telnet, web.
  timeout: "10s"

***

4. Creating cron jobs
Let's assume that your username on the system is "user"
Then, if you execute "echo $HOME", you will see "/home/user"
Or, if you are root, there will be "/root"

Now, to create a job for cron that will check the mod updates every 5 minutes, run:
(crontab -l ; echo "*/5 * * * * /home/user/pzct/pzct.sh --checkmods 2>&1") | crontab -
I also recommend creating a job that will do a daily backup. Let's say it should run at 10:05AM:
(crontab -l ; echo "5 10 * * * /home/user/pzct/pzct.sh --restart 2>&1") | crontab -
Or at 4:20PM:
(crontab -l ; echo "20 16 * * * /home/user/pzct/pzct.sh --restart 2>&1") | crontab -

***

5. Interactive Mode

pzct can be used in interactive mode. To do this, run:

echo "alias pzct=$HOME/pzct/pzct.sh" >> "$HOME"/.bashrc
bash

And you can just type "pzct --command" at the console.
I recommend starting with "pzct --help"

Or without alias, you have to specify which script you're executing each time:
"$HOME/pzct/pzct.sh --help" for example "/home/user/pzct/pzct.sh --help"

6. What's next

There will probably be a few mod updates, but they will be minor improvements, fixings and testings.
There will be no major revisions in the near future.

If you want to participate in fixing the script, or added functionality suitable for widespread use, then let's cooperate.
I'm also learning how to use Github. I heard it's possible to do it there.

Read the "most important section" at the very bottom.

***

42. Short Q&A
Q: Why not use "Udderly Up To Date" or pz-server-tools?
A: "Udderly Up To Date" is made in Lua. I don't understand Lua yet. But many people understand shell scripts.
pz-server-tools is too complicated. We don't need Python just to restart the process.
Q: Add this, rework that.
A: Just give me time. If you can help, you may help.
Q: My data was corrupted in some way.
A: Show the specific command that led to this. Never use any commands people tell you in the comments. You've been warned.
Q: I use Windows.
A: This mod in NOT for you, it's for Linux only. Also Windows must die.

***

99. Subscribe to vsnegupal
Join my server in Discord:
https://discord.gg/Q5efMMuCfQ
visit https://github.com/vsnegupal/pzct

To see pzct in action, join my PZ server:
IP: 5.128.212.85
PORT: 16261
SERVER PASSWORD: leave the field empty
or go to https://wargm.ru/server/66326/connect

The server is running 24/7, if you like the settings then stay to play with me and my friends.
If you like pzct then please vote for my server on the link:
https://wargm.ru/server/66326/votes

If you like the mod, you may also https://www.buymeacoffee.com/vsnegupal

***

The most important section:
NO MODPACKING
NO REUPLOADING
private rework is allowed but no further distribution

***

Workshop ID: 3217318300
Mod ID: pzct