<p>Всем привет!</p>
<p>В январе 2022 года я решил запустить свой собственный сервер для игры Project Zomboid. Условия позволяли мне использовать для этого отдельный компьютер дома. Я был знаком с ОС семейства GNU/Linux. Поэтому я решил, что сервер будет работать на компьютере с Linux.</p>
<p>Управляя сервером, я понял, что это совсем не просто. Управление сводилось к выполнению команд в консоли. Различные действия требовали выполнения различных команд. Нужно было либо запомнить эти команды, либо обращаться к их списку. Команды нужно было выполнять в определенной последовательности. Всё это занимало много времени.</p>
<p>В то время я умел писать примитивные скрипты для Unix shell. Я написал несколько простых скриптов, и стал выполнять их, когда это было нужно. Управлять сервером стало проще. Но результат всё равно меня не устраивал. Решение простых задач позволяло подумать о более сложных. Я пришел к выводу, что хочу иметь один скрипт, который будет выполнять те или иные действия, которые я укажу.</p>
<p> В это же время меня повысили на работе. Мне стало нужно уметь писать более сложные скрипты. Я понял, что лучшей возможности для обучения мне не представится. Поэтому взялся за сооружение pzct.</p>
<p>Сначала я повторил основные механики, которые уже были у меня в виде отдельных скриптов, такие как start, quit и backup. Я написал довольно простую, и, как мне кажется, удачную проверку того, запущен или не запущен процесс сервера, что позволило выполнять или не выполнять действия с сервером.</p>
<p>Сложность возникла при написании функции внутриигровых уведомлений перед остановкой сервера. С этим мне помог человек с никнеймом joljaycups из Discord, за что я выражаю ему благодарность. После этого, путем комбинации функций, я смог получить опцию restart.</p>
<p>Этот проект для меня является образовательным. В нем наверняка присутствуют моменты, которые опытные люди сочтут неоптимальными или неверными. Если вы хотите предложить исправление или свой вариант в реализации того или иного момента, то не стесняйтесь это сделать. Хотя я и достиг того минимума, на который расчитывал, но продолжу исправлять и улучшать утилиту pzct в будущем.</p>
<p>Изначально я расчитывал только на личное пользование скриптом. Однако, если кому-то из вас это будет полезно, то вы тоже можете пользоваться pzct. Я хочу обратить ваше внимание на то, что, хотя я свободно и бесплатно распространяю данный скрипт, однако я прошу вас не присваивать себе результаты моей работы. Вы можете редактировать мой скрипт так, как вам нужно, однако я прошу вас не распространять скрипт после того, как вы его отредактировали.</p>
<p>Вы можете связаться со мной в Telegram: https://t.me/vsnegupal или написав на почту vsnegupal@gmail.com (быстрый ответ не гарантируется).</p>
<p>Благодарю за внимание!</p>