<?php
//_________________________________________________________________________________________________
//�������������������������������������������������������������������������������������������������
//  Confidential
//
//  achievementsDAO.php
//
//  Liquid Entertainment
//
//  Description:
//   
//_________________________________________________________________________________________________
//�������������������������������������������������������������������������������������������������

include $GLOBALS['application_dir']."/private/util/log_state.php";


class achievementsDAO{
	
	static private $_instance;
	private $_mc;
	private $_dbc;
	private $_l;
	
	private function __construct(){
		//set up memcache connection
		$this->_mc = memcache_connection::instance();

		//set up mysql connection
		$this->_dbc = mysql_connection::instance();
		
		//logging
		global $l;
		$this->_l = $l;
	}
	
	/**
	 * singleton function
	 */
	public static function instance()
	{
		if( !isset( self::$_instance ))
		{
			self::$_instance = new achievementsDAO();
		}
		return self::$_instance;
	}
	
	private function __clone()
	{
	}
	
	public function existForUser($user_id, &$result)
	{
		$key = "achievements:user:".$user_id;
		$data = $this->_mc->get( $key );
		
		if( !$data )
		{
			$dblayer = new db_connection($user_id);
            
			$querySuccess = $this->_dbc->query( $queryData, "SELECT ua_id FROM user_achievements WHERE user_id=" . $user_id . " LIMIT 1");
			
			if (!$querySuccess)
			{
				return false;
			}
			
			$result = (mysqli_num_rows($queryData) > 0);
			
			return true;
		}
		
		// If a memcache key exists, the settings exist for that user.
		return true;
	}
	
	/**
	 * creates acheivements for a new user
	 * 
	 * @param unknown_type $user_id
	 */
	public function createUserAchievements($user_id){
		// Ensure that achievements do not previously exist.
		
		$this->_dbc->push_connection($user_id);
		$querySuccess = $this->_dbc->query( $queryData, "SELECT ua_id FROM user_achievements WHERE user_id=" . $user_id);
		
		if ($querySuccess && mysqli_num_rows($queryData) == 0)
		{
			$key = "achievements:createALL";
			
			$data = $this->_mc->get($key);
			if( !$data ){
				$querySuccess = $this->_dbc->query( $queryData, "SELECT a_id FROM achievements");
				
				if( !$querySuccess ){
					$this->_l->log(" >> achievementsDAO->createUserAchievements: failed to select achievements", PEAR_LOG_ERR );
					$this->_dbc->pop_connection();
					return false;
				}
				
				$data = "";
				while( $achievementData= $queryData->fetch_object()){
					$data .= "(USER_ID," . $achievementData->a_id . "),";
				}
				if( strlen($data) > 0 ){
					$data = rtrim( $data, "," );
				}
				
				$this->_mc->set( $key, $data, MEMCACHE_COMPRESSED, time() + 60 * 60 * 24 );
			}
			
			if( strlen($data) > 0 ){
				$insertAchievements = str_replace( "USER_ID", $user_id, $data );
				
				$querySuccess = $this->_dbc->query( $result,
					"INSERT INTO user_achievements (user_id, a_id) VALUES ".$insertAchievements );
				if( !$querySuccess ){
					$this->_l->log(" >> achievementsDAO->createUserAchievements: failed to insert user achievements for user_id=$user_id, insertAchievements=$insertAchievements", PEAR_LOG_ERR );
					$this->_dbc->pop_connection();
					return false;
				}
				$this->_dbc->pop_connection();
				return true;	
			}
			$this->_dbc->pop_connection();
			return true;
		}
		else
		{
			$this->_dbc->pop_connection();
			$this->_l->log(" >> achievementsDAO->createUserAchievements: achievements already exist for user_id=$user_id", PEAR_LOG_ERR );
			return false;
		}
	}
	
	
	public function readAchievementIDs(&$result)
	{
		$key = "achievements:createALL";
			
		$data = $this->_mc->get($key);
		if( $data ){
			$result = $data;
			return true;
		}
		
		$this->_dbc->connect_random_db();
		$querySuccess = $this->_dbc->query( $queryData, "SELECT a_id FROM achievements");
	
		if( !$querySuccess ){
			$this->_l->log(" >> achievementsDAO->readAchievementIDs: failed to select achievements", PEAR_LOG_ERR );
			$this->_dbc->pop_connection();
			return false;
		}
	
		$data = array();
		while( $achievementData = $queryData->fetch_object()){
			array_push($data, $achievementData->a_id);
		}
		
		$this->_mc->set( $key, $data, MEMCACHE_COMPRESSED, time() + 60 * 60 * 24 );
		$this->_dbc->pop_connection();
		$result = $data;
		return true;
	}
	
	
	public function createMissingAchievements($user_id)
	{
		
		$success = $this->readAchievementIDs($achievementIDs);
		
		if (!$success)
		{
			$this->_l->log(" >> achievementsDAO->createMissingAchievements: could not read achievements to create", PEAR_LOG_ERR );
			return false;
		}
		
		$success = $this->readUserAchievements( $user_id, $userAchievements );
		
		if (!$success)
		{
			$this->_l->log(" >> achievementsDAO->createMissingAchievements: could not read user achievements", PEAR_LOG_ERR );
			return false;
		}
		
		
		if (count($achievementIDs) == count($userAchievements))
		{
			// Nothing to update!
			return true;
		}
		
		$missingIDs = array();
		foreach ($achievementIDs as $a_id)
		{
			$foundID = false;
			foreach ($userAchievements as $user_ach)
			{
				if ($user_ach->a_id == $a_id)
				{
					$foundID = true;
					break;
				}
			}
			
			if (!$foundID)
			{
				array_push($missingIDs, $a_id);
			}
		}
		
		if (count($missingIDs) == 0)
		{
			$this->_l->log(" >> achievementsDAO->createMissingAchievements: user $user_id already has entries for all achievements. Achievement count: ".count($achievementIDs).", user entry count: ".count($userAchievements), PEAR_LOG_ERR );
			return false;
		}
		
		$insertString = "INSERT INTO user_achievements (user_id, a_id) VALUES ";
		$valueString = "($user_id, ";
		$valueString .= implode("),($user_id, ", $missingIDs);
		$valueString .= ")";
		
		$dblayer = new db_connection($user_id);
		$success = $this->_dbc->query($insertResult, $insertString . $valueString);
		
		if (!$success)
		{
			$this->_l->log(" >> achievementsDAO->createMissingAchievements: could not insert achievements for user $user_id! (values: $valueString )", PEAR_LOG_ERR );
			return false;
		}
		
		$key = "achievements:user:".$user_id;
		$this->_mc->delete($key);
		return true;
	}
	
