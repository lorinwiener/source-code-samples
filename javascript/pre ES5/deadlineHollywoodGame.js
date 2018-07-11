/**
 * Called when the FriendsBar is clicked through the LiquidExternalInterface.as call().
 * Opens a FB UI for inviting friends.
 * */
function invite( invite_tag )
{
	//console.log("<_scott_> invite() invite_tag is " + invite_tag );
	inviteFriends( invite_tag );
}


var scriptStartTime = (new Date()).getTime();

function addMethod(name)
{
	if (!flashElem.methods) {
		flashElem.methods = {};
	}
	if (!flashElem.methods[name]) {
		flashElem.methods[name] = true;
	}
}

function isCallbackRegistered(name)
{
	//var flashElem = document.getElementById("DHflashcontent");
	//alert("registering " + name + " on " + flashElem);
	if (timesCalled == 0 || timesCalled == 12) {
		//console.log(flashElem);
		//console.log(flashElem[name]);
		//console.log(flashElem.methods);
		//console.log("isCallbackRegistered has been called " + timesCalled + " times");
		loggedFlashElem = true;
	}
	if (timesCalled <= 12) {
		++timesCalled;
	}
	var status = flashElem.methods[name] != undefined && flashElem[name] != undefined && typeof(flashElem[name]) == "function";
	//alert('flashElem: ' + flashElem + ', flashElem['+name+']: ' + flashElem[name]);
	
	return status;
}


/** variables to save streamPublish attempts */
var old_streamAttachment;
var old_streamActionLink;
var old_streamTargetId;
var old_streamUserMessagePrompt;
var old_streamIsAutoPublish = false;

var dhFriends; // Friends of the user who already installed Deadline Hollywood
var nondhFriends; // Friends who don't use Deadline Hollywood
var requestDialog;
var publishActions;

// inviteFriends
// - Create an FBML-based popup inviting your friends to play DH
// NOTE: the request-form API is likely to change prior to the end the first half of 2010.
function inviteFriends( invite_tag ) {
	FB.api({
		method: 'batch.run',
		method_feed: ['method=friends.get', 'method=friends.getAppUsers'],
		},
		function (response) {
			var allFriends = $.parseJSON(response[0]);
			var appFriends = $.parseJSON(response[1]);
			if (appFriends === {}) appFriends = [];
			
			// Copy the app friends now before we modify the array
			dhFriends = appFriends.slice(0);
			var nonAppFriends = [];
			for (var i = 0; i < allFriends.length; ++i) {
				var usesApp = false;
				for (var j = 0; j < appFriends.length; ++j) {
					if (allFriends[i] == appFriends[j]) {
						usesApp = true;
						appFriends.splice(j, 1);
						break;
					}
				}
				
				if (!usesApp) {
					nonAppFriends.push(allFriends[i]);
				}
			}
			nondhFriends = nonAppFriends;
			createInviteForm( invite_tag );
		}
	);
	/*
	var sequencer = new FB.BatchSequencer();
	var pendingResult = FB.Facebook.apiClient.friends_getAppUsers(sequencer);

	// Given a sequencer that has been used for API calls, send on HTTP request to FB and
	// execute the callback. At the time of the callback, the result objects returned from the 
	// API calls will have values from the server.
	sequencer.execute(onResultsArrived);

	function onResultsArrived() {
		if (pendingResult.result.length > 0) {
			dhFriends = pendingResult.result.join(",");
		}
		else {
			dhFriends = ""; // Null string denoting no friends play the game.
		}
		createInviteForm();
	}
	*/
}

