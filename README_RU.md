Приветствую!<p>
Позвольте представить Вам `pzct`, что означает _Project Zomboid Console (or Command) Tool_.  
`pzct` значительно упрощает управление сервером Project Zomboid, а главное - `автоматически перезапускает сервер, если требуется обновление модов.`<p>
Ниже представлен порядок действий, выполнив которые, вы сможете легко и быстро начать пользоваться `pzct`, не имея опыта в использовании Linux.  
Если вы не новичок в Linux, то наверняка сами поймете, как интегрировать `pzct` в вашу систему.<p>
# 0. Подготовка<p>
Предполагается, что:  
1. у вас уже установлен `steamcmd`  
2. что вы уже выполнили команду `/some/path/to/steamcmd/steamcmd.sh +force_install_dir /some/path/to/pzserver +login anonymous +app_update 380870 validate +quit &&`  
3. и что вы можете запустить сервер Project Zomboid, выполнив скрипт `start-server.sh`<p>
<!-- -->
Если у вас `НЕ` установлен `steamcmd` и так далее, то обратитесь ~к программисту~ в Интернет для получения инструкций по его установке.  
После установки `steamcmd` можете попробовать выполнить команду из п.2 и запустить сервер, выполнив скрипт `/path/to/pzserver/start-server.sh`<p>
Также убедитесь, что у вас в системе уже есть программы `wget`, `tar`, `mc`, `crond` и `crontab`. Для этого выполните следующие команды:  
`which wget`, `which tar`, `which mcedit`, `which crond`, `which crontab`<p>
- Если вы видите ответы вроде `/usr/bin/wget`, `/usr/bin/tar`, `/usr/bin/mcedit`, `/usr/sbin/crond`, `/usr/bin/crontab` - вы можете продолжить.  
- Если ответы отличаются от этих и, вероятно, содержат `no wget`, `no tar`, `no mcedit` и так далее - вы не можете продолжить.  
Вам нужно установить отсутствующие программы для вашей системы. Поищите информацию в Интернете о том, как это сделать, или обратитесь в мой сервер Discord.<p>
### Дополнительно:  
Для лучшего понимания, выполните команду `echo $HOME`  
Вы увидите строчку навроде `/home/some_name` или `/root` (если вы *root*).  
Это путь к домашнему каталогу пользователя, от имени которого вы выполняете все последующие команды.<p>
# 1. Создание каталогов<p>
Создайте каталог `pzct` в вашем домашнем каталоге и перейдите в него:  
`mkdir $HOME/pzct`  
`cd $HOME/pzct`<p>
Дальнейшие операции происходят без смены каталога, то есть вы должны оставаться в `$HOME/pzct`<p>
Также создайте каталог для хранения бэкапов:  
`mkdir $HOME/pzct/pzbackup`<p>
# 2. Скачивание и распаковка программ<p>
Скачайте `rcon` и `pzct`:  
`wget https://github.com/gorcon/rcon-cli/releases/download/v0.10.3/rcon-0.10.3-amd64_linux.tar.gz`  
`wget https://github.com/vsnegupal/pzct/releases/download/v1.1/pzct.tar.gz`<p>
Распакуйте архивы:  
`tar xvz rcon*.tar.gz --strip-components=1`  
`tar xvz pzct*.tar.gz --strip-components=1`<p>
### Дополнительно:<p>
- Можете прочитать _ABOUT_EN.txt_ или _ABOUT_RU.txt_, где я описал причины и процесс разработки `pzct`  
- Можете удалить файлы ABOUT_EN.txt, ABOUT_RU.txt, CHANGELOG.md, LICENSE, pzct.tar.gz и rcon-0.10.3-amd64_linux.tar.gz:  
`rm -v ABOUT_EN.txt ABOUT_RU.txt CHANGELOG.md LICENSE rcon*.tar.gz pzct*.tar.gz`<p>
<!-- -->
После этого в каталоге `$HOME/pzct` должен присутствовать `каталог pzbackup` и файлы `pzct.conf`, `pzct.sh`, `rcon` и `rcon.yaml`<p>
# 3. Заполнение конфигов<p>
Откройте файл `pzct.conf`:  
`mcedit pzct.conf`<p>
Укажите пути к каталогам `pzserver` и `Zomboid`.  
У вас должно получиться похожим образом:  
`pzserver_DIR=/your/path/to/pzserver`  
`Zomboid_DIR=/your/path/to/Zomboid`<p>
Аналогично можете указать путь к каталогу `steamcmd` в строчке `steamcmd_DIR`, если хотите обновлять сервер при помощи pzct.<p>
Сохраните и закройте файл `pzct.conf`<p>
Откройте файл `rcon.yaml`:  
`mcedit rcon.yaml`<p>
Заполните поле `address` в формате `host:port`<p>
Я предполагаю, что вы будете использовать pzct там же, где у вас запущен сервер.  
Тогда параметр `host` следует указать как `localhost` или `127.0.0.1`<p>
Параметр `port` - это то, что написано в файле `/your/path/to/Zomboid/Server/servertest.ini` в параметре `RCONPort`.  
По умолчанию его значение `27015`<p>
Заполните поле `password`. Нужно вписать то, что указано в файле `/your/path/to/Zomboid/Server/servertest.ini` в параметре `RCONPassword`<p>
Сохраните и закройте файл `rcon.yaml`<p>
У вас должно получиться похожим образом:  
`default:`<br>
`  address: "127.0.0.1:27015"`<br>
`  password: "your_password"`<br>
`  log: "rcon-default.log"`<br>
`  type: "" # rcon, telnet, web.`<br>
`  timeout: "10s"`<p>
# 4. Создание заданий `cron`
Допустим, что имя вашего пользователя в системе - `user`.  
Тогда, если вы выполните:  
`echo $HOME`  
то увидите `/home/user`<p>
Теперь, чтобы создать задание для `cron`, которое будет проверять статус обновления модов каждые 5 минут при помощи `pzct`, выполните команду:  
`(crontab -l ; echo "*/5 * * * * /home/user/pzct/pzct.sh checkmods 2>&1") | crontab -`<p>
Также я рекомендую создать задание, которое будет 1 раз в сутки делать ежедневный бэкап сервера. Допустим, оно должно запускаться в 10:05:  
`(crontab -l ; echo "5 10 * * * /home/user/pzct/pzct.sh restart 2>&1") | crontab -`<p>
Или в 16:20:  
`(crontab -l ; echo "20 16 * * * /home/user/pzct/pzct.sh restart 2>&1") | crontab -`<p>
# 5. Интерактивный режим<p>
`pzct` можно использовать в интерактивном режиме. Для этого:<p>
Если вы _root_, то сначала выполните команды:  
`ln -s $HOME/pzct/pzct.sh /usr/local/bin/pzct`  
`ln -s $HOME/pzct/pzct.conf /usr/local/bin/pzct.conf`  
`ln -s $HOME/pzct/rcon /usr/local/bin/rcon`  
`ln -s $HOME/pzct/rcon.yaml /usr/local/bin/rcon.yaml`<p>
Если вы не _root_, но у вас есть _sudo_ (`which sudo` возвращает ответ `/usr/bin/sudo`) и соответствующие привилегии, то выполните:  
`sudo ln -s $HOME/pzct/pzct.sh /usr/local/bin/pzct`  
`sudo ln -s $HOME/pzct/pzct.conf /usr/local/bin/pzct.conf`  
`sudo ln -s $HOME/pzct/rcon /usr/local/bin/rcon`  
`sudo ln -s $HOME/pzct/rcon.yaml /usr/local/bin/rcon.yaml`<p>
После этого:  
`bash`<p>
После этого в командной строке можете просто писать `pzct command`, рекомендую начать с `pzct help`<p>
Если вы не _root_ и не можете получить _sudo_ привилегии, то придется каждый раз указывать, к какому скрипту вы обращаетесь:  
`$HOME/pzct/pzct.sh command`  
или например  
`/home/user/pzct/pzct.sh command`<p>
В любом случае, полный список команд с описанием можете посмотреть, выполнив:  
`$HOME/pzct/pzct.sh help`  
или например  
`/home/user/pzct/pzct.sh help`<p>
# 99. Лайк, подписка, колокольчик<p>
Можете присоединиться к моему серверу в Discord:  
https://discord.gg/UkrFcBPtPJ<p>
Чтобы увидеть `pzct` в действии, зайдите на мой сервер PZ:  
`IP: 5.128.212.85`  
`ПОРТ: 16261`  
`ПАРОЛЬ СЕРВЕРА: оставьте поле пустым`  
  
или по ссылке https://wargm.ru/server/66326/connect<p>
Сервер работает 24/7, если вам нравятся настройки, то оставайтесь играть со мной и моими друзьями.<p>
Если вам нравится `pzct`, то, пожалуйста, проголосуйте за мой сервер по ссылке:  
https://wargm.ru/server/66326/votes
