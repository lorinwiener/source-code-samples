<?php
//_________________________________________________________________________________________________
//�������������������������������������������������������������������������������������������������
//  Confidential
//
//  achievementsCreateNewUser.php
//
//  � Liquid Entertainment
//
//  Description: creates an entry in the user_achievements table for new users.
//_________________________________________________________________________________________________
//�������������������������������������������������������������������������������������������������


/**
 * creates achievements for new users
 * 
 * @param $user_id
 */
function achievementsCreateNewUser( $user_id ){
	
	$success = achievementsDAO::instance()->createUserAchievements( $user_id );
	if( $success ){
		return true;
	}else{
		return false;
	}
}
?>