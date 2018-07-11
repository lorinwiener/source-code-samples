/**
 * Called when the Ask Friends button is clicked through the LiquidExternalInterface.as call() in ItemActivationRequestPopus.as.
 * Opens a FB UI for inviting friends to help you activate an item.
 * */

// Called from the flash client. Requests an invite with a selector.
function askFriendsToHelpActivateItem(uid, oldItemId)
{
	disableAllInput();
	requestFriendsToHelpActivateItem(uid, null, oldItemId)	
}

// Prompts the user to send invites to friends to help activate an item.
function requestFriendsToHelpActivateItem(uid, recipient_ids, oldItemId)
{
	var data = {
				type: "askFriendsToHelpActivateItem",
				tag: uid,
				oldItemId: oldItemId,
				st1: "itemActivation",
				st2: "oldItemId_" + oldItemId,
				st3: ""
				};
	
	var params = {
		method: 'apprequests',
		message: "Hail friend! Come join me in D&D: Heroes of Neverwinter and help me activate an item!",
		data: JSON.stringify(data),
		title: 'Ask Friends to Activate an Item'
	};
	
	if (recipient_ids != null)
	{
		var uid_csv = "";
	
		var index = 0;
		
		for (index = 0; index < recipient_ids.length; index++)
		{
			var user_fbid = recipient_ids[index];
			uid_csv += user_fbid + ",";
		}
		
		params.to = uid_csv;
	}
	
	FB.ui(
		params,
		function (response) {
			if (response && response.request_ids) {
			
				sendKontagentMetric("ins/?s=" + fb_user_id + "&r=" + encodeURIComponent(response.request_ids) + "&u=" + encodeURIComponent(uid) + generateSubtypeString(data.st1, data.st2, data.st3));
				
			} else {
				
			}
			// Let's enable all input regardless of success or fail.
			enableAllInput();
		}
	);
}

/**
 * Called when the FriendsBar is clicked through the LiquidExternalInterface.as call().
 * Opens a FB UI for inviting friends.
 * */

// Called from the flash client. Requests an invite with a selector.
function invite(uid)
{
	disableAllInput();
	requestInvite(uid, null, null, "ingame")	
}

// Prompts the user to send invites.
function requestInvite(uid, recipient_ids, callback, invite_location)
{
	var data = {
				type: "invite",
				tag: uid,
				st1: "invite_" + invite_location,
				st2: "adventure_band",
				st3: ""
				};
	
	var params = {
		method: 'apprequests',
		message: "Hail friend! Come join me in D&D: Heroes of Neverwinter and together we'll battle monsters, loot treasure, and earn fame and glory!",
		data: JSON.stringify(data),
		title: 'Invite Friends to Play'
	};
	
	if (recipient_ids == null)
	{
		params.filters = ["app_non_users"];
	}
	else
	{
		var uid_csv = "";
	
		var index = 0;
		
		for (index = 0; index < recipient_ids.length; index++)
		{
			var user_fbid = recipient_ids[index];
			uid_csv += user_fbid + ",";
		}
		
		params.to = uid_csv;
	}
	
	FB.ui(
		params,
		function (response) {
			if (response && response.request_ids) {
				sendKontagentMetric("ins/?s=" + fb_user_id + "&r=" + encodeURIComponent(response.request_ids) + "&u=" + encodeURIComponent(uid) + generateSubtypeString(data.st1, data.st2, data.st3));
				
				if (callback != null)
				{
					callback(response);
				}
			}
			else
			{
				
			}
		}
	);
}

var scriptStartTime = (new Date()).getTime();
var timesCalled = 0;

var flashElem = null;

function addMethod(name)
{
//	alert("registering " + name + " on " + flashElem);
	if( flashElem == null ) {
		flashElem = gameSWF;//$("#flashcontent");
		console.log("Attempting to fetch: flashcontent "+flashElem);
	}
	console.log("registering " + name + " on " + flashElem);
	if (!flashElem.methods) {
		flashElem.methods = {};
	}
	if (!flashElem.methods[name]) {
		flashElem.methods[name] = true;
	}
	else
	{
		flashElem.methods[name] = true;
	}
}

