#!/bin/bash

export BIODIR='/opt/bioid'
export CFGDIR=$BIODIR/cfg
export TESTDIR=$BIODIR/test
export EXECDIR=/usr/local/bin
export WAVDIR=$TESTDIR/wav
export LSTDIR=$TESTDIR/lst
export LBLDIR=$TESTDIR/lbl
export SCRDIR=$BIODIR/scripts/
export PRMDIR=$TESTDIR/prm
export GMMDIR=$BIODIR/gmm



if [ ! -e $GMMDIR/$1_gmm.gmm ]
then
     $SCRDIR/nobio.php
     exit 
fi

if [ ! -e $TESTDIR/wav/$1/*.wav ]
then
     $SCRDIR/nowav.php
     exit
fi

  
pushd $TESTDIR > /dev/null

cd $WAVDIR/$1
ls *.wav > $LSTDIR/dir_$1.lst
cd $TESTDIR

mkdir -p $TESTDIR/prm/$1
mkdir -p $TESTDIR/lst/$1
mkdir -p $TESTDIR/ndx/$1
mkdir -p $TESTDIR/lbl/$1



echo >$TESTDIR/lst/$1/test.lst
echo -n "" > $TESTDIR/ndx/$1/test.ndx


          

for a in `cat $LSTDIR/dir_$1.lst` ; 
do  
        c=`basename $a .wav`
  
#        sfbcep -F PCM16 -f8000 -p 19 -e -D -A $WAVDIR/$1/$c.wav $TESTDIR/prm/$1/$c.prm
        slpcep -F WAVE -n 19 -p 19 -e -D -A $WAVDIR/$1/$c.wav  $PRMDIR/$1/$c.prm
     

#        vadalize -v -c /opt/bioid/PHN_HU_SPDAT_LCRC_N1500 -i $WAVDIR/$1/$c.wav -o $LBLDIR/$1/$c.lbl
                
        echo $c >> $TESTDIR/lst/$1/test.lst
        echo -n "$c " >> $TESTDIR/ndx/$1/test.ndx
        echo -n "$c " >> $TESTDIR/ndx/$1/test-g.ndx        
done

echo  "$1_gmm 3182106_gmm 3182103_gmm 3182221_gmm 3182007_gmm 976734193_gmm 3999_gmm" >> $TESTDIR/ndx/$1/test.ndx
echo  "male_gmm female_gmm" >> $TESTDIR/ndx/$1/test-g.ndx

#
$EXECDIR/NormFeat --config $CFGDIR/NormFeat_energy.cfg --inputFeatureFilename ./lst/$1/test.lst --featureFilesPath $TESTDIR/prm/$1/ --labelFilesPath  $TESTDIR/lbl/$1/ > /dev/null
#
$EXECDIR/EnergyDetector --config $CFGDIR/EnergyDetector.cfg --inputFeatureFilename ./lst/$1/test.lst --featureFilesPath $TESTDIR/prm/$1/  --labelFilesPath  $TESTDIR/lbl/$1/ > /dev/null
#
$EXECDIR/NormFeat --config $CFGDIR/NormFeat.cfg --inputFeatureFilename $TESTDIR/lst/$1/test.lst --featureFilesPath $TESTDIR/prm/$1/ --labelFilesPath  $TESTDIR/lbl/$1/ > /dev/null
#
$EXECDIR/ComputeTest --config $CFGDIR/ComputeTest.cfg  --ndxFilename $TESTDIR/ndx/$1/test.ndx --worldModelFilename world --outputFilename $TESTDIR/res/$1.res --mixtureFilesPath   $BIODIR/gmm/  --featureFilesPath $TESTDIR/prm/$1/ --labelFilesPath  $TESTDIR/lbl/$1/
#
$EXECDIR/ComputeTest --config $CFGDIR/target_seg_female.cfg  --ndxFilename $TESTDIR/ndx/$1/test-g.ndx --worldModelFilename world --outputFilename $TESTDIR/res/$1-g.res --mixtureFilesPath   $BIODIR/gmm/  --featureFilesPath $TESTDIR/prm/$1/ --labelFilesPath  $TESTDIR/lbl/$1/


rm $TESTDIR/wav/$1/*
rm $TESTDIR/prm/$1/*
rm $TESTDIR/lst/$1/*
rm $TESTDIR/ndx/$1/*
rm $TESTDIR/lbl/$1/*



 $SCRDIR/toarray.php $1 > $TESTDIR/res1/$1.res
 $SCRDIR/result.php $1 

popd > /dev/null
