<?php
require_once('connect.php');
$name=(isset($_POST['name']))?$_POST['name']:'';
$type=$_POST['type'];
$query=(!strcmp($type,'insert'))?"INSERT INTO `leaderboard` (`name`) VALUES ('$name')":"SELECT * FROM `leaderboard` WHERE 1 ORDER BY `timestamp` DESC LIMIT 10";
$result=$mysqli->query($query);
if(!strcmp($type,'show'))
{
	$reponse='';
	while($row=$result->fetch_assoc())
	{
		$response.="<span class='lb_name'>".$row['name']."</span>";
	}
	echo $response;
}
?>