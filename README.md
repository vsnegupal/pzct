Всех приветствую! Позвольте представить вам **pzct**, the tiny Project Zomboid Console (or Command) Tool, allows you to run some simple operations managing a dedicated server, and, more importantly, automatically update the mods on the server.
Ниже представлен порядок действий, выполнив которые, вы сможете легко и быстро начать пользоваться **pzct**, не имея опыта в использовании Linux. Если вы не новичок в Linux, то наверняка сами поймете, как интегрировать **pzct** в вашу систему.

#0. Подготовка

Предполагается, что:
1. у вас уже установлен steamcmd
2. что вы уже выполнили команду "/some/path/to/steamcmd/steamcmd.sh +force_install_dir /some/path/to/pzserver +login anonymous +app_update 380870 validate +quit &&" 
3. и что вы можете запустить сервер Project Zomboid, выполнив скрипт start-server.sh

Если у вас не установлен steamcmd, то обратитесь к программисту в Интернет для получения инструкций по его установке.
После установки steamcmd можете попробовать выполнить команду из п.2 и запустить сервер, выполнив скрипт /path/to/pzserver/start-server.sh

Также убедитесь, что у вас в системе уже есть программы **wget**, **tar**, **mc**, **crond** и **crontab**. Для этого выполните следующие команды:
>which wget
>which tar
>which mcedit
>which crond
>which crontab

Если вы видите ответы вроде "/usr/bin/wget", "/usr/bin/tar", "/usr/bin/mcedit", "/usr/sbin/crond", "/usr/bin/crontab" - вы можете продолжить.
Если ответы отличаются от этих и, вероятно, содержат "no wget", "no tar", "no mcedit" и так далее - вы не можете продолжить.
Вам нужно установить отсутствующие программы для вашей системы. Поищите информацию в Интернете о том, как это сделать, или обратитесь в мой сервер Discord.

Дополнительно:

Для лучшего понимания, выполните команду >echo $HOME
Вы увидите строчку навроде "/home/some_name" или "/root" (если вы root). Это путь к домашнему каталогу пользователя, от имени которого вы выполняете все последующие команды.

#1. Создание каталогов

Создайте каталог pzct в вашем домашнем каталоге и перейдите в него:
mkdir $HOME/pzct
cd $HOME/pzct
Дальнейшие операции происходят без смены каталога, то есть вы должны оставаться в $HOME/pzct.
Также создайте каталог для хранения бэкапов:
mkdir $HOME/pzct/pzbackup

#2. Скачивание и распаковка программ

Скачайте rcon и pzct:
wget https://github.com/gorcon/rcon-cli/releases/download/v0.10.3/rcon-0.10.3-amd64_linux.tar.gz
wget https://github.com/vsnegupal/pzct/releases/download/v1.1/pzct.tar.gz
Распакуйте архивы:
tar xvz rcon*.tar.gz --strip-components=1
tar xvz pzct*.tar.gz --strip-components=1

Дополнительно:
Можете прочитать ABOUT_EN.txt или ABOUT_RU.txt, где я описал причины и процесс разработки pzct.
Можете удалить файлы ABOUT_EN.txt, ABOUT_RU.txt, CHANGELOG.md, LICENSE, pzct.tar.gz и rcon-0.10.3-amd64_linux.tar.gz :
rm -v ABOUT_EN.txt ABOUT_RU.txt CHANGELOG.md LICENSE rcon*.tar.gz pzct*.tar.gz
После этого в каталоге $HOME/pzct должен присутствовать каталог pzbackup и файлы pzct.conf, pzct.sh, rcon и rcon.yaml

#3. Заполнение конфигов

Откройте файл pzct.conf:
mcedit pzct.conf
Укажите пути к каталогам pzserver и Zomboid.
У вас должно получиться похожим образом:

pzserver_DIR=/your/path/to/pzserver
Zomboid_DIR=/your/path/to/Zomboid

Аналогично можете указать путь к каталогу steamcmd в строчке steamcmd_DIR, если хотите обновлять сервер при помощи pzct.
Сохраните и закройте файл pzct.conf

Откройте файл rcon.yaml:
mcedit rcon.yaml

Заполните поле address в формате "host:port".
Я предполагаю, что вы будете использовать pzct там же, где у вас запущен сервер.
Тогда параметр "host" следует указать как "localhost" или "127.0.0.1"
Параметр "port" - это то, что написано в файле /your/path/to/Zomboid/Server/servertest.ini в параметре RCONPort. По умолчанию его значение 27015.
Заполните поле "password". Нужно вписать то, что указано в файле /your/path/to/Zomboid/Server/servertest.ini в параметре RCONPassword.

Сохраните и закройте файл rcon.yaml
У вас должно получиться похожим образом:

default:
  address: "127.0.0.1:27015"
  password: "your_password"
  log: "rcon-default.log"
  type: "" # rcon, telnet, web.
  timeout: "10s"

#4. Создание заданий cron

Допустим, что имя вашего пользователя в системе - "user".
Тогда, если вы выполните:
echo $HOME
то увидите "/home/user"

Теперь, чтобы создать задание для cron, которое будет проверять статус обновления модов каждые 5 минут при помощи pzct, выполните команду:
(crontab -l ; echo "*/5 * * * * /home/user/pzct/pzct.sh checkmods 2>&1") | crontab -

Также я рекомендую создать задание, которое будет 1 раз в сутки делать ежедневный бэкап сервера. Допустим, оно должно запускаться в 10:05AM:
(crontab -l ; echo "5 10 * * * /home/user/pzct/pzct.sh restart 2>&1") | crontab -

#5. Интерактивный режим

**pzct** можно использовать в интерактивном режиме. Для этого выполняйте команды вида:

Если вы root, то сначала выполните команды:
>ln -s $HOME/pzct/pzct.sh /usr/local/bin/pzct
>ln -s $HOME/pzct/pzct.conf /usr/local/bin/pzct.conf
>ln -s $HOME/pzct/rcon /usr/local/bin/rcon
>ln -s $HOME/pzct/rcon.yaml /usr/local/bin/rcon.yaml

Если вы не root, но у вас есть sudo ("which sudo" возвращает ответ "/usr/bin/sudo") и вы можете ее выполнять, то выполните:
>sudo ln -s $HOME/pzct/pzct.sh /usr/local/bin/pzct
>sudo ln -s $HOME/pzct/pzct.conf /usr/local/bin/pzct.conf
>sudo ln -s $HOME/pzct/rcon /usr/local/bin/rcon
>sudo ln -s $HOME/pzct/rcon.yaml /usr/local/bin/rcon.yaml

После этого:
>bash

После этого в командной строке можете просто писать **pzct command**, рекомендую начать с **pzct usage**

Если вы не root и не можете получить sudo привилегии, то придется каждый раз указывать, что вы обращаетесь к скрипту $HOME/pzct/pzct.sh 
>$HOME/pzct/pzct.sh command
Полный список команд с описанием можете посмотреть, выполнив:
>$HOME/pzct/pzct.sh usage
