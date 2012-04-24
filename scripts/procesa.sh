#!/bin/bash
#
#
BINDIR=/usr/local/bin
BIODIR=/opt/bioid
CFGDIR=$BIODIR/cfg
NDXDIR=$BIODIR/ndx
LSTDIR=$BIODIR/lst
TRAINDIR=$BIOID/train
GMMDIR=$BIODIR/gmm/
LBLDIR=$BIODIR/lbl/
PRMDIR=$BIODIR/prm/
#
#
#

rm -rf $PRMDIR/*
rm -rf $LBLDIR/*

for a in `cat $LSTDIR/all.lst` ;
do
     c=`basename $a .wav`
#     sfbcep -F WAVE -f8000 -p 19 -e -D -A $BIODIR/corpus/$a.wav $PRMDIR/$a.prm
     slpcep -F WAVE -n 19 -p 19 -e -D -A $BIODIR/corpus/$a.wav  $PRMDIR/$a.prm
             
#     vadalize -v -c /opt/bioid/PHN_HU_SPDAT_LCRC_N1500 -i $BIODIR/corpus/$a.wav -o $LBLDIR/$c.lbl
done
#
#                
$BINDIR/NormFeat --config $CFGDIR/NormFeat_energy.cfg --inputFeatureFilename $LSTDIR/all.lst  --labelFilesPath $LBLDIR --featureFilesPath $PRMDIR
#
$BINDIR/EnergyDetector --config $CFGDIR/EnergyDetector.cfg --inputFeatureFilename $LSTDIR/all.lst --labelFilesPath $LBLDIR --featureFilesPath $PRMDIR
#
$BINDIR/NormFeat --config $CFGDIR/NormFeat.cfg --inputFeatureFilename $LSTDIR/all.lst --labelFilesPath $LBLDIR --featureFilesPath $PRMDIR
#
#
$BINDIR/TrainWorld --config $CFGDIR/TrainWorldInit.cfg --inputStreamList $LSTDIR/world.lst  --weightStreamList $LSTDIR/world.weight --outputWorldFilename world_init --mixtureFilesPath $GMMDIR --labelFilesPath $LBLDIR --featureFilesPath $PRMDIR
$BINDIR/TrainWorld --config $CFGDIR/TrainWorldFinal.cfg --inputStreamList $LSTDIR/world.lst --weightStreamList $LSTDIR/world.weight --outputWorldFilename world --inputWorldFilename world_init --mixtureFilesPath $GMMDIR --labelFilesPath $LBLDIR --featureFilesPath $PRMDIR
#
#
$BINDIR/TrainTarget --config $CFGDIR/target_male.cfg --targetIdList $NDXDIR/male.ndx --inputWorldFilename world --mixtureFilesPath $GMMDIR --labelFilesPath $LBLDIR --featureFilesPath $PRMDIR
$BINDIR/TrainTarget --config $CFGDIR/target_male.cfg --targetIdList $NDXDIR/female.ndx --inputWorldFilename world  --mixtureFilesPath $GMMDIR --labelFilesPath $LBLDIR --featureFilesPath $PRMDIR
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
	$BIODIR/scripts/train.sh $a
	                
done
                
                