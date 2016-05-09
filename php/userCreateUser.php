<?php
//_________________________________________________________________________________________________
//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
//  Confidential
//
//  userCreateUser.php
//
//  © Liquid Entertainment
//
//  Description:
//   create new users
//_________________________________________________________________________________________________
//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

require_once $GLOBALS['application_dir'].'/private/tutorials/tutorialsUnseen.php';

/**
 * function for creating users.  Using the user object is prefered
 *
 * @param $facebookID
 */
function userCreateUser($facebookID, &$result){
	$user_dao = userDAO::instance();
	global $isloadtest;
	global $l;
	
	if($isloadtest){
		$fbProfile = new stdClass();
		$fbProfile->first_name = "load";
		$fbProfile->last_name = "test";
		$fbProfile->email = '';	
	}else{
		global $message;
		if (isset($message->access_token) && $message->access_token != "fail"){
			$access_token = $message->access_token;
		}
		else {
			$access_token = false;
		}
		
		//query facebook, retry 3 times if facebook response doesnt work in 2 second intervals
		for ($tries=0; $tries< 3; ++$tries) {
			$success = $user_dao->readFacebookBasicProfile($facebookID, $access_token, $fbProfile);
			if ($success != false){
				break;
			}else{
			    // delay subsequent attempts to give Facebook a chance to fix their problem.
				usleep(($tries+1)*2000);
			}
		}
		
		if(!$success){
			if ($GLOBALS['isdebug'] || $GLOBALS['isloadtest']){
				//allow user to be created with blank name
				$fbProfile = new stdClass();
				$fbProfile->first_name = '';
				$fbProfile->last_name = '';
				$fbProfile->email = '';				
				global $l;
				$l->log("userCreateUser.php >> tried to create a user but can't get basic profile data for them");
			}else{
				global $l;
				$l->log("userCreateUser.php >> no profile for user and not in debug mode");
				return false;
			}
		}else {
			// Test users will return a success response but have no profile data set
			if ($GLOBALS['isdebug'] || $GLOBALS['isloadtest']) {
				if (!isset($fbProfile->first_name)) {
					$fbProfile->first_name = '';
				}
				if (!isset($fbProfile->last_name)) {
					$fbProfile->last_name = '';
				}
				if (!isset($fbProfile->email)) {
					$fbProfile->email = '';
				}
			}
		}
	}
	
	$success = $user_dao->create(
		$facebookID, 
		$fbProfile->first_name, 
		$fbProfile->last_name,
		$fbProfile->email, 
		$result);
	
	if(!$success){
		global $l;
		$l->log("userCreateUser.php >> user_dao->create failed");
		return false;
	}
	$user_id = $result;
	$success = $user_dao->readByUserID($user_id, $result);
	if(!$success){
		$l->log("userCreateUser.php >> user_dao->readByUserID failed");
		return false;
	}
	
	// Let Kontagent know that an install has occurred.
	require_once $GLOBALS['application_dir'] . '/private/kontagent/kontagent.php';
	$kontagent = kontagent::instance();
	$kontagent->customEvent($facebookID,
					"install",
					1,
					0,
					"game_installs",
					"",
					"");
	
	require_once $GLOBALS['application_dir'].'/private/ewallet/ewalletUserAddUpdateCurrency.php';
	
	//user_id
	
	
	// Give the user 100 gold.
	
	ewalletUserAddUpdateCurrency( $user_id, 1, 100 * 10, "Signup", false);
	
	// Give the user 10 diamonds.
	
	ewalletUserAddUpdateCurrency( $user_id, 2, 10, "Signup ", false);
	
	$success = tutorialsUnseenCreateEntries($user_id);
	if(!$success){
		$l->log("userCreateUser.php >> failed to create user tutorial entries");
		return false;
	}
	
	require_once $GLOBALS['application_dir'].'/private/gifts/giftsDAO.php';
	
	$giftsDAO = giftsDAO::instance();
	
	$success = $giftsDAO->transferGiftsFromFacebookUserToUser($facebookID);
	
	return true;
}


?>