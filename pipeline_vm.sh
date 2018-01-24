#!/bin/bash

archive="/mnt/hgfs/.nustar_archive/"
archive_live="/home/robert/Desktop/temp_hvs2/.nustar_archive/"

clean="/mnt/hgfs/.nustar_archive_cl/"
clean_live="/home/robert/Desktop/temp_hvs2/.nustar_archive_cl/"

notify-send "Running nupipeline on $# observations" -t 5

highlight=`tput setaf 6`
reset=`tput sgr0`

echo "${highlight}Running for $@${reset}"

for ObsID in "$@"
do
	echo "${highlight}Running on $ObsID${reset}"
	#exec 3>&1 4>&2
	#trap `exec 2>&4 1>&3` 0 1 2 3
	mkdir $clean_live$ObsID
	#exec 1>$clean_live$ObsID"/pipeline_vm.log" 2>&1

	echo "${highlight}Running init${reset}"
	source /home/robert/Software/heasoft-6.22.1/x86_64-unknown-linux-gnu-libc2.23/headas-init.sh
	source /home/robert/Software/caldb/software/tools/caldbinit.sh

	if [ ! -d "$archive$ObsID" ]; then
		echo "${highlight}Observation not found at $archive$ObsID"
		exit 1
	fi

	if [ -d "$archive_live$ObsID" ]; then
		echo "${highlight}$ObsID already in live $archive_live"
		#exit 1
	else
		echo "Copying $ObsID to $archive_live"
		rsync -a --info=progress2 $archive$ObsID/ $archive_live$ObsID/
	fi

	echo "${highlight}Running nupipeline with indir=$archive_live$ObsID steminputs=nu$ObsID outdir=$clean_live$ObsID/pipeline_out/${reset}"

	notify-send "Running nupipeline on $ObsID" -t 5

	log_file="$clean_live$ObsID"/pipeline_vm.log""

	nupipeline indir=$archive_live$ObsID steminputs=nu$ObsID outdir=$clean_live$ObsID"/pipeline_out/" | tee -a "$log_file"

	echo "${highlight}Finished nupipeline${reset}"

	rsync -a --info=progress2 --remove-source-files $clean_live$ObsID/ $clean$ObsID/

	echo "${highlight}Removing $archive_live$ObsID${reset}"

	rm -r -f $archive_live$ObsID

	rm -r -f $clean_live$ObsID

	echo "${highlight}DONE${reset}"

	notify-send "Completed $ObsID nupipeline" -t 5
done

#read -p "Press enter to continue"

#run(`gnome-terminal -e "/home/robert/pipeline_vm.sh ObsID"`)
