#!/usr/bin/php
<?
$arg=$argv[1];
$fichero="/opt/bioid/test/res/".$arg.".res";
$ficherog="/opt/bioid/test/res/".$arg."-g.res";

$array=array();
$arrayg=array();

$results=array();
$username=array();

$resultsg=array();
$usernameg=array();

$n=0;


function min_float () {
  $args = func_get_args();
    
      if (!count($args[0])) return false;
        else { 
            $min = false;
            foreach ($args[0] AS $value) {
                                          if (is_numeric($value)) {
                                          $curval = floatval($value);
                                          if ($curval < $min || $min === false) $min = $curval;
                                          } 
                                         }  
             } 
               
             return $min;
} 

function max_float () {
  $args = func_get_args();
    
      if (!count($args[0])) return false;
        else { 
            $max = false;
            foreach ($args[0] AS $value) {
                                          if (is_numeric($value)) {
                                          $curval = floatval($value);
                                          if ($curval > $max || $max === false) $max = $curval;
                                          } 
                                         }  
             } 
               
             return $max;
} 

  
 
$fs=@fopen($fichero, "r");
$n=0;
if ($fs == FALSE)
{
  echo "ERR ";
  exit (-1);  
}
 
while (!feof($fs))
{
  list ($array[$n]['gender'],$username[$n],$array[$n]['recognized'],$array[$n]['filename'],$results[$n]) = fscanf($fs, "%s %s %s %s %f");
  $n++;
}


$fs=@fopen($ficherog, "r");
$n=0;
if ($fs == FALSE)
{
  echo "ERR ";
  exit (-1);  
}
 
while (!feof($fs))
{
  list ($arrayg[$n]['gender'],$usernameg[$n],$arrayg[$n]['recognized'],$arrayg[$n]['filename'],$resultsg[$n]) = fscanf($fs, "%s %s %s %s %f");
  $n++;
}
 
 
$resultado=$results[0];

array_multisort($results,SORT_NUMERIC,SORT_DESC,
                $username);

array_multisort($resultsg,SORT_NUMERIC,SORT_DESC,
                $usernameg);
                

if ($username[0] == $arg+"_gmm") {
       $acceso='OK'; 
} else {
       $acceso='NOK';
}              


if ($usernameg[0] == "male_gmm") {
       $gender='M'; 
       
} else {
       $gender='F';
}
 
$salida = array('result'     => $acceso,
                'recognized' => $array[0]['recognized'],
                'value'      => number_format($resultado,2),
                'gender'     => $gender,
                'maxValue'   => number_format(max_float($results),2),
                'minValue'   => number_format(min_float($results),2),
                'valueCount' => count($results),
                'confidence' => max_float($results)-min_float($results)
                   );


echo json_encode($salida);

?>

