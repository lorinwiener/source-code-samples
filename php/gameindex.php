<?php

	if ($need_permissions) {
		exit;
	}

?>
<script type="text/javascript">

  var _gaq = _gaq || [];
  _gaq.push(['_setAccount', 'UA-22379701-1']);
  _gaq.push(['_trackPageview']);

</script>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:fb="http://www.facebook.com/2008/fbml" xml:lang="en" lang="en">
<head>
<!-- this X-UA-Compatible meta tag MUST be the 1st listed under the head tag -->
<meta http-equiv="X-UA-Compatible" content="IE=Edge" />
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>DND Fellowship</title>


<meta property="og:title" content="Dungeons and Dragons: Heroes of Neverwinter"/>
<meta property="og:type" content="game"/>
<meta property="og:url" content="<?php print $canvas_url;?>"/>
<meta property="og:site_name" content="Heroes of Neverwinter"/>
<meta property="fb:app_id" content="<?php print $app_id;?>"/>
<meta property="og:description"
	  content="Dungeons and Dragons Heroes of Neverwinter
	  		   online Facebook game."/>

<script type="text/javascript" src="js/facebookConfiguration.php"></script>
<script type="text/javascript" src="js/swfobject.js"></script>
<script type="text/javascript" src="js/swfaddress.js"></script>

<script type="text/javascript" src="http://assets.tp-cdn.com/static3/js/api/payment_overlay.js"></script>

<script type="text/javascript">

	<!-- Callback function called by TrialPay after a user completes a DealSpot or Offer Shortcut offer -->
	function my_ontransact(obj) {
		if (Number(obj.completions) > 0 && Number(obj.vc_amount) == 1) {
			alert("Congratulations on completing your TrialPay offer!\n\nYou have completed " + obj.completions + " offer and earned " + obj.vc_amount + " Facebook credit.\n\nGet extra weapons, armor, potions, character slots, and more by using your Facebook credits to buy Astral Diamonds in the Dungeons and Dragons Heroes of Neverwinter Facebook game now!");
		} else if (Number(obj.completions) > 0 && Number(obj.vc_amount) > 1) {
			alert("Congratulations on completing your TrialPay offer!\n\nYou have completed " + obj.completions + " offers and earned " + obj.vc_amount + " Facebook credits.\n\nGet extra weapons, armor, potions, character slots, and more by using your Facebook credits to buy Astral Diamonds in the Dungeons and Dragons Heroes of Neverwinter Facebook game now!");
		}
	}
  
  	<!-- Function called by TrialPay DealSpot in Astral Diamonds popup when the user clicks the DealSpot to open an offer panel -->
  	function customer_click() {
		disableAllInput();
  	}
  
  	<!-- Function called by TrialPay DealSpot in Astral Diamonds popup when the user clicks the DealSpot to open an offer panel -->
  	function customer_close() {
		enableAllInput();
  	}
  
</script>

<!-- TrialPay Offer Wall code called by Earn FB credits button -->

<script type="text/javascript" src="http://assets.tp-cdn.com/static3/js/api/payment_overlay.js"></script>

<script type="text/javascript">
  
  function earnCredits(app_id, sid) {
    TRIALPAY.fb.show_overlay(app_id, 'fbpayments', {sid:sid, onTransact:'my_ontransact', onOpen:'customer_click', onClose:'customer_close'});
  }
  
</script>

<!-- Increment "v=1001" to a new number when changes are made to the dnd.css file that affect the page layout. -->
<link rel="stylesheet" type="text/css" media="screen" href="css/dnd.css?v=1005" />
<!-- Increment "v=1001" to a new number when changes are made to either .js that affect the page layout. -->
<script src="js/dndf.js?v=1003" type="text/javascript" ></script>
<script src="js/dndFanBar.js?v=1006" type="text/javascript" ></script>

<!--script type="text/javascript" src="js/json.js"></script-->
<script type="text/javascript" src="js/social-wrapper.js"></script>
<script src="js/jquery-1.4.3.min.js" type="text/javascript"></script>
<!--script type="text/javascript" src="http://www.google.com/jsapi"></script-->
<script type="text/javascript">

	// You may specify partial version numbers, such as "1" or "1.3",
	//  with the same result. Doing so will automatically load the
	//  latest version matching that partial revision pattern
	//  (e.g. 1.3 would load 1.3.2 today and 1 would load 1.4.4).
