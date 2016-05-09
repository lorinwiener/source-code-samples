<?php
//_________________________________________________________________________________________________
//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
//  Confidential
//
//  userReadPublishActions.php
//
//  © Liquid Entertainment
//
//  Description:
//   reads a user's Facebook publish_action permissions.
//_________________________________________________________________________________________________
//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

/**
 * Reads a user's Facebook publish_action permissions
 * 
 * @param int - $parm_user_id
 */

 
require_once 'private/util/globals.php';
require_once 'private/user/userDAO.php';
require_once 'private/user/userReadUser.php';
require_once 'private/util/log_state.php';


$param_user_id = $_GET['user_id'];

function userReadPublishActions($arg_user_id) {

	global $l;
	
	$user_dao = userDAO::instance();
	
	$success = userReadUserByFacebookID($arg_user_id, $user);
	// Get a lock
	$success = $user_dao->getUserLock($user->user_id);
	if(!$success){
		$l->log(" >> userUpdatePublishActions.php->userUpdatePublishActions: could not lock user requested: $user->user_id", PEAR_LOG_ERR );
		return false;
	}
	
	$success = $user_dao->readPublishActionsByID($user->user_id, $publish_actions);
	// Clear a lock
	if(!$success){
		$user_dao->clearUserLock($user->user_id);
		$l->log(" >> userUpdatePublishActions->userUpdatePublishActions: failed to find user in facebook_users with user_id=$user->user_id", PEAR_LOG_ERR );
		return false;
	}
	
	$user_dao->clearUserLock($user->user_id);
	
	return $publish_actions->publish_actions;
	
}

userReadPublishActions($param_user_id);

?>
