#!/usr/bin/php
<?php


$salida = array('result'     => 0,
                'comment'    => ""
               );



function rrmdir($dir) {

foreach(glob($dir . '/*') as $file) {
  if(is_dir($file))
      rrmdir($file);
  else
      unlink($file);
  }
rmdir($dir);
}


if(!isset($argv[1])) {
   $salida['result']="NOK";
   $salida['comment'] = "NOARG";
   echo json_encode($salida);
   exit;
} else { 
       $arg=$argv[1];
       $gmm="/opt/bioid/gmm/".$arg."_gmm.gmm";
       $wavdir="/opt/bioid/train/wav/".$arg;
}


if(file_exists($gmm)){ 
    unlink($gmm); 
    } 
else {
   $salida['result']="NOK";
   $salida['comment'] = "NOGMM";
   echo json_encode($salida);
   exit;
   }       


if(file_exists($wavdir)){ 
    rrmdir($wavdir); 
    } 
else {
   $salida['result']="OK";
   $salida['comment']= "NOWAV";
   echo json_encode($salida);
   exit;
   }       


$salida['result']="OK";
$salida['comment']= "SUCCESS";
      
echo json_encode($salida);


?>
