<?php
require_once ("config.php");
require_once ("mysql_to_json.class.php");
// Author Mirko Mancin: 
/* server timezone */

define('CONST_SERVER_TIMEZONE', 'UTC');
 
/* server dateformat */
define('CONST_SERVER_DATEFORMAT', 'Y-m-d H:i:s');


class M2MConnect {

	public $connect;

	/*##################### COSTRUCTOR #################################*/
	function __construct() {
		$this -> connect = mysqli_connect($GLOBALS['db_host'], $GLOBALS['user'], $GLOBALS['pwd'], $GLOBALS['db_name']);
	}


	function addNewDevice($rawData) {
		$json = json_decode($rawData, true);
		/*
		{"mac":"XXXXX","longitude":"44.10","latitude":"10.10","accuracy":"10","type":"GSM","location":"1",
		 "sensors":[
						{"name":"temp","datatype":"DOUBLE","rangeMin":"-20","rangeMax":"80","units":"C","type":"termometria"},
						{"name":"hum","datatype":"INTEGER","rangeMin":"0","rangeMax":"100","units":"rH","type":"igrometria"}
						{"name":"temp","datatype":"DOUBLE","rangeMin":"-20","rangeMax":"80","units":"C","type":"thermoglobe"}
					]}
		
		 */
		$mac = $json['mac']; 
		$longitude = $json['longitude']; 
		$latitude = $json['latitude']; 
		$accuracy = $json['accuracy']; 
		$type = $json['type']; 
		$location = $json['location']; 
		$sensors = (array) $json['sensors']; 
		
		 
		$query = "INSERT INTO  `device` (`idDevice`,`m2mLocation_idLocation` ,`type` ,`lat` ,`lng`,`alt`) VALUES (NULL ,  '{$location}', '{$type}' ,  '{$latitude}' ,  '{$longitude}' ,  '{$accuracy}');";
		//echo $query;
		$resp = mysqli_query($this->connect, $query);
		
		$deviceId = mysqli_insert_id($this->connect);
		
		if ($deviceId > 0)
			$response = array('status' => "200", 'msg' => "Log Correctly Added () !");
		else{
			$response = array('status' => "400", 'msg' => "Log data ERROR ! Insert not completed !");
			return $response;
		}
		
		$query = "INSERT INTO  `networkInterface` (`macAddress`,`device_idDevice` ,`type` ,`ipAddress`) VALUES ('{$mac}' ,  '{$deviceId}', '{$type}' ,  '{$deviceId}');";
		//echo $query;
		$resp = mysqli_query($this->connect, $query);
		
		foreach($sensors as $sensor) { //foreach element in $arr
		    $name = $sensor['name'];
			$datatype = $sensor['datatype'];
			$rangeMin = $sensor['rangeMin'];
			$rangeMax = $sensor['rangeMax'];
			$units = $sensor['units'];
			$type = $sensor['type'];
			
			$query = "INSERT INTO  `sensorType` (`idsensorType`,`name` ,`device_idDevice` ,`dataType` ,`rangeMin` ,`rangeMax` ,`units` ,`type`) VALUES (NULL, '{$name}' ,  '{$deviceId}', '{$datatype}' ,  '{$rangeMin}' ,  '{$rangeMax}' ,  '{$units}' ,  '{$type}');";
			//echo $query . "\n";
			$resp = mysqli_query($this->connect, $query);
			
			//$deviceId = mysqli_insert_id($this->connect);
		}
		
		$response = array('status' => "200", 'msg' => "Log Correctly Added () !");	
		return $response;
    }