/** 
 * createInviteForm
 * Create the FBML form for inviting friends.
 * Pre-conditon: the friends_getAppUsers call has called this as a callback function.
*/
function createInviteForm( invite_tag ) {

	var title = "Come play Nikki Finke's new Deadline Hollywood Game! Pick a career: Actor, Writer, Director, Producer, Agent or Studio Exec and start clawing your way to the top!";
	var offset = { x: -55, y: -55 };
	var requestType = "Deadline Hollywood Game";
	// Specify the invitecallback.php file to be opened when the invite form is sent through to FB. 
	var actionUrl = siteRoot + 'invitecallback.php';
	// Specify the inviteaccepted.php file to be opened when the friend clicks the link to start playing DHD.
	var myUrl = facebookUrl + 'inviteaccepted.php?invite_tag=' + invite_tag;	
	var requestContent = title + '&lt;fb:req_choice url=&quot;' + myUrl + '&quot; label=&quot;Play Deadline Hollywood Game!&quot; /&gt;';

	//  must use 'target = _self' for this window to display and close correctly.
	var fbml = '';
	fbml += '   <div style="color: rgb(255, 255, 255); background-color: rgb(109, 132, 180); font-size: 15px; font-weight: bold; padding: 5px; text-align: left;">Invite your friends to play Deadline Hollywood Game!</div>'; 
	fbml += '   <fb:request-form target="_self" type="' + requestType + '" content="' + requestContent + '" action="' + actionUrl + '" invite="true" method="post" >';
	fbml += '       <div style="width: 625px; margin:0px auto">';
	fbml += '           <fb:multi-friend-selector exclude_ids="' + dhFriends + '" cols="3" showborder="false" actiontext="Select your friends to invite." target="_self"/>';
	fbml += '			<input name="sender_id" type="hidden" fb_protected="true" value=' + flashVars['user_id'] + '>';	
	fbml += '			<input name="invite_tag" type="hidden" fb_protected="true" value=' + invite_tag + '>';	
	fbml += '       </div>';
	fbml += '   </fb:request-form>';

	FB.ui(
		{
			method: 'fbml.dialog',
			fbml: fbml,
			width: 444,
			height: 370,
			size: {width: 444, height: 370},
			display: 'iframe'
		},
		function(response) {
			FB.Dialog.remove(FB.Dialog._active);
		}
	);
	
}

/**
 * Helper function for the invite dialogue to be closed from invitecallback.php. 
 * */
function closeInviteForm(){
	FB.Dialog.remove(FB.Dialog._active);
}


// sendGifts
// - Create an FBML-based popup for the user to send gifts to their friends.
// - Post-conditions: Clicking on 'Skip' or 'Send' will close the window and notify the user
function sendGift(giftText, giftToken, itemID, exclude_ids, singleRecipientUserId) {
		
	// TODO? get list of non-app-users to exclude them
	createGiftForm(giftText, giftToken, itemID, exclude_ids, singleRecipientUserId);
	
}

// createGiftForm
// - Create the FBML form for sending gifts to friends.
// Pre-conditon: the friends_getAppUsers call has called this as a callback function.
function createGiftForm(giftText, giftToken, giftID, exclude_ids, singleRecipientUserId) {

	var title = "Send your friends a gift!";
	var offset = { x: -60, y: -60 };
	var requestType = "Deadline Hollywood Game Gift";
	var actionUrl = siteRoot + 'giftcallback.php';
	var myUrl = facebookUrl + '?gift_token=' + giftToken + '&gift_id=' + giftID;
	var requestContent = giftText + '&lt;fb:req-choice url=&quot;' + myUrl + '&quot; label=&quot;Accept gift&quot; /&gt;';
	var maxFriends = 1;
	
	if (singleRecipientUserId != null) {
	
		FB.api("/me", function (response) {
			var data = {gift_id: giftID, gift_token: giftToken};
			var params = {
							method: 'apprequests',
							to: singleRecipientUserId,
							message: giftText,
							data: JSON.stringify(data),
							title: requestType
						 };
			FB.ui(params, function (response) {
					var idsArray = new Array();
					idsArray[ 0 ] = singleRecipientUserId;
					if (response != null) {
						$.get( actionUrl, { gift_id: giftID, sender_id: flashVars['user_id'], gift_token: giftToken, ids: idsArray }, function(data) {}, "json" );
					}
			});
		});

	} else {
	
		var fbml = '<div style="color: rgb(255, 255, 255); background-color: rgb(109, 132, 180); font-size: 15px; font-weight: bold; padding: 5px; text-align: left;">Send A Deadline Hollywood Game Gift</div>'; 
		fbml += '   <fb:request-form target="_self" type="' + requestType + '" content="' + requestContent + '" action="' + actionUrl + '" invite="false" method="post" >';
		fbml += '       <div style="width: 452px; margin:0px auto">';
		fbml += '           <fb:multi-friend-selector target="_self" exclude_ids="' + exclude_ids + '"  max="' + maxFriends + '" cols="3" rows="3" showborder="false" actiontext="Send a gift to your friend" import_external_friends="false" />';
		fbml += '			<input name="gift_id" type="hidden" fb_protected="true" value=' + giftID + '>';
		fbml += '			<input name="sender_id" type="hidden" fb_protected="true" value=' + flashVars['user_id'] + '>';
		fbml += '			<input name="gift_token" type="hidden" fb_protected="true" value=' + giftToken + '>';
		fbml += '       </div>';
		fbml += '   </fb:request-form>';
		fbml += '</div>';
	
		FB.ui(
			{
				method: 'fbml.dialog',
				fbml: fbml,
				width: 444,
				height: 370,
				size: {width: 444, height: 370},
				display: 'iframe'
			},
			function(response) {
				FB.Dialog.remove(FB.Dialog._active);
			}
		);
		
	}
}

