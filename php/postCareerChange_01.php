<?php

require_once 'private/util/globals.php';

$trimmed_canvas_url = trim($canvas_url, 'http://');
$trimmed_canvas_url = trim($trimmed_canvas_url, '/');
$canvas_url_array = explode('/', $trimmed_canvas_url);
$post_namespace = $canvas_url_array[1];

$post_app_id = $app_id;
$post_type = $post_namespace.':career';
$post_canvas_url = $server_folder_url.'postCareerChange_01.php';
$post_title = 'Careers';
$post_description = "If at first you do not succeed... try another career!";
$post_image_url = $client_folder_url.'images/Icon_FBTickerPostCareerChange.png';
$linkImage = $client_folder_url.'images/DHGPlayNow.png';

?>

<html xmlns="http://www.w3.org/1999/xhtml" dir="ltr" lang="en-US" xmlns:fb="http://ogp.me/ns/fb#">
	
	<head prefix="og: http://ogp.me/ns# <?php echo $post_namespace?>: http://ogp.me/ns/apps/<?php echo $post_namespace?>#"> 
	
		<meta property="fb:app_id" content="<?php echo $post_app_id?>" /> 
		<meta property="og:type" content="<?php echo $post_type?>" /> 
		<meta property="og:url" content="<?php echo $post_canvas_url?>" />  
		<meta property="og:title" content="<?php echo $post_title?>" /> 
		<meta property="og:description" content="<?php echo $post_description?>" />
		<meta property="og:image" content="<?php echo $post_image_url?>" />
		
	</head>

	<body> 
		<a href="http://apps.facebook.com/deadlinehollywood"><img src="<?php echo $linkImage?>" /></a>
		<br>
		<br>
		Join Nikki Finke, the reigning queen of Hollywood news, in Deadline Hollywood Game, to find out if you have what it takes to really make it in Tinsel Town. Build your reputation, align with powerful friends and climb your way up the showbiz food chain in this game of intrigue and power.
	</body>
	
</html>