files=$(ls | grep .evt)

if [ "$files" != "" ]; then
	echo 'Starting heasoft'
	source /home/robert/Documents/heasoft-6.22.1/x86_64-unknown-linux-gnu-libc2.23/headas-init.sh

	echo 'Found files:'
	echo $files
	mkdir -p readable
else
	echo 'No ".evt" files found'
fi

for file in $files ; do
	file_out=`basename $file .evt`.txt
	fdump infile=./$file[1] outfile=./readable/$file_out columns="TIME X Y DET1X DET1Y DET2X DET2Y" rows=-
	echo 'Saved as' ./readable/$file_out
done
