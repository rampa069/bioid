#!/bin/bash


if [ "$2" = "" ]
then
   LANG="es"
else
     LANG=$2
fi
     

export BIODIR='/opt/bioid'
export CFGDIR=$BIODIR/cfg
export TESTDIR=$BIODIR/test
export EXECDIR=/opt/bin
export WAVDIR=$TESTDIR/wav
export LSTDIR=$TESTDIR/lst
export LBLDIR=$TESTDIR/lbl
export SCRDIR=$BIODIR/scripts/
export PRMDIR=$TESTDIR/prm
export GMMDIR=$BIODIR/gmm/$LANG/



if [ ! -e $GMMDIR/$1_gmm.gmm ]
then
     $SCRDIR/nobio.php
     rm $TESTDIR/wav/$1/*
     exit 
fi

if [ ! -e $TESTDIR/wav/$1/*.wav ]
then
     $SCRDIR/nowav.php
     exit
fi

  
pushd $TESTDIR > /dev/null

cd $WAVDIR/$1
for wavfile in `ls *.wav`;
do

 sox -c 1 *.wav -n trim 0 2 noiseprof speech.noise-profile
 sox -c 1 $wavfile  nr-$wavfile noisered speech.noise-profile  0.6
 echo nr-*.wav >> $LSTDIR/dir_$1.lst

done

ls nr-*.wav > $LSTDIR/dir_$1.lst
cd $TESTDIR

mkdir -p $TESTDIR/prm/$1
mkdir -p $TESTDIR/lst/$1
mkdir -p $TESTDIR/ndx/$1
mkdir -p $TESTDIR/lbl/$1

rm $TESTDIR/res1/$1.res
rm $TESTDIR/res/$1.res



echo >$TESTDIR/lst/$1/test.lst
echo -n "" > $TESTDIR/ndx/$1/test.ndx


          

for a in `cat $LSTDIR/dir_$1.lst` ; 
do  
        c=`basename $a .wav`
  
#        sfbcep -F PCM16 -f8000 -p 19 -e -D -A $WAVDIR/$1/$c.wav $TESTDIR/prm/$1/$c.prm
        $EXECDIR/slpcep -F WAVE -n 19 -p 19 -e -D -A $WAVDIR/$1/$c.wav  $PRMDIR/$1/$c.prm
     

#        vadalize -v -c /opt/bioid/PHN_HU_SPDAT_LCRC_N1500 -i $WAVDIR/$1/$c.wav -o $LBLDIR/$1/$c.lbl
                
        echo $c >> $TESTDIR/lst/$1/test.lst
        echo -n "$c " >> $TESTDIR/ndx/$1/test.ndx
        echo -n "$c " >> $TESTDIR/ndx/$1/test-g.ndx        
done

echo  -n "$1_gmm " >> $TESTDIR/ndx/$1/test.ndx

for user in `ls $BIODIR/gmm/$LANG/[0-9]*`;

	do 
		echo -n "`basename $user .gmm` " >>  $TESTDIR/ndx/$1/test.ndx
     	done 
     


echo  "male_gmm female_gmm" >> $TESTDIR/ndx/$1/test-g.ndx

#
$EXECDIR/NormFeat --config $CFGDIR/NormFeat_energy.cfg \
		  --inputFeatureFilename ./lst/$1/test.lst \
		  --featureFilesPath $TESTDIR/prm/$1/ \
		  --labelFilesPath  $TESTDIR/lbl/$1/ > /dev/null
#
$EXECDIR/EnergyDetector --config $CFGDIR/EnergyDetector.cfg \
			--inputFeatureFilename ./lst/$1/test.lst \
			--featureFilesPath $TESTDIR/prm/$1/  \
			--labelFilesPath  $TESTDIR/lbl/$1/ > /dev/null
#
$EXECDIR/NormFeat --config $CFGDIR/NormFeat.cfg \
		  --inputFeatureFilename $TESTDIR/lst/$1/test.lst \
		  --featureFilesPath $TESTDIR/prm/$1/ \
		  --labelFilesPath  $TESTDIR/lbl/$1/ > /dev/null
#
$EXECDIR/ComputeTest --config $CFGDIR/ComputeTest.cfg  \
		     --ndxFilename $TESTDIR/ndx/$1/test.ndx \
		     --worldModelFilename world \
		     --outputFilename $TESTDIR/res/$1.res \
		     --mixtureFilesPath   $BIODIR/gmm/$LANG/ \
		     --featureFilesPath $TESTDIR/prm/$1/ \
		     --labelFilesPath  $TESTDIR/lbl/$1/
#
$EXECDIR/ComputeTest --config $CFGDIR/target_seg_female.cfg  \
                     --ndxFilename $TESTDIR/ndx/$1/test-g.ndx \
                     --worldModelFilename world \
                     --outputFilename $TESTDIR/res/$1-g.res \
                     --mixtureFilesPath   $BIODIR/gmm/$LANG/  \
                     --featureFilesPath $TESTDIR/prm/$1/ \
                     --labelFilesPath  $TESTDIR/lbl/$1/


rm $TESTDIR/wav/$1/*
rm $TESTDIR/prm/$1/*
rm $TESTDIR/lst/$1/*
rm $TESTDIR/ndx/$1/*
rm $TESTDIR/lbl/$1/*


 $SCRDIR/toarray.php $1 > $TESTDIR/res1/$1.res
 $SCRDIR/result.php $1 
 $SCRDIR/stat.php $1 > /var/www/recordings/test/$1.html

popd > /dev/null