	/**
	 * Generates and caches off a complete set of achievement data.
	 * 
	 * @param  $result
	 */
	 
	public function readNPCAchievements( &$result ){
		$key = "achievements:npc_user";
		
		// Read in a complete set of achievement data.
		
		$this->_dbc->push_connection(rand());
		$data = $this->_mc->get($key);
		if (!$data) {
			$querySuccess = $this->_dbc->query( $queryData,
				"SELECT *, required_count as a_count, 1 as is_complete, 0 as first_award_time, 0 as update_time FROM achievements ORDER BY a_id ASC");

			if ($querySuccess)
			{
				$result = array();
				while( $data = $queryData->fetch_object()){
					array_push($result, $data);
				}
				$this->_mc->set($key, $result, MEMCACHE_COMPRESSED, time() + 60 * 60 * 24);
				$this->_dbc->pop_connection();
				return true;
			}
			else
			{
				$result = -1;
				$this->_l->log(" >> achievementsDAO->readNPCAchievements: could not retrieve achievements for npc", PEAR_LOG_ERR );
				$this->_dbc->pop_connection();
				return false;
			}
		}else{
			$result = $data;
			$this->_dbc->pop_connection();
			return true;
		}
	    $this->_dbc->pop_connection();
	}
	
	/**
	 * reads a user's current acheivement state.  Includes detailed acheivement information.
	 * memcache backed
	 * 
	 * @param  $user_id
	 * @param  $result
	 */
	public function readUserAchievements( $user_id, &$result ){
		$key = "achievements:user:".$user_id;
		
		$this->_dbc->push_connection($user_id);
		$data = $this->_mc->get($key);
		if (!$data) {
			$querySuccess = $this->_dbc->query( $queryData,
				"SELECT * FROM achievements a LEFT JOIN user_achievements ua
				ON a.a_id = ua.a_id WHERE ua.user_id = ?", $user_id);
			if ($querySuccess){
				
				// If the user has no achievements, we should create some for them.
				if (mysqli_num_rows( $queryData ) <= 0)
				{
				//	if ($this->createUserAchievements($user_id))
				//	{
				//	    $this->_dbc->pop_connection();
				//		return $this->readUserAchievements( $user_id, $result);
				//	}
				//	else
					{
						$result = -1;
						$this->_l->log(" >> achievementsDAO->readUserAchievements: user had no achievement data and could not create: $user_id", PEAR_LOG_ERR );
					    $this->_dbc->pop_connection();
						return false;
					}
				}
				
				// This code only gets executed if user achievement data was found.
			
				$result = array();
				while( $data = $queryData->fetch_object()){
					array_push($result, $data);
				}
				$this->_mc->set($key, $result, MEMCACHE_COMPRESSED, time() + 60 * 60 * 24);
				$this->_dbc->pop_connection();
				return true;
			}
			else
			{
				$result = -1;
				$this->_l->log(" >> achievementsDAO->readUserAchievements: could not retrieve achievements for user requested: $user_id", PEAR_LOG_ERR );
				$this->_dbc->pop_connection();
				return false;
			}
		}else{
			$result = $data;
			$this->_dbc->pop_connection();
			return true;
		}
	    $this->_dbc->pop_connection();
	}
	
	/** 
	 *	Read in achievement sets. 
	 * */
	public function readAchievementSets( &$result ){

		$key = "achievementSets:All:";
		$data = $this->_mc->get($key);
		$db_layer = new db_connection( rand() );
		if( !$data ){
			$querySuccess = $this->_dbc->query( 
				$queryData,
				"SELECT * FROM achievement_sets");
			if( $querySuccess && mysqli_num_rows( $queryData ) > 0 ){
				$result = array();
				while( $data = $queryData->fetch_object()){
					array_push($result, $data);
				}
				$this->_mc->set($key, $result, MEMCACHE_COMPRESSED, time() + 60 * 60 * 24);
				return true;
			}else{
				$result = -1;
				$this->_l->log(" >> achievementsDAO->readAchievementSets: could not retrieve achievementsets.", PEAR_LOG_ERR );
				return false;
			}
		}else{
			$result = $data;
			return true;
		}
		
	}
	
	
	/**
	 * updates an individual user's achievement record
	 * 
	 * @param  $a_id
	 * @param  $user_id
	 * @param  $is_complete
	 * @param  $count
	 * @param  $first_award_time
	 * @param  $update_time
	 */
	public function updateUserAchievement( 
		$a_id, 
		$user_id, 
		$is_complete, 
		$count, 
		$first_award_time, 
		$update_time ){

		//update the db
		
		$this->_dbc->push_connection($user_id);
		if ($is_complete >= 0) // If is complete is set, set the completion value, if -1, otherwise, don't update it.
		{
			$querySuccess = $this->_dbc->query( $queryData,
				"UPDATE user_achievements 
				SET is_complete = ?, a_count = ?, first_award_time = ?, update_time = ?
				WHERE a_id = ?
				AND user_id = ?",
				array($is_complete, $count, $first_award_time, $update_time, $a_id, $user_id));
			if (!$querySuccess){
				$this->_l->log(" >> achievementsDAO->updateUserAchievementCompletion: failed to update acheivement for user_id: $user_id, a_id:$a_id, first_award_time:$first_award_time, update_time:$update_time", PEAR_LOG_ERR );
				$this->_dbc->pop_connection();
				return false;
			}
		}
		else
		{
			$querySuccess = $this->_dbc->query( $queryData,
				"UPDATE user_achievements 
				SET a_count = ?, first_award_time = ?, update_time = ?
				WHERE a_id = ?
				AND user_id = ?",
				array($count, $first_award_time, $update_time, $a_id, $user_id));
			if (!$querySuccess){
				$this->_l->log(" >> achievementsDAO->updateUserAchievementCompletion: failed to update acheivement for user_id: $user_id, a_id:$a_id, first_award_time:$first_award_time, update_time:$update_time", PEAR_LOG_ERR );
				$this->_dbc->pop_connection();
				return false;
			}
		}
		
		//update the cache
		$key = "achievements:user:".$user_id;
		$data = $this->_mc->get($key);
		if ($data) {
			foreach($data as $achiev){
				if(isset($achiev->a_id) && $achiev->a_id == $a_id){
					$achiev->a_count = $count;
					
					if ($is_complete >= 0)
					{
						$achiev->is_complete = $is_complete;
					}
					
					$achiev->update_time = $update_time;
					$achiev->first_award_time = $first_award_time;
					$this->_mc->set($key, $data, MEMCACHE_COMPRESSED, time() + 60 * 60 * 24);
					break;
				}
			}
		}
		$this->_dbc->pop_connection();
		return true;
	}
}

?>
