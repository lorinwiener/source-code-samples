<?php
//_________________________________________________________________________________________________
//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
//  Confidential
//
//  achievementsCredit.php
//
//  © Liquid Entertainment
//
//  Description:  Credit a user with achievement progress and award it to them if it is complete.
//_________________________________________________________________________________________________
//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

require_once $GLOBALS['application_dir'].'/private/events/eventsAdd.php';
require_once $GLOBALS['application_dir'].'/private/characterSlots/characterSlotsDAO.php';
require_once $GLOBALS['application_dir'].'/private/monsterGroups/monsterGroupsDAO.php';
require_once $GLOBALS['application_dir'].'/private/adventureSlots/adventureSlotsDAO.php';
require_once $GLOBALS['application_dir'].'/private/bonusBar/bonusBarUpdate.php';

/**
 * credits the user for an achievement
 * 
 * @param $a_id
 * @param $user_id
 * @param $increment_amount
 */
function achievementsCredit( 
	$a_id, 
	$user_id, 
	$increment_amount = 1, 
	$send_event, 
	&$completed_achievement ){
		
	global $l;
	
	require_once $GLOBALS['application_dir'] . '/private/kontagent/kontagent.php';
	require_once $GLOBALS['application_dir'] . '/private/user/userDAO.php';
	$user_dao = userDAO::instance();
	$kontagent = kontagent::instance();
	
	$achievements_DAO = achievementsDAO::instance();
	
	$success = $achievements_DAO->readUserAchievements( $user_id, $userAchievements );
	if( !$success ){
		$l->log(" >> achievementsCredit.php: failed reading user acheivements for user id: $user_id", PEAR_LOG_ERR);
		return false;
	}
	
	// find the acheivement in the list
	foreach( $userAchievements as $singleAchievement ){
		if( isset($singleAchievement->a_id) && $singleAchievement->a_id == $a_id ){
			//check to see if we should discard this update
			if( $singleAchievement->is_complete == 1 && $singleAchievement->repeatable == 0 ){
				$l->log(" >> achievementsCredit.php: achievement was already completed and not repeatable: $a_id", PEAR_LOG_INFO);
				//discard this update
				return false;
			}else{
				// Check to see if we achieved something with this update.
				if( ( $singleAchievement->a_count + $increment_amount) >= $singleAchievement->required_count){

					$achievementTime = time();
					if( $singleAchievement->repeatable == 0 ){
						$success = $achievements_DAO->updateUserAchievement($a_id, $user_id, 1, $singleAchievement->required_count, $achievementTime, $achievementTime);
					}else{
						$achievCount = ( $singleAchievement->a_count + $increment_amount) - $singleAchievement->required_count;
						if( !isset( $singleAchievement->first_award_time ) ){
							$success = $achievements_DAO->updateUserAchievement($a_id, $user_id, 1, $achievCount, $achievementTime, $achievementTime);
						}else{
							$success = $achievements_DAO->updateUserAchievement($a_id, $user_id, 1, $achievCount, $singleAchievement->first_award_time, $achievementTime);
						}
					}
					if( !$success ){
						$l->log(" >> achievementsCredit.php: failed updating user acheivements for a_id:$a_id, user id: $user_id", PEAR_LOG_ERR);
						return false;
					}
					
					$fb_user_row = null;
					
					$user_dao->readByUserID($user_id, $fb_user_row);
					
					$event_name = strtolower($singleAchievement->name);
					
					$kontagent->customEvent($fb_user_row->facebook_id,
					"complete",
					1,
					$fb_user_row->max_achieved_level,
					"goal_completions",
					$singleAchievement->group_type . "_completions",
					$event_name);
					
					// Achievement items
					if( ( $singleAchievement->item1_reward > 0 ) &&
						( $singleAchievement->item1_reward_quantity > 0 )){
						require_once $GLOBALS['application_dir'].'/private/gifts/giftsPost.php';
						
						for ($i = 0; $i < $singleAchievement->item1_reward_quantity; $i++)
						{
							$success = sendGift($singleAchievement->item1_reward, -1, -1, $user_id, $result);
						}
						
						if(!$success){
							$l->log(" >> achievementsCredit.php: failed to credit item, user_id=$user_id, item1_reward:".$singleAchievement->item1_reward, PEAR_LOG_ERR );
						}
					}

					if( ( $singleAchievement->item2_reward > 0 ) &&
						( $singleAchievement->item2_reward_quantity > 0 )){
						require_once $GLOBALS['application_dir'].'/private/gifts/giftsPost.php';
						
						for ($i = 0; $i < $singleAchievement->item2_reward_quantity; $i++)
						{
							$success = sendGift($singleAchievement->item2_reward, -1, -1, $user_id, $result);
						}
						
						if(!$success){
							$l->log(" >> achievementsCredit.php: failed to credit item, user_id=$user_id, item2_reward:".$singleAchievement->item2_reward, PEAR_LOG_ERR );
						}
					}
										
					$l->log(" >> achievementsCredit.php: achievement completed succesfully: $a_id", PEAR_LOG_INFO);					
					$completed_achievement = $singleAchievement;
					$completed_achievement->is_complete = 1;
					
					// Update any user character slots which are associated with this achievement
					$characterSlotsDAO = characterSlotsDAO::instance();
					$success = $characterSlotsDAO->giveUserCharacterSlotsFromAchievement($user_id, $a_id);
					if( !$success ){
						$l->log(" >> achievementsCredit.php: failed updating character slots.", PEAR_LOG_ERR);
					}
					
					// Update monster groups
					$monsterGroupsDAO = monsterGroupsDAO::instance();
					$success = $monsterGroupsDAO->giveUserMonsterGroupsFromAchievement($user_id, $a_id);
					if (!$success)
					{
						$l->log(" >> achievementsCredit.php: failed updating monster groups.", PEAR_LOG_ERR);
					}
					
					// Update adventure slots
					$adventureSlotsDAO = adventureSlotsDAO::instance();
					$success = $adventureSlotsDAO->giveUserAdventureSlotsFromAchievement($user_id, $a_id);
					if( !$success){
						$l->log(" >> achievementsCredit.php: failed updating adventure slots.", PEAR_LOG_ERR);
					}
					
					if( $send_event ){
						$eventdata = Array();
						$eventdata["a_id"] = $a_id;
						$eventdata["user_id"] = $user_id;
						// Notification - achievment completed.
						eventsAdd( $user_id, new GameEvent(GameEvent::achievementAwarded), $eventdata, true );
						// Notification - achievement update.
						eventsAdd( $user_id, new GameEvent(GameEvent::achievementUpdate), $eventdata, false );
					}
					
					
					// Update bonus bar progress -- do this here so the events get credited in the right order
					if ($singleAchievement->group_type == 'bonusbar')
					{
						$l->log(" >> achievementsCredit.php: updating bonus bar " . $singleAchievement->sort_type . " with progress from achievement $a_id", PEAR_LOG_INFO);
						$success = updateBarProgress($user_id, $singleAchievement->sort_type, $a_id);
						if( $success){
						}else{
							$l->log(" >> achievementsCredit.php: failed updating bar progress for bar set ".$singleAchievement->sort_type, PEAR_LOG_ERR);
						}
					}
					
					return true;
				}else{

					// Credit acheivement, notifiy client of progress
					$success = $achievements_DAO->updateUserAchievement($a_id, $user_id, $singleAchievement->is_complete, $singleAchievement->a_count + $increment_amount, $singleAchievement->first_award_time, time());
					if(!$success){
						$l->log(" >> achievementsCredit.php: failed updating user acheivements for a_id:$a_id, user id: $user_id", PEAR_LOG_ERR);
						return false;
					}
					
					// Notification - achievement update.
					if( $send_event ){
						$eventdata = Array();
						$eventdata["a_id"] = $a_id;
						$eventdata["user_id"] = $user_id;
						$success = eventsAdd( $user_id, new GameEvent(GameEvent::achievementUpdate), $eventdata, false);
					}
				}
				
				return false;
			}
		}
	}
}

