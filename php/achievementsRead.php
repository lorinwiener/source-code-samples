<?php
//_________________________________________________________________________________________________
//ŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻ
//  Confidential
//
//  achievementsRead.php
//
//  İ Liquid Entertainment
//
//  Description:
//
//_________________________________________________________________________________________________
//ŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻŻ

/**
 * Read data for a user by their user_ID
 * @param int 			$item_id
 * @param unknown_type 	$result
 */
function achievementsReadByUser( $user_id, &$result ){

	$achievements_DAO = achievementsDAO::instance();

	$success = $achievements_DAO->readUserAchievements( $user_id, $result );

	return $success;
}

