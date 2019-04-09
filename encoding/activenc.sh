#!/bin/bash
## Script to auto encode videos
## Author: maitre
# $Id$
## Updated: 2014.06.22

set -m

IN_DIR="/disk/raid2/tmp/encode/in"
OUT_DIR="/disk/raid2/tmp/encode"

DEC_OPTS="-vf dsize=480:320:0,scale=-8:-8,harddup -alang jpn -slang eng -ass -embeddedfonts"
FRM_OPTS="-of lavf -lavfopts format=mp4"
VID_OPTS="-ovc x264 -x264encopts profile=baseline:global_header"
AUD_OPTS="-oac faac -faacopts mpeg=4:object=2:raw:br=128"

MAX_THREADS="5"
count="1"
timestamp="`date +%s`"

echo "========================================================" >> /tmp/activenc_${timestamp}.log
echo "activenc started `date`" >> /tmp/activenc_${timestamp}.log

encode_list ()
{
	inlist=$1
	for enc_file in ${enc_list[${inlist}]}
	do
		## The Logic V -- Encode each file in the list
		echo "--------------------------------------------------------">> /tmp/activenc_${timestamp}_${inlist}.log
		echo "Encoding $enc_file -- `date`" >> /tmp/activenc_${timestamp}_${inlist}.log
		echo mencoder ${DEC_OPTS} ${FRM_OPTS} ${VID_OPTS} ${AUD_OPTS} -o ${OUT_DIR}/${enc_file}.mp4 ${IN_DIR}/${enc_file} 2>&1 >> /tmp/activenc_${timestamp}_${inlist}.log
		echo "----" >>/tmp/activenc_${timestamp}_${inlist}.log
		mencoder ${DEC_OPTS} ${FRM_OPTS} ${VID_OPTS} ${AUD_OPTS} -o ${OUT_DIR}/${enc_file}.mp4 ${IN_DIR}/${enc_file} 2>&1 >> /tmp/activenc_${timestamp}_${inlist}.log 2>&1
	done
}

cd ${IN_DIR} || exit 1

## Bug-Logic I - less files than max threads?
FILECOUNT="`ls *.* |wc -l`"
if [ ${FILECOUNT} -lt ${MAX_THREADS} ]
then
	MAX_THREADS=${FILECOUNT}
fi

## The Logic I -- Check if there are files to encode.
for in_file in *.*
do
	if [ ! -f ${OUT_DIR}/${in_file}.mp4 ]
	then
		## The Logic II -- Add file to "current" list
		enc_list[${count}]="${enc_list[${count}]} $in_file"

		## The Logic III -- increment current list
		if [ $count -ge $MAX_THREADS ]
		then
			count="1"
		else
			count="`expr $count + 1`"
		fi

	fi

done

### The Logic IV -- Run encoder thread on each list
for in_list in `seq 1 $MAX_THREADS`
do
	coproc encode_list ${in_list}
done

wait

for in_list in `seq 1 $MAX_THREADS`
do
	cat /tmp/activenc_${timestamp}_${in_list}.log >> /tmp/activenc_${timestamp}.log
	rm -f /tmp/activenc_${timestamp}_${in_list}.log
done
echo "activenc completed `date`" >> /tmp/activenc_${timestamp}.log
echo "========================================================" >> /tmp/activenc_${timestamp}.log

