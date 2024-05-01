#! /bin/bash

if [ $# -ne 3 ]
then
	echo "usage $0 file1 file2 file3"
	exit 1
fi

echo "************OSS1 - Project1************"
echo "*         StudentID: 12181673         *"
echo "*         Name : JuhoJang             *"
echo "***************************************"
while :
do
	echo "[MENU]"
	echo "1. Get the data of Heung-Min Son's Current Club, Appearances, Goals, Assists in players.csv"
	echo "2. Get the team data to enter a league position in teams.csv"
	echo "3. Get the Top-3 Attendance matches in mateches.csv"
        echo "4. Get the team's league position and team's top scorer in teams.csv & players.csv"
	echo "5. Get the modified format of date_GMTin matches.csv"
	echo "6. Get the data of the winning team by the largest difference on home stadium in teams.csv & matches.csv"
	echo "7. Exit"
	read -p "Enter your CHOICE (1~7): " choice
	
	case "$choice" in
		1)
			read -p "Do you want to get the Heung-Min Son's data? (y/n): " flag
			if [ "$flag" = "y" ]
			then
				awk -F, '$1~/^(Heung-Min)/{printf "Team:%s, Apperance:%d, Goal:%d, Assist:%d\n", $4, $6, $7, $8}' "$2"
			fi
			;;
		2)
			read -p "What do you want to get the team data of league_position[1~20]: " pos
			awk -v pattern=$pos -F, '$6==pattern{printf "%d %s %f\n", $6 , $1, ($2/($2+$3+$4))}' "$1"
			;;
		3)
			read -p "Do you want to know Top-3 attendance data and average attendance? (y/n): " flag
			if [ "$flag" = "y" ]
			then
				sort -t "," -r -k 2 -g $3 | head -n 3 | awk -F, '{printf "%s vs %s (%s)\n%d %s\n", $3, $4, $1, $2, $7}'
			fi
			;;
		4)
			read -p "Do you want to get each team's ranking and the highest-scoring player? (y/n): " flag
			if [ "$flag" = "y" ]
			then
				IFS=$'\n'
				for line1 in $(awk 'NR > 1' "$1" | sort -t "," -k 6 -g)
				do
    					info=$(echo "$line1" | awk -F, '{printf "%d %s", $6, $1}')
    					printf "%s\n" ${info}
    					team=$(echo "$info" | sed 's/[0-9]\{1,2\}/,/g' | awk -F", " '{printf "%s", $2}')
    					player=$(sort -t "," -r -k 7 -g "$2" | awk -v club=$team -F, 'BEGIN {max=0} $4==club {if ($7 > max) {max=$7; name=$1} else if (max == $7) {name=name " " max "\n" $1}} END {printf "%s %d", name, max}')
    					printf "%s\n" ${player}
				done
			fi;;
		5)
			read -p "Do you want to modify the format of date? (y/n): " flag
			if [ "$flag" = "y" ]
			then
				sed -e 's/Jan/01/' -e 's/Feb/02/' -e 's/Mar/03/' -e 's/Apr/04/' -e 's/May/05/' -e 's/Jun/06/' -e 's/Jul/07/' -e 's/Aug/08/' -e 's/Sep/09/' -e 's/Oct/10/' -e 's/Nov/11/' -e 's/Dec/12/' "$3" | sed -E 's/([0-9]{2}) ([0-9]{1,2}) ([0-9]{4}) - ([0-9]{1,2}:[0-9]{2}(am|pm))/\3\/\1\/\2 \4/' | awk -F, '{print $1}' | head -n 10
			fi;;
		6)
			IFS=$'\n'
			PS3="Enter your team number: "
			choice=$(awk -F, 'NR > 1{print $1}' "$1")
			select team in $choice
			do
        			# echo "$team"
        			diff=$(awk -v club=$team -F, '$3==club{print $5 - $6}' "$3" | sort -r | head -n 1)
        			output=$(awk -v max=$diff -v club=$team -F, '$3==club && $5 - $6 == max {printf "%s\n%s %d vs %d %s\n", $1, $3, $5, $6, $4}' "$3")
        			printf "%s\n" ${output}
        			break
			done
			;;
		7)
			echo "Bye!"
			break

	esac



done

