colgen - Генератор коллекций для Kindle.

I. Требования
1. jailbreak
2. launchpad (опционально см. 2.1)
3. usbnetwork (опционально см. 2.2)
II. Установка
1. Распаковать папку из архива на Kindle.
	Например, в корень отображаемого съемного диска (/mnt/us)
2. Выбрать способ запуска скрипта: по кнопке(2.1) 
	или автоматически при отключении от USB-порта компьютера(2.2).
2.1 Добавить в launchpad сочетание клавиш для запуска скрипта.
	Для этого дописать в файл /mnt/us/launchpad/launchpad.ini строку:
	C = !/bin/ash /mnt/us/colgen/colgen.sh
	Соответственно путь к файлу colgen.sh должен соответствовать тому, куда вы его распаковали.
2.2 Для тех у кого установлен usbNetwork можно добавить в файл /lib/udev/bin/notifyusb	
	одну строку как показано ниже. Теперь перестроение коллекций будет происходить автоматически
	после отключения Kindle от USB-порта компьютера.
		if [ "$ACTION" = "offline" ] ; then
			/usr/bin/lipc-send-event -r 3 com.lab126.hal usbUnconfigured
			/bin/ash /mnt/us/colgen/colgen.sh # эту строку нужно добавить
		fi	
3. Нажать выбранное сочетание(если вы его указали) произойдет перезагрузка фреймворка Kindle.
	После перезагрузки вы получите список коллекций в соответствии с вашими папками,
	а в папке backup будет сохранен ваш старый список коллекций.
	Если вы выбрали только второй способ, то создание коллеций произойдет только после 
	следующего отлючения Kindle от USB-порта компьютера.
	
III. Работа скрипта.
1. Для построения коллекций сканируются папки:
	1) documents
	2) audible
	При желании можете указать свои пути в скрипте.
2. В коллекции включаются файлы с расширениями:
	1) mobi
	2) pdf
	3) txt
	4) azw
	5) mp3
	В принципе этот список очень просто отредактировать в скрипте.
3. Принцип формирования коллекций:
	Сканируются папки первого уровня
		а) файлы внутри них помещаются в коллекцию "<Имя папки первого уровня>"
		б) папки внутри них сканируются снова и все файлы из них и их подпапок
			помещаются в коллекцию "<Имя папки первого уровня> - <Имя папки второго уровня>"
		в) Коллекции из пустых папок не создаются
			
IV. Пример:
		/mnt/us/
		+documents
		|+Ливадный Андрей
		||+История Галактики
		|||-Наемник.mobi
		|||-Первый мир.mobi
		||-Титановая лоза.mobi
		|+Вселенная метро 2033
		||-Мраморный рай.mobi
		||-Странник.pdf
		|+Панов Вадим
		||+Тайный город
		||+Анклавы
		|||+Костры на алтарях.mobi
		|||+Московский клуб.mobi
		...
		+audible
		|+Аудиокниги
		|||+Alhimik.mp3
		|+Волошина Полина
		||+Этногенез
		|||+Маруся.mp3
	
	Полученный список коллекций:
		Ливадный Андрей - История Галактика
		Ливадный Андрей
		Вселенная метро 2033
		Панов Вадим - Анклавы
		Аудиокниги
		Волошина Полина - Этногенез
		
21.12.2010
stasenko
