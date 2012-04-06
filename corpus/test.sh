#!/bin/bash

for a in `ls *.wav` ; 
do  
        c=`echo $a |cut -d"-" -f 1`

        /opt/bin/SRec_test $a 9999
                
done

