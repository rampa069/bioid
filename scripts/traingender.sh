#!/bin/bash

LANG=$2
export BIODIR='/opt/bioid'
export TMPDIR=$BIODIR/tmp
export CFGDIR=$BIODIR/cfg
export TRAINDIR=$BIODIR/train
export EXECDIR=/opt/bin
export WAVDIR=$TRAINDIR/gender
export LSTDIR=$TRAINDIR/lst
export LBLDIR=$TRAINDIR/lbl
export PRMDIR=$TRAINDIR/prm

pushd $WAVDIR/$1

ls *digit*.wav > $LSTDIR/dir_$1.lst
cd /opt/bioid/train/

mkdir -p $TRAINDIR/prm/$1
mkdir -p $TRAINDIR/lst/$1
mkdir -p $TRAINDIR/ndx/$1
mkdir -p $TRAINDIR/lbl/$1


echo >$TRAINDIR/lst/$1/train.lst
echo -n "$1_gmm " > $TRAINDIR/ndx/$1/train.ndx

for a in `cat $TRAINDIR/lst/dir_$1.lst` ; 
do  
        c=`basename $a .wav`
  
#        sfbcep -F WAVE -p 19 -e -D -A /opt/bioid/train/wav/$1/$c.wav /opt/bioid/train/prm/$1/$c.prm
        $EXECDIR/slpcep -F WAVE -n 19 -p 19 -e -D -A $WAVDIR/$1/$c.wav  $PRMDIR/$1/$c.prm
             
#        vadalize -v -c /opt/bioid/PHN_HU_SPDAT_LCRC_N1500 -i /opt/bioid/train/wav/$1/$c.wav -o $LBLDIR/$1/$c.lbl
             
        echo $c >> $TRAINDIR/lst/$1/train.lst
        echo -n "$c " >> $TRAINDIR/ndx/$1/train.ndx
done
#
$EXECDIR/NormFeat --config $CFGDIR/NormFeat_energy.cfg \
                  --inputFeatureFilename $TRAINDIR/lst/$1/train.lst \
                  --featureFilesPath $TRAINDIR/prm/$1/ \
                  --labelFilesPath  $TRAINDIR/lbl/$1/
#
$EXECDIR/EnergyDetector --config $CFGDIR/EnergyDetector.cfg \
                        --inputFeatureFilename $TRAINDIR/lst/$1/train.lst \
                        --featureFilesPath $TRAINDIR/prm/$1/  \
                        --labelFilesPath  $TRAINDIR/lbl/$1/
#
$EXECDIR/NormFeat --config $CFGDIR/NormFeat.cfg \
                  --inputFeatureFilename $TRAINDIR/lst/$1/train.lst \
                  --featureFilesPath $TRAINDIR/prm/$1/ \
                  --labelFilesPath  $TRAINDIR/lbl/$1/
#
$EXECDIR/TrainTarget --config $CFGDIR/target_male.cfg \
                     --targetIdList $TRAINDIR/ndx/$1/train.ndx \
                     --inputWorldFilename world \
                     --featureFilesPath $TRAINDIR/prm/$1/ \
                     --mixtureFilesPath	$BIODIR/gmm/$LANG/ \
                     --labelFilesPath   $TRAINDIR/lbl/$1/



rm $TRAINDIR/prm/$1/*
rm $TRAINDIR/lst/$1/*
rm $TRAINDIR/ndx/$1/*
rm $TRAINDIR/lbl/$1/*




popd