//	google.load("jquery", "1.4.4");
//	google.load("jquery", "1.3");

	var gameSWF;
	var min_flash_version = "10.2.0";

	function showFlashRequirements()
	{
		document.getElementById("noflash").style.visibility = "visible";
		document.getElementById("flashcontent").style.visibility = "hidden";
	}

	function onSWFEmbed(e)
	{
		if (e.success)
		{
			document.getElementById("flashcontent").style.visibility = "visible";
			document.getElementById("noflash").style.visibility = "hidden";
			gameSWF = e.ref;
		}
		else
		{
			showFlashRequirements();
		}

		<?php
		/*
			10/04/2011:
			Selene came up with this is terrible hack. It's necessary to prevent Facebook from being "helpful" (as of Sept 20th, 2011) by hiding
			the flash window when a FB credits purchase window comes up. IE has problems un-hiding it.
		*/
		?>

		var flashContent = document.getElementById('flashcontent');
		for (var i = 0; i < flashContent.childNodes.length; ++i)
		{
						if (flashContent.childNodes[i].nodeName == "PARAM" &&
										flashContent.childNodes[i].name == "wmode") {
										flashContent.childNodes[i].value = "opaque";
						}
		}
	}

	// Vars necessary for facebook integration bar processing.
	var fbVars = {};
	fbVars['user_id']="<?php echo $user_id; ?>";
    fbVars['app_id']="<?php echo $app_id; ?>";
    fbVars['auth_token']="<?php echo $oauth_token; ?>";

	$(document).ready(function(){

		var params = {
			quality: "high",
			scale: "noscale",
			allowscriptaccess: "always",
			bgcolor: "#000000",
			wmode: "direct"
		};

		params.allowFullscreen = "true";

		var flashvars = {
			siteXML: "xml/site.xml"
		};

		flashvars['signed_request']="<?php echo $signed_request; ?>";
		flashvars['user_id']="<?php echo $user_id; ?>";
		flashvars['auth_token']="<?php echo $oauth_token; ?>";

		flashvars['app_id']="<?php echo $app_id; ?>";
		flashvars['api_url']="<?php echo $server_main; ?>";
		flashvars['api_root']="<?php echo $server_root; ?>";
		flashvars['client_url']="<?php echo $client_folder_url; ?>";
		flashvars['gaiaSiteVersion']="<?php echo $version_string; ?>";
		flashvars['siteXML']="<?php echo $client_folder_url; ?>xml/site.xml";
		flashvars['uid']="<?php echo $referral_uid; ?>";

		flashvars['debug_panel']="true";

		var attributes = {
			id: "flashcontent",
			name: "flashcontent"
		};

		if (swfobject.hasFlashPlayerVersion(min_flash_version))
		{
			swfobject.embedSWF("<?php echo $client_folder_url; ?>Main.swf?<?php echo time();?>", "flashcontent", "760", "726", min_flash_version, "<?php echo $client_folder_url; ?>expressInstall.swf", flashvars, params, attributes, onSWFEmbed);
		}
		else
		{
			showFlashRequirements();
		}

	});

	// Update the 'progress' for this user in the fan_bar.
	$(document).ready(function() {
		(function() {
			var e = document.createElement('script');
			e.src = document.location.protocol + '//connect.facebook.net/en_US/all.js';
			e.async = true;
			document.getElementById('fb-root').appendChild(e);
		}());

		setupProgressBar();

		// Hide the progress completed check marks.  Will be overridden if necessary in
		// button specific functions below.
//		$('div#dndFanBarBtnLikeTheGame_CheckMark').hide();
//		$('div#dndFanBarBtnUpdates_CheckMark').hide();
//	   	$('div#dndFanBarBtnPublish_CheckMark').hide();
//	   	$('div#dndFanBarBGLikeTheGameComplete').hide();
//	   	$('div#dndFanBarBGUpdatesComplete').hide();
//	   	$('div#dndFanBarBGPublishComplete').hide();

		flashElem = document.getElementById('flashcontent');
 	});


</script>
<style type="text/css">
	/*hide from ie on mac\*/
	#flashcontent_container {
		width: 760px;
		height: 726px;
		top:170px;
		left:0px;
		position:absolute;
		z-index:0;
		background-color:#000000;
	}

	#flashcontent_background {
		width: 760px;
		height: 726px;
		background-image: url( 'assets/fan_bar/splash.jpg' );
		background-repeat: none;
	}

	#noflash
	{
		width: 760px;
		position:absolute;
		top: 0px;
		left: 0px;
		background-color: #FFFF00;
	}

	/* end hide */
	body {
		margin: 0;
		padding: 0;
		background-color: #FFFFFF;
	}