function onCreditPurchaseSuccess(user_id, cost)
{
	switch (install_tag)
	{
		case 'nanigans':
			sendMetric( "//api.nanigans.com/event.php?app_id=4025&type=purchase&name=main&user_id=" + user_id + "&value=" + cost);
			break;
			
		case 'adparlor':
			sendMetric( "https://fbads.adparlor.com/Engagement/action.php?id=245&adid=741&vars=7djDxM/P1uDV4OfKs7SxjdbV1ObN4ebE3NXXz9jPwtjg1OTE58XK0Nni1Ky6vp7X3tnWwtbkwNrb5OTYs5aO1tfVtOfOqcC0" );
			break;
	}
}

function onTutorialComplete(user_id)
{
	switch (install_tag)
	{
		case 'nanigans':
			sendMetric( "//api.nanigans.com/event.php?app_id=4025&type=user&name=tutorial&user_id=" + user_id );
			break;
			
		case 'adparlor':
			sendMetric( "https://fbads.adparlor.com/Engagement/action.php?id=243&adid=741&vars=7djDxM/P1uDV4OfKs7+ntJDixuXg0OTZ2MnR1tLkwNPS49fX2NTBydPl0+WmvcGR68vV1cXi1dHU3ufX7KCSjdnjxsXh0ayzyA==" );
			break;
	}
}

function onCharacterCreated(user_id)
{
	switch (install_tag)
	{	
		case 'nanigans':
			sendMetric( "//api.nanigans.com/event.php?app_id=4025&type=user&name=create&user_id=" + user_id );
			break;
		
		case 'adparlor':
			sendMetric( "https://fbads.adparlor.com/Engagement/action.php?id=244&adid=741&vars=7djDxM/P1uDV4OfKs7+ntJDixuXg0OTZ2MnR1tLkwNPS49fX2NTBydPl0+WmvcGR68vV1cXi1dHU3ufX7KCSjdnjxsXh0ayzyA==" );
			break;
	}
}



function isCallbackRegistered(name)
{
	//var flashElem = document.getElementById("DNDflashcontent");
//	alert("checking for " + name + " on " + flashElem);
	console.log("checking for " + name + " on " + flashElem);
	if (timesCalled == 0 || timesCalled == 12) {
		console.log("flashElem: ");
		console.log(flashElem);
		console.log("flashElem["+name+"]: ");
		console.log(flashElem[name]);
		console.log("flashElem.methods: ");
		console.log(JSON.stringify(flashElem.methods));
		console.log("isCallbackRegistered has been called " + timesCalled + " times");
		loggedFlashElem = true;
	}
	if (timesCalled <= 12) {
		++timesCalled;
	}
	var status = flashElem.methods[name] != undefined && flashElem[name] != undefined && typeof(flashElem[name]) == "function";
//	alert('flashElem: ' + flashElem + ', flashElem['+name+']: ' + flashElem[name]);
	console.log('flashElem: ' + flashElem + ', flashElem['+name+']: ' + flashElem[name]);
	
	return status;
}


/** variables to save streamPublish attempts */
var old_streamAttachment;
var old_streamActionLink;
var old_streamTargetId;
var old_streamUserMessagePrompt;
var old_streamIsAutoPublish = false;

