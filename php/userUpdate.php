<?php
//_________________________________________________________________________________________________
//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
//  Confidential
//
//  userUpdate.php
//
//  © Liquid Entertainment
//
//  Description: update a user's data.
//_________________________________________________________________________________________________
//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯


/**
 * Accesor function to add a friend user_id to the user's dndfFriends list.
 */
//function userUpdateFriends(
//	$user_id,
//	$friend_user_id ){
//	
//	// Get the active character id.
//	require_once $GLOBALS['application_dir'].'/private/user/userDAO.php';	
//	$userDAO = userDAO::instance();
//	$success = $userDAO->userAddFriend( $user_id, $friend_user_id );	
//	
//	if( $success ){
//		// Log error.
//		global $l;
//		$l->log("userUpdateFriends >> success.");
//		return true;
//	}
//	else{
//		// Log error.
//		global $l;
//		$l->log("userUpdateFriends >> failed.");
//		return false;
//	}	
//}

function userGrantUnlimitedEnergy( $user_id, $value, &$result )
{
	require_once $GLOBALS['application_dir'].'/private/user/userDAO.php';	
	$userDAO = userDAO::instance();

	$success = $userDAO->userGrantUnlimitedEnergy( $user_id, $value, $result );
	
	if(!$success){
		global $l;
		$l->log(" >> userGrantUnlimitedEnergy: failed to update user_id=$user_id", PEAR_LOG_ERR );
		return false;	
	}

	return true;
}
?>
