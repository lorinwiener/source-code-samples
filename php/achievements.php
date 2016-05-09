<?php
//_________________________________________________________________________________________________
//ппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп
//  Confidential
//
//  achievements.php
//
//  й Liquid Entertainment
//
//  Description:  object representing the all achievements for a user.
//_________________________________________________________________________________________________
//ппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппппп

/**
 * reads all the achievements and a user's current status for each achievement.
 */
class achievements{
	
	public $contents;
	
	function __construct($user_id) {
		$this->load($user_id);
	}

	public function load($user_id) {
		
		$achievements_DAO = achievementsDAO::instance();
		$success = $achievements_DAO->readUserAchievements( $user_id, $result );
		if( $success ){
			$this->contents = $result;
		}else{
			global $l;
			$l->log(" >>achievements->load: failed to load achievements", PEAR_LOG_ERR );
		}
	}
	
	public function loadNPCSet()
	{
		$achievements_DAO = achievementsDAO::instance();
		$success = $achievements_DAO->readNPCAchievements( $result );
		if( $success ){
			$this->contents = $result;
		}else{
			global $l;
			$l->log(" >>achievements->load: failed to load achievements", PEAR_LOG_ERR );
		}
	}
}

?>