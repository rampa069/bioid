#!/usr/bin/php
<?php
$arg=$argv[1];
$fichero="/opt/bioid/test/res/".$arg.".res";

$array=array();
$results=array();
$username=array();
$n=1;


$fs=@fopen($fichero, "r");

if ($fs == FALSE)
{
  echo "ERR ";
  exit (-1);
}

while (!feof($fs))
{
  list ($array[$n][1],$username[$n],$array[$n][3],$array[$n][4],$results[$n]) = fscanf($fs, "%s %s %s %s %s");
  $n++;
}

$resultado=$results[1];

array_multisort($results,SORT_NUMERIC,SORT_DESC,
                $username);
                
//var_dump($results);
//var_dump($username);


if ($username[0] == $arg+"_gmm") {
 echo "OK CORRECTO ". number_format($results[0],2)."\n";
} else {
 echo "NOK INCORRECTO ".number_format($resultado,2)."\n";
}

?>