#!/bin/bash

# child id see Manage Children page: https://classroom.kindercare.com/accounts
# ID is in the url : https://classroom.kindercare.com/accounts/xxxxxx 

child_id="xxxx"
no_insert_db=0
caption=0
 
usage() {
        echo "Usage: $0 [ -cik xxxxxx ] " 1>&2
}

exit_abnormal() {
        usage
        exit 1
}

while getopts "cik:" o; do
	case "${o}" in
		c)
			caption=1
			;;
		i)
			no_insert_db=1
			;;
		k)
			child_id=${OPTARG}
			;;
		:)
			echo "Error: -${OPTARG} requires an argument."
			exit_abnormal
			;;
		*)
			exit_abnormal
			;;
	esac
done

if [ ! -s "$(dirname "${0}")/${child_id}/id.db" ]; then
  mkdir -p "$(dirname "${0}")/${child_id}"
  mkdir -p "/tmp/_${child_id}"
  touch "$(dirname "${0}")/${child_id}/id.db"
else
  mkdir -p "/tmp/_${child_id}"
fi

done=0
k=1

until [ $done == "1" ]; do
	wget -q --load-cookies $(dirname ${0})/cookies.txt "https://classroom.kindercare.com/accounts/${child_id}/journal_api?page=${k}" -O /tmp/_${child_id}/_act

	jq '.intervals[] | .[].activity' /tmp/_${child_id}/_act > /tmp/_${child_id}/_jsontemp 

	if [ -s /tmp/_${child_id}/_jsontemp ]; then
		jq '.activity_file_id' /tmp/_${child_id}/_jsontemp  > /tmp/_${child_id}/_id 
		jq '.title' /tmp/_${child_id}/_jsontemp > /tmp/_${child_id}/_title 
		jq '.description' /tmp/_${child_id}/_jsontemp > /tmp/_${child_id}/_desc
		jq '.created_at' /tmp/_${child_id}/_jsontemp > /tmp/_${child_id}/_date
		jq '.image.big.url,.video.url' /tmp/_${child_id}/_jsontemp | grep -v null  > /tmp/_${child_id}/_img

		sort /tmp/_${child_id}/_id > /tmp/_${child_id}/_id_new
		
		comm -13 "$(dirname "${0}")/${child_id}/id.db" "/tmp/_${child_id}/_id_new" > "/tmp/_${child_id}/_delta"

		n=`cat /tmp/_${child_id}/_id | wc -l`

		new=`cat /tmp/_${child_id}/_delta | wc -l`

		if [ $new -gt 0 ]; then
			i=1
			until [ $i -gt $n ]; do
				id=`head -$i /tmp/_${child_id}/_id | tail -1`  
			 	test=`grep $id /tmp/_${child_id}/_delta`
				
				if [ ! -z "$test" ]; then
					date=`head -$i /tmp/_${child_id}/_date | tail -1 | tr -d '\"'` 
					date=$(echo "$date" | sed 's/\.[0-9]*//' | sed 's/:\([0-9][0-9]\)$/\1/')
          date=$(date -j -f "%Y-%m-%dT%H:%M:%S%z" "$date" "+%Y%m%d_%H%M%S")
					desc=`head -$i /tmp/_${child_id}/_desc | tail -1 | tr -d '\"' | tr -dc '[:alnum:][ ][.!?]\n\r'`  
					desc=${desc/"Look what I'm doing today!"/}
					title=`head -$i /tmp/_${child_id}/_title | tail -1 | tr -d '\"' | tr -dc "[:alnum:][ ][.!?']\n\r"`  
					title=${title/"Look what I'm doing today!"/}
					img=`head -$i /tmp/_${child_id}/_img | tail -1 | tr -d '\"'`  
					
					vidtest=`echo $img | grep "activity_file/video"`
					if [ -z "$vidtest" ]; then
						wget -q $img -O ${child_id}/${date}.jpg
						exiftool -XPcomment="$desc" -title="$title $desc" ${child_id}/${date}.jpg
						if [ "$caption" == "1" ]; then
							size=`exiftool -ImageSize ${child_id}/${date}.jpg | cut -d: -f2 | cut -dx -f1 | cut -d\  -f2`
							convert ${child_id}/${date}.jpg -background lightgray -size ${size}x -pointsize 20 caption:"$title $desc" -gravity center -append result.jpg
							mv -f result.jpg ${child_id}/${date}.jpg
						fi
					else
						wget -q $img -O ${child_id}/${date}.mov
						echo "converting video"
						ffmpeg -loglevel panic -i ${child_id}/${date}.mov -metadata title="$title $desc" ${child_id}/${date}.mp4
						rm ${child_id}/${date}.mov
					fi
				else
					done=1
				fi
				((i++))
			done
		else
			done=1
		fi
		
		((k++))

		if [ "$no_insert_db" == "0" ]; then
			cat /tmp/_${child_id}/_delta >> $(dirname ${0})/${child_id}/id.db
			sort -u $(dirname ${0})/${child_id}/id.db > /tmp/_${child_id}/id.db_sorted
			mv /tmp/_${child_id}/id.db_sorted $(dirname ${0})/${child_id}/id.db
		fi
		rm -rf /tmp/_${child_id}/_act /tmp/_${child_id}/_id /tmp/_${child_id}/_title /tmp/_${child_id}/_desc /tmp/_${child_id}/_date /tmp/_${child_id}/_img /tmp/_${child_id}/_delta /tmp/_${child_id}/_jsontemp $(dirname ${0})/${child_id}/*.jpg_original
	else
		done=1
	fi
done