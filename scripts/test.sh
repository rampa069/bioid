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
export CFGDIR=$BIODIR/cfg
export TESTDIR=$BIODIR/test
export EXECDIR=/opt/bin
export WAVDIR=$TESTDIR/wav
export LSTDIR=$TESTDIR/lst
export LBLDIR=$TESTDIR/lbl
export SCRDIR=$BIODIR/scripts/
export PRMDIR=$TESTDIR/prm
export GMMDIR=$BIODIR/gmm/$LANG/



if [ ! -e $GMMDIR/$USER"_gmm".gmm ]
then
     $SCRDIR/nobio.php
     rm $TESTDIR/wav/$USER/*
     exit 
fi

if [ ! -e $TESTDIR/wav/$USER/*.wav ]
then
     $SCRDIR/nowav.php
     exit
fi

  
pushd $TESTDIR > /dev/null

cd $WAVDIR/$USER
for wavfile in `ls *.wav`;
do

 sox -c 1 *.wav -n trim 0 2 noiseprof speech.noise-profile
 sox -c 1 --norm $wavfile  nr-$wavfile noisered speech.noise-profile  0.6 vad

# sox -c 1 $wavfile  nr-$wavfile vad
 echo nr-*.wav >> $LSTDIR/dir_$USER.lst

done

ls nr-*.wav > $LSTDIR/dir_$USER.lst
cd $TESTDIR

mkdir -p $TESTDIR/prm/$USER
mkdir -p $TESTDIR/lst/$USER
mkdir -p $TESTDIR/ndx/$USER
mkdir -p $TESTDIR/lbl/$USER

rm $TESTDIR/res1/$USER.res
rm $TESTDIR/res/$USER.res



echo >$TESTDIR/lst/$USER/test.lst
echo -n "" > $TESTDIR/ndx/$USER/test.ndx


          

for a in `cat $LSTDIR/dir_$USER.lst` ; 
do  
        c=`basename $a .wav`
  
#        sfbcep -F PCM16 -f8000 -p 19 -e -D -A $WAVDIR/$USER/$c.wav $TESTDIR/prm/$USER/$c.prm
        $EXECDIR/slpcep -F WAVE -n 19 -p 19 -e -D -A $WAVDIR/$USER/$c.wav  $PRMDIR/$USER/$c.prm
     

#        vadalize -v -c /opt/bioid/PHN_HU_SPDAT_LCRC_N1500 -i $WAVDIR/$USER/$c.wav -o $LBLDIR/$USER/$c.lbl
                
        echo $c >> $TESTDIR/lst/$USER/test.lst
        echo -n "$c " >> $TESTDIR/ndx/$USER/test.ndx
        echo -n "$c " >> $TESTDIR/ndx/$USER/test-g.ndx        
done

echo  -n "$USER"_gmm" " >> $TESTDIR/ndx/$USER/test.ndx

for user in `ls $BIODIR/gmm/$LANG/[0-9]*`;

	do 
		echo -n "`basename $user .gmm` " >>  $TESTDIR/ndx/$USER/test.ndx
     	done 
     


echo  "male_gmm female_gmm" >> $TESTDIR/ndx/$USER/test-g.ndx

#
$EXECDIR/NormFeat --config $CFGDIR/NormFeat_energy.cfg \
		  --inputFeatureFilename ./lst/$USER/test.lst \
		  --featureFilesPath $TESTDIR/prm/$USER/ \
		  --labelFilesPath  $TESTDIR/lbl/$USER/ > /dev/null
#
$EXECDIR/EnergyDetector --config $CFGDIR/EnergyDetector.cfg \
			--inputFeatureFilename ./lst/$USER/test.lst \
			--featureFilesPath $TESTDIR/prm/$USER/  \
			--labelFilesPath  $TESTDIR/lbl/$USER/ > /dev/null
#
$EXECDIR/NormFeat --config $CFGDIR/NormFeat.cfg \
		  --inputFeatureFilename $TESTDIR/lst/$USER/test.lst \
		  --featureFilesPath $TESTDIR/prm/$USER/ \
		  --labelFilesPath  $TESTDIR/lbl/$USER/ > /dev/null
#
$EXECDIR/ComputeTest --config $CFGDIR/ComputeTest.cfg  \
		     --ndxFilename $TESTDIR/ndx/$USER/test.ndx \
		     --worldModelFilename world \
		     --outputFilename $TESTDIR/res/$USER.res \
		     --mixtureFilesPath   $BIODIR/gmm/$LANG/ \
		     --featureFilesPath $TESTDIR/prm/$USER/ \
		     --labelFilesPath  $TESTDIR/lbl/$USER/
#
$EXECDIR/ComputeTest --config $CFGDIR/target_seg_female.cfg  \
                     --ndxFilename $TESTDIR/ndx/$USER/test-g.ndx \
                     --worldModelFilename world \
                     --outputFilename $TESTDIR/res/$USER-g.res \
                     --mixtureFilesPath   $BIODIR/gmm/$LANG/  \
                     --featureFilesPath $TESTDIR/prm/$USER/ \
                     --labelFilesPath  $TESTDIR/lbl/$USER/


rm $TESTDIR/wav/$USER/*
rm $TESTDIR/prm/$USER/*
rm $TESTDIR/lst/$USER/*
rm $TESTDIR/ndx/$USER/*
rm $TESTDIR/lbl/$USER/*


 $SCRDIR/toarray.php $USER > $TESTDIR/res1/$USER.res
 $SCRDIR/result.php $USER 
 $SCRDIR/stat.php $USER > /var/www/recordings/test/$USER.html

popd > /dev/null