/**
 * Helper function for the invite dialogue to be closed from giftcallback.php. 
 * */
function onGiftDialogClose() {
	FB.Dialog.remove(FB.Dialog._active);
}

function tellFlashFriends(friends) {
	var elem = flashElem;
	try {
		elem['giftCallback'].apply(elem, [friends]);
	}
	catch (e) {
		// alert(e);
	}
	FB.Dialog.remove(FB.Dialog._active);
}





// createCastOfferForm
// - Create the FBML form for sending gifts to friends.
// Pre-conditon: the friends_getAppUsers call has called this as a callback function.
function createCastOfferForm(userID) {
	//alert("createCastOfferForm()");
	var title = "Make an offer";
	var offset = { x: -60, y: -60 };
	var requestType = "DHD Cast";
	var actionUrl = 'http://dhd.localhost/test/posttest.php';
	var myUrl = 'http://dhd.localhost/test/posttest.php';
	var requestContent = giftText + '&lt;fb:req-choice url=&quot;' + myUrl + '&quot; label=&quot;Accept offer&quot; /&gt;';
	var maxFriends = 1;

	var fbml = '';
	fbml += '<fb:fbml>';
	fbml += '   <fb:request-form target="_self" type="' + requestType + '" content="' + requestContent + '" action="' + actionUrl + '" invite="false" method="post" >';
	fbml += '			<input name="ids[]" type="hidden" fb_protected="true" value=' + userID + '>';
	fbml += '   </fb:request-form>';
	fbml += '</fb:fbml>';

	// NOTE: FB.UI.FBMLPopupDialog seems to not be officially supported anymore -- should find a replacement
	requestDialog = new FB.UI.FBMLPopupDialog(title, fbml);

	requestDialog.setContentWidth(715);
	requestDialog.setContentHeight(560);

	requestDialog.set_offset(offset);
	alert("about to show request dialog()");
	
	requestDialog.show();
}





function streamPublish(attachment, actionLinks, targetId, userMessagePrompt, autoPublish) {
	var params = {
		method: 'stream.publish',
		attachment: attachment,
		action_links: actionLinks
	};
		
	if (targetId) {
		params.target_id = targetId;
	}
	
	if (userMessagePrompt) {
		params.user_message_prompt = userMessagePrompt;
	}
	
	FB.ui(
		params,
		onStreamPublish
	);
	
	// TODO: Check if the user has given publish permissions and use a Graph API POST if they have

}

/** 
* Callback for when the stream publish dialog has closed 
*/
function onStreamPublish(response) {
	var tryAgain = false;
	var isException = response != null;

	if (isException && old_streamIsAutoPublish) {
		tryAgain = true;
	}

	document.getElementById('DHflashcontent').enableAllInput();
	if (tryAgain) {
		streamPublish(old_streamAttachment, old_streamActionLink, old_streamTargetId, old_streamUserMessagePrompt, false);
	}
}

