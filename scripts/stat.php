#!/usr/bin/php
<?php
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

//array_multisort($resultsg,SORT_NUMERIC,SORT_DESC,
//                $usernameg);
                

//if ($username[0] == $arg+"_gmm") {
//       $acceso='OK'; 
//} else {
//       $acceso='NOK';
//}              

if (number_format($resultado,2) == number_format(max_float($results),2)) {
       $acceso='OK'; 
} else {
       $acceso='NOK';
}              




if ($resultsg[0] > $resultsg[1]) {
       $gender='M'; 
       
} else {
       $gender='F';
}

$indice=0;
$aceptados=0;
$rechazados=0;
$tempuser='';
$tempvalue=0;
$stat_user='';
$background="black";

print("<html><head><title>Test de usuario $arg</title></head><body>");
print("<center><table border=\"1\" style=\"background-color:yellow;color:white;border:1px dotted black;width:40%;border-collapse:collapse;\">");
print("<tr style=\"background-color:orange;\"><th>ACCION</th><th>USUARIO</th><th>RESULTADO</th></th>");
foreach ($results as $resultado)
{
    $stat_user=basename($username[$indice],"_gmm");
    $stat_value=number_format($results[$indice],3);

 if ($tempvalue >=0 && $stat_value <= 0)
 {
   //print("---------------------------------------------------------\n");  
 }  
   
 if (($username[$indice] > '') && ($tempuser != $stat_user))
 {

    if ($results[$indice] > 0 )
        {
         $reconocido='POSITIVO';
         $aceptados++;
         $background="green";
        }
       else
        {
         $reconocido='NEGATIVO';
         $rechazados++;
         $background="red";
        }
    print ("<tr style=\"background-color:$background;color:yellow\"><td>$reconocido</td><td>$stat_user</td><td>$stat_value</td><tr>\n");
 }    
 $indice++;
 $tempuser=$stat_user;
 $tempvalue=$stat_value;
 }

$percent=($aceptados*$rechazados)/$indice; 
$posibleId=basename($username[0],"_gmm")." ".number_format(max_float($results),2);
$confidence=max_float($results)-min_float($results);
$recognized=$array[0]['recognized'];
$maxvalue= number_format(max_float($results),2);
$minvalue=number_format(min_float($results),2);


print("</table></center>");
print("<center><hr width=40%></center>");
print("<center>");

print("<table border=\"1\" style=\"background-color:orange;color:black;border:1px dotted black;width:40%;border-collapse:collapse;\">");
print ("<tr><th>Usuarios:</th><td>$indice</td><tr>\n");
print ("<tr><th>Aceptados:</th><td>$aceptados</td></tr>\n");
print ("<tr><th>Rechazados:</th><td>$rechazados</td></tr>\n");
print ("<tr><th>Porcentaje:</th><td>$percent%</td></tr>\n");
print("</table>");

print("</center>");
print("<center><hr width=40%></center>");

print("<center>");

print("<table border=\"1\" style=\"background-color:orange;color:black;border:1px dotted black;width:40%;border-collapse:collapse;\">");
print ("<tr><th>Resultado:</th><td>$acceso</td><tr>\n");
print ("<tr><th>Reconocido:</th><td>$recognized</td></tr>\n");
print ("<tr><th>Genero:</th><td>$gender</td></tr>\n");
print ("<tr><th>Valor Maximo:</th><td>$maxvalue</td></tr>\n");
print ("<tr><th>Valor Minimo:</th><td>$minvalue</td></tr>\n");
print ("<tr><th>Posible usuario (1-N):</th><td>$posibleId</td></tr>\n");
print ("<tr><th>Distancia Máxima:</th><td>$confidence</td></tr>\n");



print("</table>");

print("</center>");


print("</body>"); 





$salida = array('result'     => $acceso,
                'recognized' => $array[0]['recognized'],
                'value'      => number_format($resultado,2),
                'gender'     => $gender,
                'valueCount' => count($results),
                'possibleId' => basename($username[0],"_gmm")." ".number_format(max_float($results),2),
                'confidence' => max_float($results)-min_float($results)
                   );


echo json_encode($salida);

?>