</style>
</head>
<body>
	<div id="fb-root"></div>
	<script type="text/javascript">


	window.fbAsyncInit = function() {
		FB.Event.subscribe('edge.create', function(href, widget) {
			testProgress(fbVars['user_id']);
		});

		FB.Event.subscribe('edge.remove', function(href, widget) {
			testProgress(fbVars['user_id']);
		});

		// HACK - Hide the input blocker when any FB dialog is closed. 3/25/11
		var _fbRemoveFunction = FB.Dialog.remove;

		FB.Dialog.remove = function(args) {
			_fbRemoveFunction.call( this, args );
			enableAllInput();
		}

		FB.Event.subscribe('auth.login', function(response) {
			testProgress(fbVars['user_id']);
		});

		FB.Event.subscribe('auth.authResponseChange', function(response) {
			testProgress(fbVars['user_id']);
		});

		setTimeout("testProgress(fbVars['user_id'])", 3000);

		FB.Canvas.setSize({ height: 990 });

		FB.init({
			appId: '<?php print $app_id; ?>',
			status: true,
			cookie: true,
			oauth: true,
			xfbml: true});

		setTimeout("sendInfo()", 3000);
	};

	//149937631721176
	(function() {
		var e = document.createElement('script'); e.async = true;
		e.src = document.location.protocol +
		  '//connect.facebook.net/en_US/all.js';
		document.getElementById('fb-root').appendChild(e);
	}());


	</script>

	<img src="<?php echo $cl_kontagentpath;?>pgr/?s=<?php echo $user_id;?>&ts=<?php echo time();?>" style="display: none;">

	<?php

	$is_install = false;

	// Only place tracking pixel on installs.
	if ( isset($_GET["installed"]) && $_GET["installed"] == 1)
	{
		$is_install = true;
	}

	if (isset($tracking_tag))
	{
		switch ($tracking_tag)
		{
			case 'spruce':
				if ($is_install)
				{
				?>
				<img style="display:none" src="https://bp-pixel.socialcash.com/100527/pixel.ssps?adid=<?php echo $kt_st3;?>&sid=<?php echo $user_id;?>">
				<?php
				}
				break;
			case 'nanigans':
				if ($is_install)
				{
				?>
				<img style="display:none" src="//api.nanigans.com/event.php?app_id=4025&type=install&name=main&user_id=<?php echo $user_id;?>&nan_pid=<?php echo $kt_st3;?>">
				<?php
				}
				break;
			case 'adparlor':
				?>
				<img style="display:none" src="https://fbads.adparlor.com/conversion.php?adid=741" alt="AP_pixel" height="1" width="1">
				<?php
				break;
			case 'tbg':
				if ($is_install)
				{
				?>
				<img style="display:none" src="https://altfarm.mediaplex.com/ad/bk/19139-135737-3840-0?Confirmation_Page=1&mpuid=" height="1" width="1" alt="Mediaplex_tag">
				<?php
				}
				break;
			case 'cpmstar':
				if ($is_install)
				{
				?>
				<img src="https://server.cpmstar.com/action.aspx?advertiserid=1779&gif=1">
				<?php
				}
				break;
			case 'adknowledge':
				if ($is_install)
				{
				?>
				<img height='1' width='1' border='0' src='https://socpixel.bidsystem.com/onAdConv.php?aid=20238&conType=signup&conValue=0.60&conDays=30' />
				<?php
				}
				break;
		}
	}

	?>

	<!-- Container div to enforce all of our elements staying within bounds. -->
	<!--
	<div id="likebar">
	<fb:like href="http://www.facebook.com/apps/application.php?id=<?php print $app_id;?>" show_faces="true" send="false"></fb:like>
	</div>
	-->
	<div id="dndBody">
		<div id="dndGame" style="height:827px; width:760px; top:30px; position:absolute; left:0px; z-index:0;">
			<div id="dndStartUpBarBG">

				<div id="dndAdventureProgressTopBorder"></div>

				<!--  All % bars are loaded, jQuery hides/displays the correct one. -->
				<div id="dndStartUpBarProgressionTxt">Complete the steps to defeat the Dragon and claim the treasure!</div>

				<!--  Installed game! is always displayed with a chec kmark. -->
				<div id="dndFanBarBGInstalled"></div>
				<div id="dndFanBarBGInstalledComplete"></div>

				<div id="dndFanBarTxtInstalled" title="Install Heroes of Neverwinter on Facebook">Installed D&D</div>
				<div id="dndFanBarBGLikeTheGame"></div>
				<div id="dndFanBarBGLikeTheGameComplete"></div>


				<div id="dndFanBarTxtLikeTheGame" title="Like the Game on Facebook">Like the Game</div>
				<div id="dndFanBarTxtUpdates" title="Connect Heroes of Neverwinter to a personal email account to receive updates">Get Email Updates</div>
				<div id="dndFanBarTxtPublish" title="Allow Heroes of Neverwinter to broadcast, post to his, her wall on Facebook.">Post to your Wall</div>

				<div id="dndFanBarBGUpdates"></div>
				<div id="dndFanBarBGUpdatesComplete"></div>


				<div id="dndFanBarBGPublish"></div>
				<div id="dndFanBarBGPublishComplete"></div>

				<div id="dndFanBarBtnLikeTheGameTxt" title="Like the Game on Facebook">Like the Game</div>
				<div id="dndFanBarBtnUpdatesTxt" title="Connect Heroes of Neverwinter to a personal email account to receive updates">Get Email Updates</div>
				<div id="dndFanBarBtnPublishTxt" title="Allow Heroes of Neverwinter to broadcast, post to his, her wall on Facebook.">Post to your Wall</div>


				<div id="dndFanBarBGGoalSetComplete"></div>

				<div id="dndAdventureBarToggle"></div>
				 <div id="dndAdventureBarToggleGoalUp"></div>
				 <div id="dndAdventureBarToggleGoalDown"></div>

			</div>
			<div id="Dungeon">

				<div id="dndAdventurersDungeon"></div>
				<div id="dndAdventurersForest"></div>
				<div id="dndAdventurersMountain"></div>

				<div id="dndStartUpBarDragon"></div>
				<div id="dndStartUpBarDragonDefeated"></div>

				<div id="dndStartUpBarOgre"></div>
				<div id="dndStartUpBarOgreDefeated"></div>

				<div id="dndStartUpBarKobold"></div>
				<div id="dndStartUpBarKoboldDefeated"></div>

				<div id="dndStartUpBarVampire"></div>
				<div id="dndStartUpBarVampireDefeated"></div>
				
				<div id="dndStartUpBarBeholder"></div>
				<div id="dndStartUpBarBeholderDefeated"></div>
				
				<div id="dndStartUpBarSpider"></div>
				<div id="dndStartUpBarSpiderDefeated"></div> 
				<div id="dndStartUpBarSkeleton"></div> 
				<div id="dndStartUpBarSkeletonDefeated"></div> 
				<div id="dndStartUpBarMindflayer"></div> 
				<div id="dndStartUpBarMindflayerDefeated"></div>

				<div id="dndAdventureProgress01"></div>
				<div id="dndAdventureProgress02"></div>
				<div id="dndAdventureProgress03"></div>
				<div id="dndAdventureProgress04"></div>
				<div id="dndAdventureProgress05"></div>

				<div id="dndAdventureProgress01Forest"></div>
				<div id="dndAdventureProgress02Forest"></div>
				<div id="dndAdventureProgress03Forest"></div>
				<div id="dndAdventureProgress04Forest"></div>
				<div id="dndAdventureProgress05Forest"></div>

				<div id="dndAdventureProgress01Mountain"></div>
				<div id="dndAdventureProgress02Mountain"></div>
				<div id="dndAdventureProgress03Mountain"></div>
				<div id="dndAdventureProgress04Mountain"></div>
				<div id="dndAdventureProgress05Mountain"></div>

				<div id="dndAdventureProgressBottomBorder"></div>
			</div>


			<div id="flashcontent_container">
				<!--SEO-->

				<div id="noflash" style="visibility: hidden;">
					<h1>You need to upgrade your Flash Player</h1>
					<p><b>Dungeons & Dragons: Heroes of Neverwinter</b> requires the <a href="http://www.adobe.com/go/getflashplayer" target="_blank">latest version of Adobe Flash Player</a>.</p>
					<!--<p><a href="index.html?detectflash=false">bypass the detection</a></p>-->
				</div>

				<div id="flashcontent_background">
					<div id="flashcontent"></div>
				</div>
			</div>

			<div id="helpguide" style="visibility: hidden;">
			<iframe src="assets/helpguide/helpguide.php"></iframe>
			</div>


	<!--  <div id="dndFrameFooter"></div> -->

	</div> <!-- End  <div id="dndGame"> -->


	<div id="likeGamePopupDialog" style="display: none;">
		<div style="color: rgb(255, 255, 255); background-color: rgb(109, 132, 180); font-size: 15px; font-weight: bold; padding: 5px; text-align: left;">Like the Game</div>
		<div id="fb-root"></div>
		<fb:like-box
			href="http://www.facebook.com/apps/application.php?id=<?php print $app_id;?>"
			width="500"
			show_faces="true"
			border_color=""
			stream="true"
			header="false">
		</fb:like-box>
	</div>
	</div> <!--  end div dndBody -->

	<div id="serverFullNotification" style="display: none">
	    We're sorry, Heroes of Neverwinter Closed Beta is currently at capacity!  Please watch our <a href="http://www.facebook.com/HeroesOfNeverwinter">home page</a> for further updates!
	</div>

</body>
</html>

