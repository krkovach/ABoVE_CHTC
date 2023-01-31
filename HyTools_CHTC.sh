# Set Env Variables #

username=kovach3

ENVNAME=hytools_env
ENVDIR=$ENVNAME
flightname=$1

# Set Environment #

cp /staging/$username/support/ABOVE/Zips/$ENVNAME.tar.gz ./

mkdir $ENVDIR
tar -xzf $ENVNAME.tar.gz -C $ENVDIR
rm $ENVNAME.tar.gz

export PATH=$(pwd)/$ENVDIR:$(pwd)/$ENVDIR/lib:$(pwd)/$ENVDIR/share:$PATH

. $ENVDIR/bin/activate

# Initial Processing Steps #

mkdir coeffs/
mkdir ${flightname}_storage
flightnamefolder=${flightname}_storage/

cp /staging/$username/support/ABOVE/HyTools_Scripts/image_correct.py ./
cp /staging/$username/support/ABOVE/HyTools_Scripts/image_correct_json_generate.py ./
cp /staging/$username/support/ABOVE/HyTools_Scripts/trait_estimate.py ./
cp /staging/$username/support/ABOVE/HyTools_Scripts/trait_estimate_json_generate.py ./
cp /staging/$username/support/ABOVE/Zips/trait_models.tar.gz ./ #Full Traits
cp /staging/$username/support/ABOVE/Tables/ABOVE_Lines.txt ./
cp /staging/$username/support/ABOVE/Rotation_Correction/correct_avng_offset_obs_ort.py ./

mkdir traits/
mkdir trait_models/
traitmodels=trait_models
tar -xzf trait_models.tar.gz -C trait_models/ #Full Traits

mkdir jsons/

filelist=$(column -s, -t < ABOVE_Lines.txt | awk -v var="$flightname" '($1 == var)')
linklist=$(awk -F' ' '{print$3}' <<< "$filelist")
linklist=$(echo $linklist | tr -d '\r')
rfllist=$(awk -F' ' '{print$4}' <<< "$filelist")
rfllist=$(echo $rfllist | tr -d '\r')
rflhdrlist=$(awk -F' ' '{print$5}' <<< "$filelist")
rflhdrlist=$(echo $rflhdrlist | tr -d '\r')

for DOWNLOAD in "$linklist"; do wget $DOWNLOAD -P $flightnamefolder; done

for DOWNLOAD in "$rfllist"; do wget $DOWNLOAD -P $flightnamefolder; done

for DOWNLOAD in "$rflhdrlist"; do wget $DOWNLOAD -P $flightnamefolder; done

for f in $flightnamefolder*.gz; do tar -zxvf $f -C $flightnamefolder; done

find $flightnamefolder -type f -name '*.tar.gz*' -delete

find $flightnamefolder -type f -name '*img*' -delete

folderlines=$(find $flightnamefolder -mindepth 1 -type d)

for g in $folderlines; do mv $g/* $flightnamefolder; done

find $flightnamefolder -mindepth 1 -type d -delete

obsort=$(find $flightnamefolder -type f -name '*obs_ort')

for h in $obsort; do python correct_avng_offset_obs_ort.py -i $h -o $h"_new";done

python ./image_correct_json_generate.py $flightname $flightnamefolder $(pwd)

python ./image_correct.py ic_config_$flightname.json

python ./trait_estimate_json_generate.py $flightname $flightnamefolder $(pwd)

python ./trait_estimate.py trait_config_$flightname.json

mv coeffs/*.json jsons/

mv coeffs imagery

# Handle and Resort Output #

mv ic_config_$flightname.json imagery/

tar -cvf ${flightname}_imagery.tar imagery/

mv trait_config_$flightname.json traits/

tar -cvf ${flightname}_traits.tar traits/

tar -cvf ${flightname}_jsons.tar jsons/

tar -czvf ${flightname}_imagery-jsons-traits.tar.gz ${flightname}_imagery.tar ${flightname}_jsons.tar ${flightname}_traits.tar

mv ${flightname}_imagery-jsons-traits.tar.gz /staging/$username/imagery_output/ABOVE/

# Remove Files #

rm -rf $ENVDIR

rm -f ABOVE_joblist.txt

rm -f ABOVE_joblistfull.txt

rm -f ABOVE_Lines.txt

rm -f correct_avng_offset_obs_ort.py

rm -r imagery/

rm -rf traits/

rm -rf jsons/

#rm -rf coeffs/

rm -rf trait_models/

rm -rf $flightnamefolder

rm -f image_correct_json_generate.py

rm -f image_correct.py

rm -f trait_estimate_json_generate.py

rm -f trait_estimate.py

rm -f trait_models.tar

rm -f trait_models.tar.gz

rm -f data_pull.py

rm -f ${flightname}_traits.tar

rm -f ${flightname}_imagery.tar

rm -f ${flightname}_jsons.tar

rm -f ${flightname}_imagery-jsons-traits.tar

exit