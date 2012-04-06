#!/bin/bash

export BIODIR='/opt/bioid'
export CFGDIR=$BIODIR/cfg
export TESTDIR=$BIODIR/test
export EXECDIR=/usr/local/bin
export WAVDIR=$TESTDIR/wav
export LSTDIR=$TESTDIR/lst




function f_floats()
{
	a=$1
	b=$2
	if [ "${a}" != "" -a "${b}" != "" ]
	then
		len_a=${#a}
		len_b=${#b}
		
		if [ $len_a -gt $len_b ]
		then
			b=${b}`f_add_zeros $(( $len_a - $len_b ))`
		else
					a=${a}`f_add_zeros $(( $len_b - $len_a ))`
		fi
		
		a=`echo $a | sed 's/\.//'`
		b=`echo $b | sed 's/\.//'`
		
		if [ $a -gt $b ]
		then
			echo 1
		else
			echo 0
		fi
	fi
}

function f_add_zeros()
{
	i=0
	while [ $i -lt $1 ]
		do
			out=${out}0
			((i++))
		done
		echo $out
}

pushd $TESTDIR

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
        c=`echo $a |cut -d"." -f 1`
  
        sfbcep -F PCM16 -f8000 -p 19 -e -D -A $WAVDIR/$1/$c.wav $TESTDIR/prm/$1/$c.prm
        echo $c >> $TESTDIR/lst/$1/test.lst
        echo -n "$c " >> $TESTDIR/ndx/$1/test.ndx
done

echo -n "$1_gmm " >> $TESTDIR/ndx/$1/test.ndx

#
$EXECDIR/NormFeat --config $CFGDIR/NormFeat_energy.cfg --inputFeatureFilename ./lst/$1/test.lst --featureFilesPath $TESTDIR/prm/$1/ --labelFilesPath  $TESTDIR/lbl/$1/
#
$EXECDIR/EnergyDetector --config $CFGDIR/EnergyDetector.cfg --inputFeatureFilename ./lst/$1/test.lst --featureFilesPath $TESTDIR/prm/$1/  --labelFilesPath  $TESTDIR/lbl/$1/
#
$EXECDIR/NormFeat --config $CFGDIR/NormFeat.cfg --inputFeatureFilename $TESTDIR/lst/$1/test.lst --featureFilesPath $TESTDIR/prm/$1/ --labelFilesPath  $TESTDIR/lbl/$1/
#
$EXECDIR/ComputeTest --config $CFGDIR/ComputeTest.cfg  --ndxFilename $TESTDIR/ndx/$1/test.ndx --worldModelFilename world --outputFilename $TESTDIR/res/$1.res --mixtureFilesPath   $BIODIR/gmm/  --featureFilesPath $TESTDIR/prm/$1/ --labelFilesPath  $TESTDIR/lbl/$1/


rm $TESTDIR/wav/$1/*
rm $TESTDIR/prm/$1/*
rm $TESTDIR/lst/$1/*
rm $TESTDIR/ndx/$1/*
rm $TESTDIR/lbl/$1/*


        resultado=`cut -d" " -f 5 $TESTDIR/res/$1.res`

if [ `f_floats $resultado 0.5` == 0 ]
        then
        	echo "INCORRECTO $resultado" > $TESTDIR/res/$1.res
        else
        	echo "CORRECTO $resultado" > $TESTDIR/res/$1.res
        fi

popd
