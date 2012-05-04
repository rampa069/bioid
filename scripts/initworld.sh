#!/bin/bash
#
#
BINDIR=/usr/local/bin
BIODIR=/opt/bioid
CFGDIR=$BIODIR/cfg
NDXDIR=$BIODIR/ndx
LSTDIR=$BIODIR/lst
TRAINDIR=$BIODIR/train
SCRIPTDIR=$BIODIR/scripts
#
#

rm $BIODIR/prm/*
rm $BIODIR/lbl/*

echo "" > $LSTDIR/users_train.lst

for a in `find $TRAINDIR -name *-digitos*.wav` ; 
do  
        c=`basename $a .wav`
          
#        sfbcep -F WAVE -p 19 -e -D -A $a prm/$c.prm
        slpcep -F WAVE -n 19 -p 19 -e -D -A $a prm/$c.prm
                    
        echo $c >> $LSTDIR/users_train.lst                         
done
                                 
#
#
$BINDIR/NormFeat --config $CFGDIR/NormFeat_energy.cfg --inputFeatureFilename $LSTDIR/users_train.lst  
#
$BINDIR/EnergyDetector --config $CFGDIR/EnergyDetector.cfg --inputFeatureFilename $LSTDIR/users_train.lst 
#
$BINDIR/NormFeat --config $CFGDIR/NormFeat.cfg --inputFeatureFilename $LSTDIR/users_train.lst 
#
#
$BINDIR/TrainWorld --config $CFGDIR/TrainWorldInit.cfg --inputStreamList $LSTDIR/users.lst  --outputWorldFilename world_init --debug true --verbose true --weightStreamList $LSTDIR/users.weight
$BINDIR/TrainWorld --config $CFGDIR/TrainWorldFinal.cfg --inputStreamList $LSTDIR/users.lst --outputWorldFilename world --inputWorldFilename world_init  --weightStreamList $LSTDIR/users.weight
                
                