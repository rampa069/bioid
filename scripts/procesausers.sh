#!/bin/bash
#
#
BINDIR=/usr/local/bin
BIODIR=/opt/bioid
CFGDIR=$BIODIR/cfg
NDXDIR=$BIODIR/ndx
LSTDIR=$BIODIR/lst
TRAINDIR=$BIODIR/train
#
#

rm $BIODIR/prm/*
rm $BIODIR/lbl/*

echo "" > $LSTDIR/users.lst

for a in `find $TRAINDIR -name *-digitos.wav` ; 
do  
        c=`basename $a .wav`
          
        sfbcep -F WAVE -p 19 -e -D -A $a prm/$c.prm
                    
        echo $c >> $LSTDIR/users.lst                         
done
                                 
#
#
$BINDIR/NormFeat --config $CFGDIR/NormFeat_energy.cfg --inputFeatureFilename $LSTDIR/users.lst  
#
$BINDIR/EnergyDetector --config $CFGDIR/EnergyDetector.cfg --inputFeatureFilename $LSTDIR/users.lst 
#
$BINDIR/NormFeat --config $CFGDIR/NormFeat.cfg --inputFeatureFilename $LSTDIR/users.lst 
#
#
$BINDIR/TrainWorld --config $CFGDIR/TrainWorldInit.cfg --inputStreamList $LSTDIR/users.lst  --outputWorldFilename world_init --debug true --verbose true
$BINDIR/TrainWorld --config $CFGDIR/TrainWorldFinal.cfg --inputStreamList $LSTDIR/users.lst --outputWorldFilename world --inputWorldFilename world_init
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
for a in `ls $BIODIR/train/wav` ;
do
	$BIODIR/train2.sh $a
	                
done
                
                