function testPrint( msg ) {
	document.write( msg + "<br />" );
}


// requestItemFB
// - Create an FBML-based popup for the user to request an item from their friends.
// - Post-conditions: Clicking on 'Skip' or 'Send' will close the window and notify the user
function requestItemFB( description ) {		
	var params = {
		method: "apprequests",
		title: "Deadline Hollywood Game Gift Request",
		message: description
	};
	
	FB.ui(params,
		function (response) {
				if (response) {
					
				}
				else
				{
					// Fail
				}
			})
}

/**
 *  Request a purchase with facebook credits
 */
function purchaseOfferWithCredits( offer, fbid ) {
	//disableAllInput();
	//alert("purchaseOfferWithCredits(offer=" + offer + ")");
	//$.get( siteRoot + 'facebookcallbacks/testprocesscredits.php', {"offer_id":offer, "fb_id": fbid}, onPurchaseOffer );

	var params = {
		method: 'pay',
		order_info: offer,
		purchase_type: 'item'
	};
	
	FB.ui( params, onPurchaseOffer );

}

function onPurchaseOffer( response ) {
	//enableAllInput();
}

function enableAllInput()
{
	document.getElementById( 'flashcontent' ).enableAllInput();
	document.getElementById( 'flashcontent' ).style.visibility = 'visible'; 
}

function disableAllInput()
{
	document.getElementById( 'flashcontent' ).disableAllInput();
	document.getElementById( 'flashcontent' ).style.visibility = 'hidden'; 
}

function postStoryReward( story_reward_id, token, title, description, image, tracking_tag )
{
	var accept_url = facebookUrl;
	if( story_reward_id > 0 ){
		accept_url = facebookUrl + '?story_reward=' + story_reward_id + "&reward_token=" + token + "&post_tag=" + tracking_tag;
	}
	else {
		accept_url = facebookUrl + "?post_tag=" + tracking_tag;
	}
	var image_url = serverRoot + 'images/StoryRewardImages/' + image + '.png';
	
	var params = {
		method: "feed",
		name: title,
		message: description,
		link: accept_url,
		picture: image_url,
		user_message_prompt: "Enter a personalized message below:",
		caption: "Deadline Hollywood Game",
		description: description,
		actions: [{name: "Claim!", link:accept_url}]
	};
	FB.ui(params,
		function (response) {
				if (response) {
					
				}
				else
				{
					// Fail
				}
			})
}

function readPublishActionsPermission()
{
	FB.api({ method: 'fql.query', query: 'SELECT publish_actions FROM permissions WHERE uid=me()' },
		function(response)
		{
			for(var key in response[0]) {
				if(response[0][key] === "1") {
					publishActions = true;
				} else {
					publishActions = false;
					displayPublishActionsPermissionsDialogue();
				}
			}
		});		
}

function postCareerChange(namespace, accessToken)
{
	if (publishActions == true) {
	
		var objectURL_01 = siteRoot + 'postCareerChange_01.php';
		var objectURL_02 = siteRoot + 'postCareerChange_02.php';
		var objectURL_03 = siteRoot + 'postCareerChange_03.php';
		var objectURL_04 = siteRoot + 'postCareerChange_04.php';
		
		var randomNumber = Math.floor(Math.random()*4) + 1;
		
		var randomObjectURL = "";
		
		switch(randomNumber)
		{
			case 1:
			  randomObjectURL = objectURL_01;
			  break;
			case 2:
			  randomObjectURL = objectURL_02;
			  break;
			case 3:
			  randomObjectURL = objectURL_03;
			  break;
			case 4:
			  randomObjectURL = objectURL_04;
			  break;
			default:
			  randomObjectURL = objectURL_01;
			  break;
		}	
		
		FB.api('/me/' + namespace + ':change?career=' + randomObjectURL + '&access_token=' + accessToken, 'post',
			function(response) {
				if (!response || response.error) {
					//alert('Facebook Ticker Post error occured');
				}
			});
			
	}
	
}

