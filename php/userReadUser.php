<?php
//_________________________________________________________________________________________________
//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
//  Confidential
//
//  userReadUser.php
//
//  © Liquid Entertainment
//
//  Description:
//   returns the complete user row from the facebook_users table for a given user_id
//_________________________________________________________________________________________________
//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

/**
 * returns the complete user row from the facebook_users table for a given user_id
 * also recalculates the user's current energy based on regeneration
 * 
 * @param $user_id
 * @param $result
 */
function userReadUser($user_id, &$result)
{
	$user_dao = userDAO::instance();
	$success = $user_dao->readByUserID($user_id, $result);
	if(!$success){
		return false;
	}
	// TODO: Implement User energy system?
	//updateUserEnergy($result);
	return true;
}

/**
 * returns the complete user row for a given facebook user_id
 * also recalculates the user's current energy based on regeneration
 * 
 * @param unknown_type $facebook_id
 * @param unknown_type $result
 */
function userReadUserByFacebookID($facebook_id, &$result)
{
	$user_dao = userDAO::instance();
	$success = $user_dao->readByFacebookID($facebook_id, $result);
	if(!$success){
		return false;
	}
	//updateUserEnergy($result);
	return true;
}


/**
 * returns the complete user row for a given facebook user_id
 * also recalculates the user's current energy based on regeneration
 * 
 * @param unknown_type $facebook_id
 * @param unknown_type $result
 */
function userReadUserByCharacterID( $userCharacterID, &$result )
{
	$user_dao = userDAO::instance();
	$success = $user_dao->readUserByCharacterID( $userCharacterID, $result );

	if( !$success ){
		return false;
	}
	
	return true;
}


/** 
 * Tests if the owner of a character is available to be a spectator.
 * */
function userCanBeSpectator( $playingUserID, $userCharacterID, &$spectatorResult ){
	global $l;
			
	$readSuccess = userReadUserByCharacterID( $userCharacterID, $result );
	if( $readSuccess ){
		if( $playingUserID == $result->user_id ){
			// Can't spectate our own session.
			$l->log("userCanBeSpectator: can't spectate our own session");
			$spectatorSuccess = false;
			return false;
		}
		
		require_once $GLOBALS['application_dir'].'/private/activityTimes/activityTimeDAO.php';
		require_once $GLOBALS['application_dir'].'/private/enums/enums.php';
		$activity_time_dao = ActivityTimeDAO::instance();
		$userActive = $activity_time_dao->isUserActive( $result->user_id, ServerSettings::USER_ACTIVE_WINDOW );
		if( $userActive ){
			$spectatorSuccess = true;
			$spectatorResult = new stdClass();
			$spectatorResult->owning_user_id = $result->user_id;
			$spectatorResult->playing_user_id = $playingUserID;
			$spectatorResult->success = $spectatorSuccess;
			// TODO: Fill in character name for notification?
			$spectatorResult->character_name = "none";
			
			return true;
		}
		else{
			$l->log("userCanBeSpectator: user not active");
			$spectatorSuccess = false;
			return false;
		}
	}
	
	return false;
}


/**
 * applies user energy regeneration to a specific user
 * intended to mostly be used locally, as a "private" function
 * 
 * @param $user
 */
//TODO: Implement User energy system?
/*
function updateUserEnergy(&$user){
	$processTime = time();
	if ($user->energy != $user->energy_max && $user->energy_last_updated + USER_ENERGY_REGEN_SECONDS < $processTime ){
		//user needs to regenerate energy
		$elapsed = $processTime - $user->energy_last_updated;
		$user->energy += floor($elapsed/USER_ENERGY_REGEN_SECONDS) * USER_ENERGY_REGEN_PER_TICK;
		if ($user->energy >= $user->energy_max){
			$user->energy = $user->energy_max;
			$user->energy_last_updated = $processTime;
		}else{
			$user->energy_last_updated += floor($elapsed/USER_ENERGY_REGEN_SECONDS) * USER_ENERGY_REGEN_SECONDS;
		}
		// update cache/db
		$user_dao = userDAO::instance();
		$success = $user_dao->updateUserEnergy($user->user_id, $user->energy, $user->energy_last_updated);
		if(!$success){
			global $l;
			$l->log(" >> userReadUser->updateUserEnergy: could not update user requested: ".$user->user_id, PEAR_LOG_ERR );
			return false;
		}
	}
	return true;
}
*/