function streamPublish(attachment, actionLinks, targetId, userMessagePrompt, autoPublish) {
	disableAllInput();
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

function postStream(gift_id, identifier, title, message, link_text, icon_path, reward, token, uid)
{
	disableAllInput();
	
	var accept_url = "";
	
	if (identifier != "")
	{
		psr_st1_tag = "&psr_st1=" + identifier;
	}
	
	if (reward > 0)
	{
		accept_url = facebookUrl + 'claimloot.php?id=' + gift_id + '&token=' + token + "&uid=" + uid + psr_st1_tag;
	}
	else
	{
		accept_url = facebookUrl + '?uid=' + uid + psr_st1_tag;
	}
	
	if (icon_path)
	{
		// Prepend the icon url.
		icon_path = iconUrl + icon_path + ".png";
	}
	
	var params =
	{
		method: "feed",
		name: title,
		link: accept_url,
		picture: icon_path,
		user_message_prompt: "Enter a personalized message below:",
		caption: "Dungeons & Dragons: Heroes of Neverwinter",
		description: message,
		actions: [{name: link_text, link:accept_url}]
	};
	
	FB.ui(params,
		function (response) {
			if (response) {
				sendKontagentMetric("pst/?s=" + fb_user_id + "&u=" + uid + "&tu=stream&st1=" + identifier);
				sendKontagentMetric("evt/?s=" + fb_user_id + "&n=valid&st1=stream_post&st2=post_send&st3=" + identifier);
			}
			else
			{
				// Fail
				sendKontagentMetric("evt/?s=" + fb_user_id + "&n=invalid&st1=stream_post&st2=post_send&st3=" + identifier);
			}
			
			// Let's enable all input regardless of success or fail.
			enableAllInput();
		});
}

function notifyGift(uid, recipient_fb_ids)
{
	disableAllInput();

	// Retrieve the sender's data.
	FB.api("/me", function (response) {
	
		var data = {
				type: "gift",
				tag: uid,
				st1: "gift",
				st2: "",
				st3: ""
				};
	
		var params = {
			method: 'apprequests',
			to: recipient_fb_ids,
			message: response.name + ' has sent you a gift!',
			data: JSON.stringify(data),
			title: 'Send an optional Notification'
		};
		
		FB.ui(
			params,
			function (response) {
				if (response && response.request_ids) {
					sendKontagentMetric("ins/?s=" + fb_user_id + "&r=" + encodeURI(response.request_ids) + "&u=" + encodeURI(uid) + generateSubtypeString(data.st1, data.st2, data.st3));
				}
				else
				{
					// Fail
				}
				
				// Let's enable all input regardless of success or fail.
				enableAllInput();
			});
		});
}

function purchaseOfferWithCredits(offer, fbid) {
	disableAllInput();
	
	var params = {
		method: 'pay',
		order_info: offer,
		purchase_type: 'item'
	};
	
	FB.ui(params, onPurchaseOffer);

}

function onPurchaseOffer(response) {
	window.setTimeout(enableAllInput, 100);
}

function enableAllInput()
{
	document.getElementById('flashcontent').style.height = 726;
	
	// Try and catch these, because the callbacks might not be registered yet.
	try
	{
		document.getElementById('flashcontent').enableAllInput();
	}
	catch(error)
	{
	
	}
}

function disableAllInput()
{
	document.getElementById('flashcontent').style.height = 0; 
	
	// Try and catch these, because the callbacks might not be registered yet.
	try
	{
		document.getElementById('flashcontent').disableAllInput();
	}
	catch(error)
	{
	
	}
}

function showHelpGuide()
{
	document.getElementById('helpguide').style.visibility = "visible"; 
	disableAllInput();
}

function hideHelpGuide()
{
	document.getElementById('helpguide').style.visibility = "hidden"; 
	enableAllInput();
}

function sendInfo()
{
	FB.api("/me", function (response)
	{
		if (!response || response.error)
		{
			return;
		}
		
		if (response)
		{
			var birthday_year = "";
			var kontagent_url = "cpu/?s=" + fb_user_id;
			
			if (response.gender != null)
			{
				kontagent_url += "&g=" + response.gender;
			}
			
			if (response.locale != null)
			{
				var locale = response.locale.substr(3, 2);
				
				// Phillipines.
				if (locale == "PI")
				{
					locale = "PH";
				}
				
				kontagent_url += "&lc=" + locale;
			}
			
			if (response.birthday != null)
			{
				var birthday_array = response.birthday.split("/");
				
				if (birthday_array.length >= 3)
				{
					birthday_year = birthday_array[2];
					kontagent_url += "&b=" + birthday_year;
				}
			}
			
			sendKontagentMetric(kontagent_url);
		}
	});
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

	enableAllInput();
	if (tryAgain) {
		streamPublish(old_streamAttachment, old_streamActionLink, old_streamTargetId, old_streamUserMessagePrompt, false);
	}
}

function testPrint( msg ) {
	document.write( msg + "<br />" );
}

var receivedFull = false;
function showServerFull() {
    if (receivedFull) return;
    receivedFull = true;

    $("#dndGame").hide();
    $("#serverFullNotification").show();
    
}

function generateSubtypeString(st1, st2, st3)
{
	var url = "";
	
	if (st1 != null && st1.length > 0)
	{
		url += "&st1=" + encodeURIComponent(st1);
		
		if (st2 != null && st2.length > 0)
		{
			url += "&st2=" + encodeURIComponent(st2);
			
			if (st3 != null && st3.length > 0)
			{
				url += "&st3=" + encodeURIComponent(st3);
			}
		}
	}
	
	return url;
}

//console.log( "At the end of dndf.js" );
