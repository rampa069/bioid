#!/bin/bash

if [ "$2" = "" ]
then
   LANG="es"
else
  LANG=$2
fi

USER=$1
USER=${USER/#00/}  

export BIODIR='/opt/bioid'
export TMPDIR=$BIODIR/tmp
export CFGDIR=$BIODIR/cfg
export TRAINDIR=$BIODIR/train
export EXECDIR=/opt/bin
export WAVDIR=$TRAINDIR/wav/$LANG
export LSTDIR=$TRAINDIR/lst
export LBLDIR=$TRAINDIR/lbl
export PRMDIR=$TRAINDIR/prm

pushd $WAVDIR/$USER
ls *digit*.wav > $LSTDIR/dir_$USER.lst
cd /opt/bioid/train/

mkdir -p $TRAINDIR/prm/$USER
mkdir -p $TRAINDIR/lst/$USER
mkdir -p $TRAINDIR/ndx/$USER
mkdir -p $TRAINDIR/lbl/$USER


echo >$TRAINDIR/lst/$USER/train.lst
echo -n "$USER" > $TRAINDIR/ndx/$USER/train.ndx
echo -n "_gmm " >> $TRAINDIR/ndx/$USER/train.ndx

for a in `cat $TRAINDIR/lst/dir_$USER.lst` ;
do
        c=`basename $a .wav`
        
        sox $WAVDIR/$USER/$a -n stat -v 2> $TMPDIR/$c.volume
                
        sox -c 1 $WAVDIR/$USER/$a -n trim 0 2 noiseprof $TMPDIR/$c-speech.noise-profile                                              > /dev/null 2> /dev/null
        sox -c 1 -v `cat $TMPDIR/$c.volume`  $WAVDIR/$USER/$a  $TMPDIR/nr-$c.wav  noisered $TMPDIR/$c-speech.noise-profile  0.5 vad  > /dev/null 2> /dev/null

#        sox -c 1 $WAVDIR/$USER/$a  $TMPDIR/nr-$c.wav vad
        
#        sfbcep -F WAVE -p 19 -e -D -A /opt/bioid/train/wav/$USER/$c.wav /opt/bioid/train/prm/$USER/$c.prm
#        slpcep -F WAVE -n 19 -p 19 -e -D -A $WAVDIR/$USER/$c.wav  $PRMDIR/$USER/$c.prm
         $EXECDIR/slpcep -F WAVE -n 19 -p 19 -e -D -A $TMPDIR/nr-$c.wav  $TRAINDIR/prm/$USER/$c.prm

#        vadalize -v -c /opt/bioid/PHN_HU_SPDAT_LCRC_N1500 -i /opt/bioid/train/wav/$USER/$c.wav -o $LBLDIR/$USER/$c.lbl

        echo $c >> $TRAINDIR/lst/$USER/train.lst
        echo -n "$c " >> $TRAINDIR/ndx/$USER/train.ndx
done
#
$EXECDIR/NormFeat --config $CFGDIR/NormFeat_energy.cfg \
                          --inputFeatureFilename $TRAINDIR/lst/$USER/train.lst\
                          --featureFilesPath $TRAINDIR/prm/$USER/ \
                          --mixtureFilesPath ./gmm/$LANG/ \
                          --labelFilesPath  $TRAINDIR/lbl/$USER/
#
$EXECDIR/EnergyDetector --config $CFGDIR/EnergyDetector.cfg \
                        --inputFeatureFilename $TRAINDIR/lst/$USER/train.lst\
                        --featureFilesPath $TRAINDIR/prm/$USER/ \
                        --mixtureFilesPath ./gmm/$LANG/ \
                        --labelFilesPath  $TRAINDIR/lbl/$USER/
#
$EXECDIR/NormFeat --config $CFGDIR/NormFeat.cfg \
		  --inputFeatureFilename $TRAINDIR/lst/$USER/train.lst \
		  --featureFilesPath $TRAINDIR/prm/$USER/ \
		  --mixtureFilesPath ./gmm/$LANG/ \
		  --labelFilesPath  $TRAINDIR/lbl/$USER/
#
$EXECDIR/TrainTarget --config $CFGDIR/TrainTarget.cfg \
		     --targetIdList $TRAINDIR/ndx/$USER/train.ndx \
		     --inputWorldFilename world \
		     --featureFilesPath $TRAINDIR/prm/$USER/ \
		     --mixtureFilesPath	$BIODIR/gmm/$LANG/ \
		     --labelFilesPath   $TRAINDIR/lbl/$USER/


rm $TRAINDIR/prm/$USER/*
#rm $TRAINDIR/lst/$USER/*
#rm $TRAINDIR/ndx/$USER/*
rm $TRAINDIR/lbl/$USER/*




popd
