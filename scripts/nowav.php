#!/usr/bin/php
<?
 
$salida = array('result'     => 0,
                'recognized' => 0,
                'value'      => 0,
                'gender'     => 0,
                'maxValue'   => 0,
                'minValue'   => 0,
                'valueCount' => 0,
                'confidence' => 0
                   );


echo json_encode($salida);

?>

