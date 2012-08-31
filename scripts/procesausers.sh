#!/bin/bash
#
#

if [ "$1" = "" ]
then
   LANG="es"
else
   LANG=$1
fi

echo Processing $LANG baseline....        



BINDIR=/opt/bin
BIODIR=/opt/bioid
TMPDIR=$BIODIR/tmp
CFGDIR=$BIODIR/cfg
NDXDIR=$BIODIR/ndx
LSTDIR=$BIODIR/lst
TRAINDIR=$BIODIR/train
SCRIPTDIR=$BIODIR/scripts
#
#

rm $BIODIR/prm/*
rm $BIODIR/lbl/*
rm $BIODIR/tmp/*

echo "" > $LSTDIR/users_train.lst

for a in `find $TRAINDIR/wav/$LANG/ -name *-digit*.wav` ; 
do  
        c=`basename $a .wav`
        sox -c 1 $a -n trim 0 2 noiseprof $TMPDIR/$c-speech.noise-profile
        sox -c 1 $a  $TMPDIR/nr-$c.wav  noisered $TMPDIR/$c-speech.noise-profile  0.5
          
#        sfbcep -F WAVE -p 19 -e -D -A $a prm/$c.prm
        $BINDIR/slpcep -F WAVE -n 19 -p 19 -e -D -A $TMPDIR/nr-$c.wav prm/$c.prm
                    
        echo $c >> $LSTDIR/users_train.lst                         
done
                                 
#
#
$BINDIR/NormFeat --config $CFGDIR/NormFeat_energy.cfg \
		 --inputFeatureFilename $LSTDIR/users_train.lst  
#
$BINDIR/EnergyDetector --config $CFGDIR/EnergyDetector.cfg \
		       --inputFeatureFilename $LSTDIR/users_train.lst 
#
$BINDIR/NormFeat --config $CFGDIR/NormFeat.cfg \
		 --inputFeatureFilename $LSTDIR/users_train.lst 
#
#
$BINDIR/TrainWorld --config $CFGDIR/TrainWorldInit.cfg \
		   --inputStreamList $LSTDIR/users.lst  \
		   --outputWorldFilename world_init \
		   --debug false \
		   --verbose false \
		   --mixtureFilesPath ./gmm/$LANG/ \
		   --weightStreamList $LSTDIR/users.weight
		   
$BINDIR/TrainWorld --config $CFGDIR/TrainWorldFinal.cfg \
                   --inputStreamList $LSTDIR/users.lst \
                   --outputWorldFilename world \
                   --inputWorldFilename world_init  \
                   --mixtureFilesPath ./gmm/$LANG/ \
                   --weightStreamList $LSTDIR/users.weight
#
# --weightStreamList $LSTDIR/world.weight
#
#$BINDIR/TrainTarget --config $CFGDIR/target_male.cfg --targetIdList $NDXDIR/male.ndx --inputWorldFilename world 
#$BINDIR/TrainTarget --config $CFGDIR/target_male.cfg --targetIdList $NDXDIR/female.ndx --inputWorldFilename world 
#
#
#$BINDIR/ComputeTest --config $CFGDIR/target_seg_female.cfg  --ndxFilename ./ndx/tests_female.ndx --worldModelFilename world --outputFilename female.res --debug false --verbose true
#$BINDIR/ComputeTest --config $CFGDIR/target_seg_male.cfg  --ndxFilename ./ndx/tests_male.ndx --worldModelFilename world --outputFilename male.res  --debug false --verbose true
#

#
# Retrain models
#
for a in `ls $BIODIR/train/wav/$LANG` ;
do
	$SCRIPTDIR/train.sh $a $LANG
	                
done
#                
$SCRIPTDIR/traingender.sh male $LANG
$SCRIPTDIR/traingender.sh female $LANG
        
                        