function postMovieRelease(namespace, accessToken)
{
	if (publishActions == true) {
	
		var objectURL_01 = siteRoot + 'postMovieRelease_01.php';
		var objectURL_02 = siteRoot + 'postMovieRelease_02.php';
		var objectURL_03 = siteRoot + 'postMovieRelease_03.php';
		
		var randomNumber = Math.floor(Math.random()*3) + 1;
		
		var randomObjectURL = "";
		
		switch(randomNumber)
		{
			case 1:
			  randomObjectURL = objectURL_01;
			  break;
			case 2:
			  randomObjectURL = objectURL_02;
			  break;
			case 3:
			  randomObjectURL = objectURL_03;
			  break;
			default:
			  randomObjectURL = objectURL_01;
			  break;
		}
		
		FB.api('/me/' + namespace + ':release?movie=' + randomObjectURL + '&access_token=' + accessToken, 'post',
			function(response) {
				if (!response || response.error) {
					//alert('Facebook Ticker Post error occured');
				}
			});
	}
}

function postReputationLevelLevelUp(namespace, accessToken)
{
	if (publishActions == true) {
	
		var objectURL_01 = siteRoot + 'postReputationLevelLevelUp_01.php';
		var objectURL_02 = siteRoot + 'postReputationLevelLevelUp_02.php';
		var objectURL_03 = siteRoot + 'postReputationLevelLevelUp_03.php';
		var objectURL_04 = siteRoot + 'postReputationLevelLevelUp_04.php';
		
		var randomNumber = Math.floor(Math.random()*4) + 1;
		
		var randomObjectURL = "";
		
		switch(randomNumber)
		{
			case 1:
			  randomObjectURL = objectURL_01;
			  break;
			case 2:
			  randomObjectURL = objectURL_02;
			  break;
			case 3:
			  randomObjectURL = objectURL_03;
			  break;
			case 4:
			  randomObjectURL = objectURL_04;
			  break;
			default:
			  randomObjectURL = objectURL_01;
			  break;
		}
		
		FB.api('/me/' + namespace + ':raise?reputation_level=' + randomObjectURL + '&access_token=' + accessToken, 'post',
			function(response) {
				if (!response || response.error) {
					//alert('Facebook Ticker Post error occured');
				}
			});
	}
}

function postCareerLevelLevelUp(namespace, accessToken)
{
	if (publishActions == true) {
	
		var objectURL_01 = siteRoot + 'postCareerLevelLevelUp_01.php';
		var objectURL_02 = siteRoot + 'postCareerLevelLevelUp_02.php';
		var objectURL_03 = siteRoot + 'postCareerLevelLevelUp_03.php';
		var objectURL_04 = siteRoot + 'postCareerLevelLevelUp_04.php';
		
		var randomNumber = Math.floor(Math.random()*4) + 1;
		
		var randomObjectURL = "";
		
		switch(randomNumber)
		{
			case 1:
			  randomObjectURL = objectURL_01;
			  break;
			case 2:
			  randomObjectURL = objectURL_02;
			  break;
			case 3:
			  randomObjectURL = objectURL_03;
			  break;
			case 4:
			  randomObjectURL = objectURL_04;
			  break;
			default:
			  randomObjectURL = objectURL_01;
			  break;
		}
		
		FB.api('/me/' + namespace + ':raise?career_level=' + randomObjectURL + '&access_token=' + accessToken, 'post',
			function(response) {
				if (!response || response.error) {
					//alert('Facebook Ticker Post error occured');
				}
			});
	}
}

function displayPublishActionsPermissionsDialogue()
{
	FB.login(function(response) {
		if (response.authResponse) {
			setPublishActions(response.authResponse.userID);
		}
	}, {scope: 'publish_actions'});
}

function setPublishActions(uid) {
	var query = FB.Data.query('select publish_actions from permissions where uid={0}', uid);
	query.wait(function(rows) {
		if (rows[0].publish_actions && rows[0].publish_actions != "0") 
		{
		  publishActions = true;
		} else {
		  publishActions = false;
		}
	});
}

function sendKontagentMetric( url )
{	
	var img = document.createElement('img');
	img.src = url;
}