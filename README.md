Greetings!<p>
Let me introduce you to `pzct`, which stands for _Project Zomboid Console (or Command) Tool_  
`pzct` greatly simplifies the management of the **LINUX** Project Zomboid server, and most importantly, `automatically restarts the server process if a mod update is required.`<p>
The following is the order of operations, following which you can quickly and easily start using `pzct` with no Linux experience.  
If you are not beginner in Linux, you will probably figure out how to integrate `pzct` into your system yourself.<p>
# 0. Preparation<p>
It is assumed that:  
1. you already have `steamcmd` installed  
2. you have already run the command `/some/path/to/steamcmd/steamcmd.sh +force_install_dir /some/path/to/pzserver +login anonymous +app_update 380870 validate +quit &&`  
3. and that you can start the Project Zomboid server by running the script `start-server.sh`<p>
<!-- -->
If you `NOT have steamcmd` and so on installed, then ~contact your IT departament~ search the Web for instructions on how to install it.  
Once `steamcmd` is installed, you can try running the command from step 2 and start the server by running the `/path/to/pzserver/start-server.sh` script<p>
Also make sure that you already have the `wget`, `tar`, `mc`, `crond` and `crontab` programs on your system. To do this, run the following commands:  
`which wget`, `which tar`, `which mcedit`, `which crond`, `which crontab`<p>
- If you see answers like `/usr/bin/wget`, `/usr/bin/tar`, `/usr/bin/mcedit`, `/usr/sbin/crond`, `/usr/bin/crontab`, you can continue.  
- If the answers are different from these and probably contain `no wget`, `no tar`, `no mcedit` and so on - you cannot continue.  
You need to install the missing programs for your system. Look online for information on how to do this, or contact my Discord server.<p>
#### Optional:  
For a better understanding, run the `echo $HOME` command  
You will see a string like `/home/some_name` or `/root` (if you are *root*).  
This is the path to the home directory of the user on whose behalf you are executing all subsequent commands.<p>
# 1. Creating directories<p>
Create a `pzct` directory in your home directory and navigate to it:  
`mkdir $HOME/pzct`  
`cd $HOME/pzct`<p>
Further operations take place without changing the directory, meaning you should remain in `$HOME/pzct`<p>
Also create a directory to store backups:  
`mkdir $HOME/pzct/pzbackup`<p>
# 2. Downloading and unzipping programs<p>
Download `rcon` and `pzct`:  
`wget https://github.com/gorcon/rcon-cli/releases/download/v0.10.3/rcon-0.10.3-amd64_linux.tar.gz`  
`wget https://github.com/vsnegupal/pzct/releases/download/v1.1/pzct-1.1-linux.tar.gz`<p>
Extract the archives:  
`tar xvf rcon*.tar.gz --strip-components=1`  
`tar xvf pzct*.tar.gz --strip-components=1`<p>
### Optional:<p>
- You can read _ABOUT_EN.txt_ or _ABOUT_RU.txt_ where I described the reasons and process for developing `pzct`  
- You can delete the files ABOUT_EN.txt, ABOUT_RU.txt, CHANGELOG.md, LICENSE, pzct.tar.gz and rcon-0.10.3-amd64_linux.tar.gz:  
`rm -v ABOUT_EN.txt ABOUT_RU.txt ABOUT_RU.txt CHANGELOG.md LICENSE rcon*.tar.gz pzct*.tar.gz`<p>
<!-- -->
After that, the `$HOME/pzct` directory should contain the `pzbackup` directory and the `pzct.conf`, `pzct.sh`, `rcon` and `rcon.yaml` files.<p>
# 3. Filling out the configs<p>
Open the `pzct.conf` file:  
`mcedit pzct.conf`<p>
Specify the paths to the `pzserver` and `Zomboid` directories.  
You should get a similar path:  
`pzserver_DIR=/your/path/to/pzserver`  
`Zomboid_DIR=/your/path/to/Zomboid`<p>
Similarly, you can specify the path to the `steamcmd` directory in the `steamcmd_DIR` line if you want to update the server using pzct.<p>
Save and close the file `pzct.conf`<p>
Open the `rcon.yaml` file:  
`mcedit rcon.yaml`<p>
Fill in the `address` field in the format `host:port`<p>
I assume you will be using pzct wherever you have the server running.  
Then the `host` parameter should be specified as `localhost` or `127.0.0.1`<p>
The `port` parameter is what is written in the `/your/path/to/Zomboid/Server/servertest.ini` file in the `RCONPort` parameter.  
Its default value is `27015`<p>
Fill in the `password` field. You must enter what is specified in the `/your/path/to/Zomboid/Server/servertest.ini` file in the `RCONPassword` parameter.<p>
Save and close the `rcon.yaml` file.<p>
You should get a similar result:  
`default:`<br>
` address: "127.0.0.1:27015"`<br>
` password: "your_password"`<br>
` log: "rcon-default.log"`<br>
` type: "" # rcon, telnet, web.`<br>
` timeout: "10s"`<p>
# 4. Creating `cron` jobs<p>
Let's assume that your username on the system is `user`  
Then, if you execute:  
`echo $HOME`  
you will see `/home/user`<p>
Now, to create a job for `cron` that will check the status of mod update every 5 minutes using `pzct`, run the command:  
`(crontab -l ; echo "*/5 * * * * /home/user/pzct/pzct.sh checkmods 2>&1") | crontab -`<p>
I also recommend creating a job that will do a daily backup of the server once a day. Let's say it should run at 10:05AM:  
`(crontab -l ; echo "5 10 * * * /home/user/pzct/pzct.sh restart 2>&1") | crontab -`<p>
Or at 4:20PM:  
`(crontab -l ; echo "20 16 * * * /home/user/pzct/pzct.sh restart 2>&1") | crontab -`<p>
# 5. Interactive Mode<p>
`pzct` can be used in interactive mode. To do this:<p>
If you are _root_, first run the commands:  
`ln -s $HOME/pzct/pzct/pzct.sh /usr/local/bin/pzct`  
`ln -s $HOME/pzct/pzct.conf /usr/local/bin/pzct.conf`  
`ln -s $HOME/pzct/rcon /usr/local/bin/rcon`  
`ln -s $HOME/pzct/rcon.yaml /usr/local/bin/rcon.yaml`<p>
If you are not _root_, but you have _sudo_ (`which sudo` returns a `/usr/bin/sudo` response) and the appropriate privileges, then execute:  
`sudo ln -s $HOME/pzct/pzct.sh /usr/local/bin/pzct`  
`sudo ln -s $HOME/pzct/pzct.conf /usr/local/bin/pzct.conf`  
`sudo ln -s $HOME/pzct/rcon /usr/local/bin/rcon`  
`sudo ln -s $HOME/pzct/rcon.yaml /usr/local/bin/rcon.yaml`<p>
After that:  
`bash`<p>
After that you can just write `pzct command` at the command line, I recommend starting with `pzct help`<p>
If you're not _root_ and can't get _sudo_ privileges, you'll have to specify which script you're accessing each time:  
`$HOME/pzct/pzct/pzct.sh command`  
or for example  
`/home/user/pzct/pzct/pzct.sh command`<p>
In any case, you can see the full list of commands with descriptions by executing:  
`$HOME/pzct/pzct/pzct.sh help`  
or for example  
`/home/user/pzct/pzct/pzct.sh help`<p>
# 99. Subscribe to vsnegupie<p>
You can join my server in Discord:  
https://discord.gg/QV8x6cM99p<p>
To see `pzct` in action, join my PZ server:  
`IP: 5.128.212.85`  
`PORT: 16261`  
`SERVER PASSWORD: empty field`  
  
or go to https://wargm.ru/server/66326/connect<p>
The server is running 24/7, if you like the settings then stay to play with me and my friends.<p>
If you like `pzct` then please vote for my server on the link:  
https://wargm.ru/server/66326/votes
