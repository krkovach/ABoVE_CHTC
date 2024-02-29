#!/bin/bash

username=kovach3

ENVNAME=py365ht120
ENVDIR=$ENVNAME
group="$1"

#-----Environment-----

cp /staging/$username/support/$ENVNAME.tar.gz ./

mkdir $ENVDIR
tar -xzf $ENVNAME.tar.gz -C $ENVDIR
rm $ENVNAME.tar.gz

export PATH=$(pwd)/$ENVDIR:$(pwd)/$ENVDIR/lib:$(pwd)/$ENVDIR/share:$PATH

. $ENVDIR/bin/activate

#-----Prep and Download-----

mkdir coeffs/
mkdir imagery/
mkdir ${group}_storage
flightnamefolder=${group}_storage/

cp /staging/$username/support/ABOVE/scripts/image_correct120.py ./
cp /staging/$username/support/ABOVE/scripts/image_correct_json_generate120.py ./
cp /staging/$username/support/ABOVE/tables/AVIRIS_NG_Lines.txt ./
cp /staging/$username/support/ABOVE/scripts/correct_avng_offset_obs_ort.py ./

mkdir jsons/

filelist=$(column -s, -t < AVIRIS_NG_Lines.txt | awk -v var="$group" '($1 == var)')
linklist=$(awk -F' ' '{print$6}' <<< "$filelist")
linklist=$(echo $linklist | tr -d '\r')
rfllist=$(awk -F' ' '{print$7}' <<< "$filelist")
rfllist=$(echo $rfllist | tr -d '\r')

#-----Pre-Process-----

#Download files
for DOWNLOAD in "$linklist"; do wget $DOWNLOAD -P $flightnamefolder; done
for DOWNLOAD in "$rfllist"; do wget $DOWNLOAD -P $flightnamefolder; done

#Unzip and keep obs_ort and rfl
for f in $flightnamefolder*.gz; do tar -zxvf $f -C $flightnamefolder; done
find $flightnamefolder -type f -name '*.tar.gz*' -delete
find $flightnamefolder -mindepth 1 -type f -not \( -name "*obs_ort*" -o -name "*rfl*" \) -delete

#Move from folders to main folder
folderlines=$(find $flightnamefolder -mindepth 1 -type d)
for g in $folderlines; do mv $g/* $flightnamefolder; done
find $flightnamefolder -mindepth 1 -type d -delete
obsort=$(find $flightnamefolder -type f -name '*obs_ort')
for h in $obsort; do python correct_avng_offset_obs_ort.py -i $h -o $h"_new";done

#Run scripts
python ./image_correct_json_generate120.py $group $flightnamefolder $(pwd)
python ./image_correct120.py ic_config_$group.json

#Move contents
mv coeffs/*.json jsons/
mv coeffs/* imagery/
mv ic_config_$group.json jsons/

#-----Zip and Move-----

tar -cvf ${group}_jsons.tar jsons/

if [ -z "$(ls -A imagery/)" ]; then
    tar -czvf ${group}_jsons.tar.gz ${group}_jsons.tar
    mv ${group}_jsons.tar.gz /staging/$username/imagery_output/ABOVE/
else
    tar -cvf ${group}_imagery.tar imagery/
    tar -czvf ${group}_imagery-jsons.tar.gz ${group}_imagery.tar ${group}_jsons.tar
    mv ${group}_imagery-jsons.tar.gz /staging/$username/imagery_output/ABOVE/
fi

#-----Clean Up Remote Node-----

rm -rf ./*

# rm -rf $ENVDIR
# rm -f AVIRIS_NG_Lines.txt
# rm -f correct_avng_offset_obs_ort.py
# rm -r imagery/
# rm -rf jsons/
# rm -rf coeffs/
# rm -rf $flightnamefolder
# rm -f image_correct_json_generate120.py
# rm -f image_correct120.py
# rm -f ${group}_imagery.tar
# rm -f ${group}_jsons.tar
# rm -f ${group}_imagery-jsons.tar

# mailx -s '$(group) Done' 8149374272@vtext.com < status.txt
# rm -f status.txt

exit
exit