/**
 * Lookup function for matching an a_id by name.
 * 
 * @param 	$user_id			user to find data for.
 * @param	$achievementName	name to find.
 * @param	&$achievementID		found a_id, passed by reference.
 * 
 * */
function findAchievementIDByName( $user_id, $achievementName, &$achievementID ){

	global $l;
	
	$achievements_DAO = achievementsDAO::instance();
	
	$success = $achievements_DAO->readUserAchievements( $user_id, $userAchievements );
	if( !$success ){
		$l->log(" >> findAchievementIDByName.php: failed reading user achievements for user id: $user_id", PEAR_LOG_ERR);
		return false;
	}
	
	// find the acheivement in the list
	foreach( $userAchievements as $singleAchievement ){
		if( isset( $singleAchievement->name ) && $singleAchievement->name == $achievementName ){
			$achievementID = $singleAchievement->a_id;
			return true;
		}
	}
	
	return false;
}


/** 
 * Set the chestofwonders achievement count back to 1 and send an event to the client.
 * */
function resetChestOfWondersAchievement( $user_id ){
	
	$a_id = AchievementTypes::ACHIEVEMENT_Wonderful;
	
	// Reset the count to 1 if the this is not adding to sequentialdays.
	$setSuccess = setAchievementCount( $user_id, AchievementTypes::ACHIEVEMENT_Wonderful, 0 );

	if( $setSuccess ){
		// Notification - achievement update.
		$eventdata = Array();
		$eventdata["a_id"] = $a_id;
		$eventdata["user_id"] = $user_id;
		eventsAdd( $user_id, new GameEvent(GameEvent::achievementUpdate), $eventdata, false);
	}
}


