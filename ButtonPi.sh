#!/bin/bash
#
Musique ()
{
	wget -q -U Mozilla -O output.mp3 "http://translate.google.com/translate_tts?ie=UTF-8&total=1&idx=0&textlen=32&client=tw-ob&q='Musique'&tl=Fr-fr"
	mplayer output.mp3
	playlist=`echo $[($RANDOM % ($[3 - 1] + 1)) + 1]`
	echo $playlist
	if [ $playlist = 1 ]
	then
	mplayer -playlist ~/ButtonPi/PiLaylist/Playlist1.m3u
	elif [ $playlist = 2 ]
	then
	mplayer -playlist ~/ButtonPi/PiLaylist/Playlist2.m3u
	elif [ $playlist = 3 ]
	then
	mplayer -playlist ~/ButtonPi/PiLaylist/Playlist3.m3u
	fi
	let "compte = compte + 1" && Principale
}

PiGenda ()
{
	wget -q -U Mozilla -O output.mp3 "http://translate.google.com/translate_tts?ie=UTF-8&total=1&idx=0&textlen=32&client=tw-ob&q='PiGenda'&tl=Fr-fr"
	mplayer output.mp3
	date=`date +%A`
	lecture=`cat /home/pi/ButtonPi/PiGenda/"$date".txt`
	wget -q -U Mozilla -O output.mp3 "http://translate.google.com/translate_tts?ie=UTF-8&total=1&idx=0&textlen=32&client=tw-ob&q='Tu as. $lecture'&tl=Fr-fr"
	mplayer output.mp3
	let "compte = compte + 1" && Principale
}

PiMeteo ()
{
	wget -q -U Mozilla -O output.mp3 "http://translate.google.com/translate_tts?ie=UTF-8&total=1&idx=0&textlen=32&client=tw-ob&q='Récupération météo en cours'&tl=Fr-fr"
	mplayer output.mp3
	meteo=`curl "http://api.openweathermap.org/data/2.5/weather?q=St-omer,FR&units=metric&appid=85a4e3c55b73909f42c6a23ec35b7147"`
	ville=$(echo $meteo | jq '.name')
	tempactu=$(echo $meteo | jq '.main.temp')
	tempmin=$(echo $meteo | jq '.main.temp_min')
	tempmax=$(echo $meteo | jq '.main.temp_max')
	wget -q -U Mozilla -O output.mp3 "http://translate.google.com/translate_tts?ie=UTF-8&total=1&idx=0&textlen=32&client=tw-ob&q='La température actuelle pour $ville est de $tempactu degrés. La température minimum sera de $tempmin degrés. La température maximum sera de $tempmax degrés'&tl=Fr-fr"
	mplayer output.mp3
	let "compte = compte + 1" && Principale
}


Principale ()
{
let "compte = 1"
gpio mode 4 in
gpio mode 0 out
gpio mode 2 out
gpio mode 3 out
gpio write 0 0 && gpio write 2 0 && gpio write 3 0
 echo -n "Waiting for button ..."

 while [ $compte = 1 ]; do
   if [ `gpio read 4` = 0 ]
	then
		gpio write 0 1
		sleep 1
		if [ `gpio read 4` = 0 ]
			then
				gpio write 2 1
				sleep 1
				if [ `gpio read 4` = 0 ]
					then
						gpio write 3 1
						let "compte = compte - 1"
						sleep 1
						PiMeteo
					else
						let "compte = compte - 1"
						sleep 1
						PiGenda
		                fi

			else
	        	        let "compte = compte - 1"
		                sleep 1
				Musique

		 fi
   fi
 done
}

jqpath=$(which jq)
if [ "$jqpath" = "" ]
then
        echo "ERREUR: jq non-installé"
        exit 69 # EX_UNAVAILABLE
else
        echo "jq : installé"
fi

bcpath=$(which bc)
if [ "$bcpath" = "" ]
then
        echo "ERREUR: bc non-installé"
        exit 69 # EX_UNAVAILABLE
else
        echo "bc : installé"
fi

wiringpipath=$(which wiringpi)
then
        echo "ERREUR: wiringpi non-installé"
        exit 69 # EX_UNAVAILABLE
else
        echo "wiringpi : installé"
fi

Principale
