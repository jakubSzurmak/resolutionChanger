#!/bin/bash

# Author			: Jakub Szurmak ( s193095@student.pg.edu.pl )
# Created ON			: 19.01.2023
# Last Modified By	 	: Jakub Szurmak ( s193095@student.pg.edu.pl )
# Last Modified On		: 19.01.2023
# Version			: 1.00
#
# Description			: The Program changes the resolution of given video file and creates another file
#				  With that resolution. The program doesn't touch the aspect ratio nor cares about
#				  Up/Down Scaling, it performs the simplest resolution change sometimes with
#				  Visible quality loss. Required ffmpeg instalation for usage
#
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more
# details or contact the Free Software Foundation for a copy)

QUIT=0
CURRVERSION=1.00

version () {
	#display current version of the program
	zenity --info --title "Resolution Changer" --text "Current Version of Resolution Changer is $CURRVERSION" --width=500 --height=200
}

help () {
	#display programs' manual
	man reschg | zenity --text-info --title "Resolution Changer" --width=500 --height=600
}

wrongDimension () {
	#warning prompt for bad resolution
	zenity --warning --text "Invalid Dimension, Try Again! " --width=400 --height=200
}

#get positional aruments on startup
while getopts hvf:q OPT;
do
	case $OPT in
		h) help;;
		v) version;;
		*) zenity --error --text "Unknown parameter! " --width=400 --height=200
			exit;;
	esac
done


while [[ $QUIT -eq 0 ]]
do
	#filename of file which player chose
	USERFILE=`zenity --file-selection --file-filter='Music files (avi,flv,mkv,mov,mp2,mp4,ogv,webm,wmv) | *.avi *.flv *.mkv *.mov *.mp2 *.mp4 *.ogv *.webm *.wmv' --title="Select a File for resolution change: "`
	case $? in
		0)
			#width and height declared by user
			USERWIDTH=`zenity --entry --title "Step 1/2 " --text "Insert Desired Resolution Width: "`
			#check if user gave an integer
			if [[ "$USERWIDTH" =~ ^[0-9]+$ ]]
			then
				#check if user gave integer in range
				if [ $USERWIDTH -ge 480 ] && [ $USERWIDTH -le 3840 ] && [ $(expr $USERWIDTH % 2) == "0" ]
				then
					USERHEIGHT=`zenity --entry --title "Step 2/2 " --text "Insert Desired Resolution Height: "`
					if [[ "$USERHEIGHT" =~ ^[0-9]+$ ]]
					then
						if [ $USERHEIGHT -ge 480 ] && [ $USERHEIGHT -le 3840 ] && [ $(expr $USERHEIGHT % 2) == "0" ]
						then
							#variables necessary for file replacement, we create a temp file with changed res and then change it's name to the original files
							SELECTEDPATH="${USERFILE%/*}"
							SELECTEDEXTENSION="${USERFILE##*.}"
							#compose a full file name with path with correct extension
							TEMPFILE=$SELECTEDPATH/outputfile.$SELECTEDEXTENSION
							zenity --info --title "Resolution Changer" --text "Change in Progress wait for success prompt" --width=600 --height=600
							#perform resolution change
							ffmpeg -y -hide_banner -loglevel error -i $USERFILE -vf scale=$USERWIDTH:$USERHEIGHT $TEMPFILE
							#swap temporary for original
							mv $TEMPFILE $USERFILE
							zenity --info --title "SUCCESS" --text "Conversion Finished" --width=600 --height=600
							zenity --question --title "Resolution Changer" --text "Would you like to change another file? " --width=500 --height=300
							#another file change?
							if [[ $? -eq 0 ]]
							then
								continue
							else
								QUIT=1
							fi
						else
						wrongDimension
						fi
					else
						wrongDimension
					fi
				else
					wrongDimension
				fi
			else
				wrongDimension
			fi;;
		1)
			zenity --warning --text "No file selected! " --width=400 --height=200
			QUIT=1;;
		-1)
			zenity --error --text "An error has occured " --width=400 --height=200
			QUIT=1
			break;;
	esac
done
