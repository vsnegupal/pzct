  Hello everyone!
  In January 2022, I decided to start my own server for Project Zomboid.
The conditions allowed me to use a separate computer at home for this.
I was familiar with the GNU/Linux operating systems. So I decided that
the server would run on a Linux computer.
  As I managed the server, I realized that it was not easy at all.
The management was all about executing commands in the console. Different
actions required different commands. You had to either memorize these
commands or refer to a list of them. The commands had to be executed in
a specific sequence. It was also time-consuming.
  At that time, I knew how to write primitive scripts for the Unix shell.
I wrote some simple scripts, and started running them when I needed to.
It was easier to manage the server. But I still wasn't satisfied. Solving
simple problems allowed me to think about more complex ones. I came to the
conclusion that I wanted a single script that would do whatever I told it
to do. At the same time I got promoted at work. It became necessary for me
to be able to write more complex scripts. I realized that there was no better
learning opportunity for me. So I started building pzct.
  First, I repeated the basic mechanics that I had as separate scripts,
such as start, quit, and backup. I wrote a fairly simple, and I think successful,
check to see if a server process is running, allowing me to perform or
not perform actions on the server. The difficulty came in writing an
in-game notification function before stopping the server. With that, I was
helped by a person with the nickname joljaycups from Discord, for which
I thank him. After that, through a combination of functions, I was able
to get the restart option. This first key moment in the development allows
me to introduce the pzct utility to you.
  Initially, I only intended for personal use of the script. However, if
any of you would find it useful, you can use pzct as well. The main thing
I've tried to accomplish at the moment is to be able to create a cron job
to reboot the server at regular intervals. In this way I hope to solve
the problem when a player cannot connect to the server because of
an unupdated mod on the server. Of course, this is not very convenient, because
the mod update can happen shortly after another reboot. But for the most part,
it should be enough. In its current form it already allows to leave
the server running for a long time. In addition, I will continue to improve
the pzct utility, so in the future its functionality will be expanded.

  Note that for pzct to work, you need to have the rcon-cli program configured
on your system. You can download it by going to https://github.com/itzg/rcon-cli.
Since rcon-cli is not of my own design, we will not cover its configuration
at this time. However, it should be pretty easy.

  Once you have downloaded pzct.sh, open the file in an editor
and fix the values of the SERVDIR, ZDIR, LOGFILE, BAKDIR, CMDDIR, RCON and RCONYAML.
You can also find the line "INGAME NOTIFICATIONS BELOW", and in the two
lines after it, fix the notifications to your own.

  After that, check the operation of the pzct utility.
By fixing "/path/to" below to its own value:
  1. run the command "/path/to/pzct.sh quit" with the server running
- the server should shut down with a notification in the game.
  2. run the command "/path/to/pzct.sh backup"
- in the directory you specified in the variable BAKDIR,
file "bak.tar.gz" or "bak.tar.bz2" should appear.
  3. run the command "/path/to/pzct.sh start" - your server should start.
  4. run the command "/path/to/pzct.sh message test1 test2"
- you should see the text "test1 test2" in the game chat
and in the middle of the game window.

  If everything is OK, it means you can create a cron job to automatically
reboot the server. Run the command "crontab -e" and paste in a new line the text:
"0 0,8,16 * * * * * nohup /opt/pzbackup/pzct.sh restart &>/dev/null"
- if you want to have the server restarted daily at 12AM, 8AM and 4PM. Check the
Internet to find out how to work with cron on your system.

  This project is an educational project for me. There are bound to be aspects
of it that experienced people will find sub-optimal or incorrect. If you would
like to suggest a correction or your variation in the implementation of a particular
point, feel free to do so. Although I have achieved the minimum I had hoped for,
but I will continue to fix and improve the pzct utility in the future.

  You can contact me on Telegram: https://t.me/vsnegupal
  or by emailing me at vsnegupal@gmail.com (quick response is not guaranteed).

  Thank you for your attention!