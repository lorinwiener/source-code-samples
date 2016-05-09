<?php
//_________________________________________________________________________________________________
//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
//  Confidential
//
//  user.php
//
//  © Liquid Entertainment
//
//  Description:
//  user class
//_________________________________________________________________________________________________
//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

/**
 * user class - represents a user
 *
 * $fbID - int - The facebook ID of the user the user state is being generated for
 */
class user{
	public $user_id;
	public $facebookID;
	public $userCore;
	public $friends;
	public $achievements;
	public $achievement_sets;
	public $notifications;
	public $game_settings;
	public $unlocks;
	public $bonus_bar_progress;
	
	public function __construct($fbID){
		$this->load($fbID);
	}

	/**
	 * loads a user with a given facebook ID
	 *
	 * @param int $fbID
	 */
	public function load($fbID){
		global $l;

		$this->facebookID = $fbID;

		require_once $GLOBALS['application_dir'].'/private/user/userReadUser.php';

		require_once $GLOBALS['application_dir'].'/private/activityTimes/activityTimeDAO.php';
		$activityTimeDAO = ActivityTimeDAO::instance();

		if (!userDAO::instance()->existForFBUser($fbID, $data_exists))
		{
			throw new Exception('/private/user/user.php could not check existence of user by FB id');
		}
		
		if ($data_exists)
		{
			$success = userReadUserByFacebookID($fbID, $user);
		
			if (!$success)
			{
				throw new Exception('/private/user/user.php could not read user by facebook id');
			}
		
			$this->userCore = $user;
			$this->user_id = $user->user_id;
		}
		else
		{
			//new user
			require_once $GLOBALS['application_dir'].'/private/user/userCreateUser.php';
			$success = userCreateUser($fbID, $user);
			
			if(!$success)
			{
				throw new Exception('/private/user/user.php userCreateUser failed');
			}

			$this->userCore = $user;
			$this->user_id = $user->user_id;
		}
		
		// See if an entry exists for this user's activity times. If not, create new ones.
		if (!activityTimeDAO::instance()->existForUser($this->userCore->user_id, $data_exists))
		{
			throw new Exception('/private/user/user.php could not check existence of activity times');
		}
		
		if (!$data_exists)
		{
			//new user initialize activity times
			$success = $activityTimeDAO->createUserActivityTimes($this->userCore->user_id);
			if(!$success){
				throw new Exception('/private/user/user.php createUserActivityTimes failed');
			}
		}
		
		require_once $GLOBALS['application_dir'].'/private/achievements/achievementsDAO.php';
		
		if (!achievementsDAO::instance()->existForUser($this->userCore->user_id, $data_exists))
		{
			throw new Exception('/private/user/user.php could not check existence of achievements');
		}
		
		// If the database was checked correctly, but the data doesn't exist, create it.
		
		if (!$data_exists)
		{
			// new user achievements.
			require_once $GLOBALS['application_dir'].'/private/achievements/achievementsCreateNewUser.php';
			$success = achievementsCreateNewUser( $this->userCore->user_id );
			if( !$success )
			{
				throw new Exception('/private/user/user.php achievementsCreateNewUser failed');
			}
		}
		
		require_once $GLOBALS['application_dir'].'/private/gameSettings/gameSettingsDAO.php';
		
		if (!gameSettingsDAO::instance()->existForUser($this->userCore->user_id, $data_exists))
		{
			throw new Exception('/private/user/user.php could not check existence of game settings');
		}
		
		if (!$data_exists)
		{
			// new user game settings.
			require_once $GLOBALS['application_dir'].'/private/gameSettings/gameSettingsCreateNewUser.php';
			$success = gameSettingsCreateNewUser( $this->userCore->user_id );
			if( !$success )
			{
				throw new Exception('/private/user/user.php gameSettingsCreateNewUser failed');
			}
		}
		
		require_once $GLOBALS['application_dir'].'/private/bonusBar/bonusBarDAO.php';
		
		if (!bonusBarDAO::instance()->existForUser($this->userCore->user_id, $data_exists))
		{
			throw new Exception('/private/user/user.php could not check existence of bonus bar progress');
		}
		
		if (!$data_exists)
		{
			// new user game settings.
			require_once $GLOBALS['application_dir'].'/private/bonusBar/bonusBarCreate.php';
			$success = bonusBarCreateNewUser( $this->userCore->user_id );
			if( !$success )
			{
				throw new Exception('/private/user/user.php bonusBarCreateNewUser failed');
			}
		}

		// load friends
		global $message;
		if (isset($message->access_token) && $message->access_token != "fail"){
			try{
				$success = userDAO::instance()->createUserFriendsList(
					$fbID, $this->userCore->user_id, $message->access_token, $friends );
			}catch (Exception $e) {
				$success = false;
			}
			if($success){
				$this->friends = $friends;
				
				// Award achievements based on the dndffriends list size.
				require_once $GLOBALS['application_dir'].'/private/achievements/achievementsCredit.php';
				$band_count = count( $friends->dndfFriends );
				awardAdventureBandAchievement( $this->userCore->user_id, $band_count );
			}else{
				$friendsObj = new stdClass();
				$friendsObj->lastRefresh = time();
				$friendsObj->allFriends = array();
				$friendsObj->dndfFriends = array();
				$this->friends = $friendsObj;
			}
		}else{
			$friendsObj = new stdClass();
			$friendsObj->lastRefresh = time();
			$friendsObj->allFriends = array();
			$friendsObj->dndfFriends = array();
			$this->friends = $friendsObj;
		}
		
		// load notifications
		try{
			$this->notifications = new notifications($this->userCore->user_id);
		}catch (Exception $e) {
			throw new Exception('/private/user/user.php notifications failed');
		}

		// load unlocks
		require_once $GLOBALS['application_dir']."/private/unlocks/userUnlocks.php";
		try{
			$this->unlocks = new userUnlocks($this->userCore->user_id);
		}catch (Exception $e) {
			throw new Exception('/private/user/user.php unlocks failed');
		}
		
		
		// load current achievements
		try{
			$this->achievements = new achievements( $this->userCore->user_id );
		}catch (Exception $e) {
			throw new Exception('/private/user/user.php loading achievements failed');
		}

		// load achievement sets
		try{
			require_once $GLOBALS['application_dir'].'/private/achievements/achievementSets.php';			
			$this->achievement_sets = new achievementSets( $this->userCore->user_id );
		}catch (Exception $e) {
			throw new Exception('/private/user/user.php loading achievement sets failed');
		}
	
		// load game settings
		try{
			require_once $GLOBALS['application_dir'].'/private/gameSettings/gameSettings.php';			
			$this->game_settings = new gameSettings( $this->userCore->user_id );
		}catch (Exception $e) {
			throw new Exception('/private/user/user.php loading game settings failed');
		}
		
		// load game settings
		try{
			require_once $GLOBALS['application_dir'].'/private/bonusBar/bonusBarProgress.php';
			$this->bonus_bar_progress = new bonusBarProgress( $this->userCore->user_id );
		}catch (Exception $e) {
			throw new Exception('/private/user/user.php loading bonus bar progress failed');
		}
		
		// update user's email address if we have permission to access it
		userDAO::instance()->updateUserEmail($this->facebookID, $this->user_id);
		
		require_once $GLOBALS['application_dir'].'/private/achievements/achievementsCredit.php';
		$completed_acheivement = new stdClass();
		if ($this->userCore->unlimited_energy_purchased > 0 && achievementsCredit( AchievementTypes::ACHIEVEMENT_HaveADrink, $this->user_id, 1, true, $completed_achievement ))
		{
			require_once $GLOBALS['application_dir'] . '/private/kontagent/kontagent.php';
			require_once $GLOBALS['application_dir'] . '/private/user/userDAO.php';
			$kontagent = kontagent::instance();
			$kontagent->customEvent(
				$this->userCore->facebook_id,
				"grandfathered",
				0,
				$this->userCore->max_achieved_level,
				"goal_step_completions",
				"have_a_drink" );
		}
	}
}
?>
