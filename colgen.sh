#!/bin/ash

GetBooksFromSubDir() # Сканирование папки второго уровня и ее подпапок
{
	SERIAL_PATH=$1
	for k in "$SERIAL_PATH"/*
	do
		if [ -f "$k" ]
		then
			AddBook "BOOKSINFOLDER" "$k"
		elif [ -d "$k" ]
		then
			GetBooksFromSubDir "$k"
		fi
	done
}

AddSerial() # Добавление коллекции
{
	SERIALNAME=$1
	BOOKLIST=$2
	if [ ${#BOOKLIST} -ne 0 ]
	then
		BOOKLIST=$(expr substr "$BOOKLIST" 1 $((${#BOOKLIST}-1)))
		SERIALS="$SERIALS\"$SERIALNAME@en-US\":{\"items\":[$BOOKLIST],\"lastAccess\":$(date +%s)},"
	fi
}

AddBook() # Добавление книги в коллекцию
{
	BOOKLISTNAME=$1
	BOOK=$2
	IsBook "$BOOK"
	if [ $? -eq 1 ]
	then
		eval $BOOKLISTNAME="\$${BOOKLISTNAME}"'\"*$(echo -n $BOOK | openssl sha1)\",'
	fi	
}

IsBook() # Проверка является ли файл книгой
{
	FILENAME=`echo "$1" | tr '[A-Z]' '[a-z]'`
	FILEEXT=`echo "$FILENAME"|awk -F "." '{printf("%s", $NF)}'`
	for EXT in mobi pdf txt azw mp3 # Расширения файлов добавляемых в коллекцию
	do
		if [[ $FILEEXT == $EXT ]]
		then
			return 1
		fi
	done
	return 0
}

GetSerialsFromDir() # Получение списка коллекций из папки
{
DIRECTORY=$1
for i in "$DIRECTORY"/*
	do
		if [ -d "$i" ]
		then
			BOOKSINFOLDER=""
			for j in "$i"/*
			do
				if [ -d "$j" ]
				then
					BOOKS=""
					GetBooksFromSubDir "$j"
					#AddSerial "$(basename "$i")" $BOOKS
				elif [ -f "$j" ]
				then
					AddBook "BOOKSINFOLDER" "$j"
				fi
			done
			AddSerial "$(basename "$i")" $BOOKSINFOLDER
		fi
	done
}

if [ ! -d "$(dirname $0)/backup" ]
then
	mkdir "$(dirname $0)/backup"
fi
if [ ! -f "$(dirname $0)/backup/collections.json" ]
then
	cp /mnt/us/system/collections.json $(dirname $0)/backup/collections.json
fi

SERIALS=""
BOOKS=""
BOOKSINFOLDER=""

for SCANDIR in documents audible # Папки в который производится сканирование
do
	GetSerialsFromDir "/mnt/us/$SCANDIR"
done
SERIALS=$(expr substr "$SERIALS" 1 $((${#SERIALS}-1)))
echo "{$SERIALS}" > /mnt/us/system/collections.json

/etc/init.d/framework restart # Перезагрузка фреймворка