    function addNewLog($rawData) {
    	
		$r = explode('{',$rawData);
		
		$remote = "";
		if(count($r)>1)
			$remote = explode('}',$r[1])[0];
		
		$array = explode(':',$r[0]);
		
		$ID = $array[0];
		
		$rawJSON = "";
		//ZANZARINO - for debug!!
		$sense = explode(',',$array[1]);
					
		$Key = $sense[0];
	
		if($ID == "XXXXX" || 
			$ID == "XXXXX" || 
			$ID == "" || 
			$ID == "" || 
			$ID == "" || 
			$ID == ""){
			  
			  	//$sense = explode(',',$array[1]);
				
				$convFactor = 0.0275;
				if($Key != "XXXXX")
					$convFactor *= 2;
				
		    	//$Key = $sense[0];
				$temp = $sense[1];
				$hum = $sense[2];
				$volt = $sense[3] * $convFactor;
				$voltLiPo = $sense[4] * $convFactor;
				$solar1 = $sense[5];
				$solar2 = $sense[6];
				$waterTemp = $sense[7];
				$RPMTops = $sense[8];			
				$RPMLast = $sense[9];
				$pp = $sense[10];
				$ppLast = $sense[11];	
					
				$rawJSON = "{\"mac\":\"". $ID ."\",\"Key\":\"". $Key ."\",\"temp\":\"". $temp ."\",\"hum\":\"". $hum ."\",\"volt\":\"". $volt ."\",\"lipo\":\"". $voltLiPo ."\",\"waterTemp\":\"". $waterTemp ."\",\"lux\":\"". $solar1 ."\",\"rpm\":\"". $RPMTops ."\",\"RPMLast\":\"". $RPMLast ."\",\"pp\":\"". $pp ."\",\"ppLast\":\"". $ppLast ."\"}";
		}
		/*	
		else if($ID == "XXXXX"){
					
		           	//$Key = $sense[0];
				$temp = $sense[1];
				$hum = $sense[2];
				$volt = $sense[3];
				$voltLiPo = $sense[4];
				$solar1 = $sense[5];
				$solar2 = $sense[6];
				$soilTemp = $sense[7];
				$RPMTops = $sense[8];			
				$RPMLast = $sense[9];
				$pp = $sense[10];
				$ppLast = $sense[11];	
					
				$rawJSON = "{\"mac\":\"". $ID ."\",\"Key\":\"". $Key ."\",\"temp\":\"". $temp ."\",\"hum\":\"". $hum ."\",\"volt\":\"". $volt ."\",\"lipo\":\"". $voltLiPo ."\",\"soilTemp\":\"". $soilTemp ."\",\"lux\":\"". $solar1 ."\",\"rpm\":\"". $RPMTops ."\",\"RPMLast\":\"". $RPMLast ."\",\"pp\":\"". $pp ."\",\"ppLast\":\"". $ppLast ."\"}";
		}	
		else if($ID == "XXXXX"){
					
		      	//$Key = $sense[0];
				$temp = $sense[1];
				$hum = $sense[2];
				$volt = $sense[3];
				$voltLiPo = $sense[4];
				$solar1 = $sense[5];
				$solar2 = $sense[6];
				$soilTemp = $sense[7];
				$RPMTops = $sense[8];			
				$RPMLast = $sense[9];
				$pp = $sense[10];
				$ppLast = $sense[11];	
					
				$rawJSON = "{\"mac\":\"". $ID ."\",\"Key\":\"". $Key ."\",\"temp\":\"". $temp ."\",\"hum\":\"". $hum ."\",\"volt\":\"". $volt ."\",\"lipo\":\"". $voltLiPo ."\",\"soilTemp\":\"". $soilTemp ."\",\"lux\":\"". $solar1 ."\",\"rpm\":\"". $RPMTops ."\",\"RPMLast\":\"". $RPMLast ."\",\"pp\":\"". $pp ."\",\"ppLast\":\"". $ppLast ."\"}";
		}
		*/
		else{
			return "";
		}
		
		$inputObj = json_decode($rawJSON);
		$response = null;
	    
    	if (!is_array($inputObj) && isset($inputObj -> mac)) {
	
			$mac = $inputObj -> mac;
			$batteryLevel = $volt;
	
			$md5Input = $mac . $GLOBALS['data_checksum_secret'];
			$checksum = md5($md5Input);
	
			$deviceId = $this -> getDeviceIdByMacAddress($mac);
				
			$str_server_timezone = CONST_SERVER_TIMEZONE;
		              $str_server_dateformat = CONST_SERVER_DATEFORMAT;
			 
		  	// set timezone to user timezone

		  	date_default_timezone_set($str_user_timezone);
		 
		  	$date = new DateTime();
		  	$date->setTimezone(new DateTimeZone($str_server_timezone));
		  	$str_server_now = $date->format($str_server_dateformat);
		 
		               $date->sub(new DateInterval('PT'.($t*15).'M'));
			$t--;
							
			$time = $date->format('Y-m-d H:i');
			
			$query = "INSERT INTO  `sensedData` (`idSensedData` ,`deviceMacAddress` ,`timestamp` ,`payload`) VALUES (NULL ,  '{$mac}', '{$time}' ,  '{$rawJSON}');";
			//echo $query;
			mysqli_query($this->connect, $query);

			if (mysqli_insert_id($this->connect) > 0)
				$response = array('status' => "200", 'msg' => "Log Correctly Added () !");
			else
				$response = array('status' => "400", 'msg' => "Log data ERROR ! Insert not completed !");

			$deviceId = $this -> getDeviceIdByMacAddress($mac);
			//$this -> updateBatteryLevelForDevice($deviceId, $batteryLevel);

			if($remote!=""){
				list($pay, $volt_remote) = explode('$',$remote);
				//echo $pay;
				$tmp = explode(':',$pay);
					
				for($i=count($tmp)-1, $j=0; $i>=0; $i--, $j++){
					//echo $tmp[$i];
					$value = explode(',',$tmp[$i]);
					
					$source_timestamp=strtotime($time);
					$time=date(CONST_SERVER_DATEFORMAT, strtotime("-15 minute", $source_timestamp));
					$temp_remote = $value[0];	
					$presence = $value[1];
					
					$rawJSON = "{\"mac\":\"". $ID ."_remote\",\"Key\":\"". $Key ."\",\"temp_remote\":\"". $temp_remote ."\",\"presence\":\"". $presence ."\",\"volt\":\"". $volt_remote ."\"}";
	
					$inputObj = json_decode($rawJSON);
	
					
					$query = "INSERT INTO  `sensedData` (`idSensedData` ,`deviceMacAddress` ,`timestamp` ,`payload`) VALUES (NULL ,  '{$mac}', '{$time}' ,  '{$rawJSON}');";
					//echo $query . "\n";
					mysqli_query($this->connect, $query);
		
					if (mysqli_insert_id($this->connect) > 0)
						$response = array('status' => "200", 'msg' => "Log Correctly Added () !");
					else
						$response = array('status' => "400", 'msg' => "Log data ERROR ! Insert not completed !");
							
				}	
			}	
		}
		else
		{
			$response = array('status' => "404", 'msg' => "POST Arguments ERROR !");			
		}
								
		
		
		return json_encode($response);
	}


	function getDeviceIdByMacAddress($macAddress) {

		$query = "SELECT device.idDevice FROM device, networkInterface WHERE networkInterface.device_idDevice = device.idDevice AND macAddress='{$macAddress}'";

		$result = mysqli_query($this->connect, $query) or die(mysql_error());

		$id = -1;

		while ($row = mysqli_fetch_array($result)) {
			$id = $row['idDevice'];
		}

		return $id;
	}

    
}
?>