/**
 * Sets the count for a specified user achievement.
 * */
function setAchievementCount( $user_id, $achievement_id, $count ){
	
	global $l;
	
	$achievements_DAO = achievementsDAO::instance();
	$achievementTime = time();
	
	// iscomplete is set to -1, which ignores updating the iscomplete value.
	$success = $achievements_DAO->readUserAchievements( $user_id, $userAchievements );
	
	if( !$success ){
		$l->log(" >> setAchievementCount.php: failed reading user acheivements for user id: $user_id", PEAR_LOG_ERR);
		return false;
	}
	
	foreach( $userAchievements as $singleAchievement )
	{
		if( isset($singleAchievement->a_id) && $singleAchievement->a_id == $achievement_id )
		{
			//check to see if we should discard this update
			if( $singleAchievement->is_complete == 1 && $singleAchievement->repeatable == 0 )
			{
				// Disallow the modification of unrepeatable, complete achievements.
				$l->log(" >> setAchievementCount.php: can't set achievement for already complete, nonrepeatable achievement_id: $achievement_id", PEAR_LOG_ERR);
				return false;
			}
			else
			{
				$success = $achievements_DAO->updateUserAchievement( 
					$achievement_id, 
					$user_id, 
					-1, 
					$count, 
					$achievementTime, 
					$achievementTime );
				
				if( !$success ){
					$l->log(" >> setAchievementCount.php: failed for user id: $user_id and achievement_id: $achievement_id", PEAR_LOG_ERR);
				}

				return $success;
			}
		}
	}
	
	return false;
}

/*** 
 * Helper function for awarding adventure band related achievements.
 * */
function awardAdventureBandAchievement( $user_id, $band_count ){
	
	
	// Set the achievement setAchievementCount
	
	setAchievementCount($user_id, AchievementTypes::ACHIEVEMENT_ComradeInArms, 0);
	$achievementUpdated = achievementsCredit(
			AchievementTypes::ACHIEVEMENT_ComradeInArms,
			$user_id,
			$band_count,
			true, 
			$completed_acheivement );
			
	setAchievementCount($user_id, AchievementTypes::ACHIEVEMENT_HeroInArms, 0);
	$achievementUpdated = achievementsCredit(
			AchievementTypes::ACHIEVEMENT_HeroInArms,
			$user_id,
			$band_count,
			true, 
			$completed_acheivement );
	
	// Goals tracking
	
	setAchievementCount($user_id, AchievementTypes::ACHIEVEMENT_AddFiveFriends, 0);
	$achievementUpdated = achievementsCredit(
			AchievementTypes::ACHIEVEMENT_AddFiveFriends,
			$user_id,
			$band_count,
			true, 
			$completed_acheivement );
			
	setAchievementCount($user_id, AchievementTypes::ACHIEVEMENT_AddTenFriends, 0);
	$achievementUpdated = achievementsCredit(
			AchievementTypes::ACHIEVEMENT_AddTenFriends,
			$user_id,
			$band_count,
			true, 
			$completed_acheivement );
}


?>