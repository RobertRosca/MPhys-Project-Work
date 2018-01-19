ObsID=$1

cyan=`tput setaf 6`
reset=`tput sgr0`

if [ ! -d "$HEADAS" ]; then
	echo "HEADAS not found, running init"
	heainit
	caldbinit
fi

archive="/mnt/hgfs/.nustar_archive/"
archive_live="/home/robert/Desktop/temp_hvs2/.nustar_archive/"

clean="/mnt/hgfs/.nustar_archive_cl/"
clean_live="/home/robert/Desktop/temp_hvs2/.nustar_archive_cl/"

if [ ! -d "$archive$ObsID" ]; then
	echo "Observation not found at $archive$ObsID"
	exit 1
fi

if [ -d "$archive_live$ObsID" ]; then
	echo "$ObsID already in live $archive_live, aborting"
	exit 1
fi

echo "Copying $ObsID to $archive_live"

rsync -a --info=progress2 $archive$ObsID/ $archive_live$ObsID/

echo "${cyan}Running nupipeline${reset}"

nupipeline indir=$archive_live$ObsID steminputs=nu$ObsID outdir=$clean_live$ObsID"/pipeline_out/"

echo "${cyan}Finished nupipeline${reset}"

rsync -a --info=progress2 --remove-source-files $clean_live$ObsID/ $clean$ObsID/

echo "${cyan}DONE${reset}"

echo "${cyan}Removing $archive_live$ObsID${reset}"

rm -r -f $archive_live$ObsID

rm -r -f $clean_live$ObsID
