#!/bin/bash
for a in `ls *.wav` ; 
do  
        c=`echo $a |cut -d"-" -f 1`
        d=`echo $a |cut -d"." -f 2`

 	mv $a $c-$d.wav             
done

