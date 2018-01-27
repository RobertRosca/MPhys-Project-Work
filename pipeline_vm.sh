#!/bin/bash

archive="/cygdrive/i/.nustar_archive/"

archive_cl="/cygdrive/i/.nustar_archive_cl/"

powershell.exe -Command 'New-BurntToastNotification -Text "Nupipeline Running", "Running on $# observations"'

highlight=`tput setaf 6`
reset=`tput sgr0`

echo "${highlight}Running for $@ ${reset}"

for ObsID in "$@"
do
	echo "${highlight}Running on $ObsID ${reset}"
	mkdir $archive_cl$ObsID

	echo "${highlight}Running init ${reset}"
	source /home/Robert/heasoft-6.22.1/i686-pc-cygwin/headas-init.sh
	source /home/Robert/caldb/software/tools/caldbinit.sh

	#if [ ! -d "$archive$ObsID" ]; then
	#	echo "${highlight}Observation not found at $archive$ObsID"
	#	exit 1
	#fi

	echo "${highlight}Running nupipeline with indir=$archive$ObsID steminputs=nu$ObsID outdir=$archive_cl$ObsID/pipeline_out/${reset}"

	log_file="$archive_cl$ObsID"/pipeline_vm.log""

	nupipeline indir=$archive$ObsID steminputs=nu$ObsID outdir=$archive_cl$ObsID"/pipeline_out/" | tee -a "$log_file"

	echo "${highlight}Finished nupipeline ${reset}"

	echo "${highlight}DONE ${reset}"
done


powershell.exe -Command 'New-BurntToastNotification -Text "Nupipeline Finished", "Finished: $@"'

# https://stackoverflow.com/questions/11616835/r-command-not-found-bashrc-bash-profile
# https://stackoverflow.com/questions/16227971/whats-the-cygwin-windows-equivalent-of-linux-notify-send
# https://stackoverflow.com/questions/4037939/powershell-says-execution-of-scripts-is-disabled-on-this-system
