#!/usr/bin/php
<?
$arg=$argv[1];
$fichero="/opt/bioid/test/res/".$arg.".res";

$array=array();
$results=array();
$username=array();
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
 
 
$resultado=$results[0];

array_multisort($results,SORT_NUMERIC,SORT_DESC,
                $username);
                
if ($username[0] == $arg+"_gmm") {
       $acceso='OK'; 
       
} else {
       $acceso='NOK';
}
 
$salida = array('result'     => $acceso,
                'recognized' => $array[1]['recognized'],
                'value'      => number_format($resultado,2),
                'maxValue'   => number_format(max_float($results),2),
                'minValue'   => number_format(min_float($results),2),
                'valueCount' => count($results),
                'confidence' => max_float($results)-min_float($results)
                   );


echo json_encode($salida);

?>

