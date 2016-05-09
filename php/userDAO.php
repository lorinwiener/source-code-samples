<?php
//_________________________________________________________________________________________________
//?????????????????????????????????????????????????????????????????????????????????????????????????
//  Confidential
//
//  userDAO.php
//
//  Liquid Entertainment
//
//  Description:
//   user DAO
//_________________________________________________________________________________________________
//?????????????????????????????????????????????????????????????????????????????????????????????????

class userDAO{

	static private $_instance;
	private $_mc;
	private $_dbc;
	private $_l;
	private $_userIDs = array();

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
			self::$_instance = new userDAO();
		}
		return self::$_instance;
	}

	private function __clone()
	{
	}

	public function deleteCredentialsByFacebookID($facebookID)
	{
		$this->_dbc->push_connection($facebookID, DB_CREDENTIALS);

		$querySuccess = $this->_dbc->query($result,
		    "DELETE FROM facebook_users WHERE facebook_id = " . $facebookID );

		$this->_dbc->pop_connection();

		if(!$querySuccess)
		{
			return false;
		}

		// Delete the cached user IDs as well.

		if( isset($this->_userIDs[$facebookID]) )
		{
			unset($_userIDs[$facebookID]);
	    }

		// And clear the key from memcache.

		$key = "fbuid:" . $facebookID;
		$result = $this->_mc->delete($key);

		return true;
	}

	public function existForFBUser($facebook_id, &$result)
	{
		$user_id = -1;

		if (!$this->getUserID($facebook_id, $user_id))
		{
			return false;
		}

		if ($user_id == -1)
		{

			// The database was read successfully, but no user exists.
			$result = false;
			return true;
		}

		$key = "user:" . $user_id;

		$data = $this->_mc->get($key);

		if (!$data) {
			$this->_dbc->push_connection($user_id);
			$querySuccess = $this->_dbc->query( $data,
				"SELECT user_id FROM facebook_users WHERE user_id = ? LIMIT 1", $user_id);

			if (!$querySuccess)
			{
				return false;
			}

			$this->_dbc->pop_connection();
			$result = (mysqli_num_rows( $data ) > 0 );
			return true;
		}

		$result = true;
		return true;
	}

	/**
	 * create a new user.
	 * Does NOT place the user into cache
	 * Returns their user_id
	 *
	 * @param int $facebookID
	 * @param int &$result
	 */
	public function create($facebookID, $firstName, $lastName, $email, &$result)
	{
		// This is a bit wasteful, because if any step fails in user creation, the UID of the broken user will remain unused.
		// We just want to make sure we aren't slamming on this function over and over if it fails.

		require_once $GLOBALS['application_dir'].'/private/util/uid.php';
        $userID = getUID("facebook_users.user_id");

        if( $userID < 0 ) {
            $result = -1;
            return false;
        }

		// Insert the Facebook user first. Once this is created, create the credentials entry. This way we'll not have any orphaned entries
		// in the credentials DBs.

		$this->_dbc->push_connection($userID);

		// Create a new user.
		$date = date_create();
		$date = $date->format("Y-m-d H:i:s");
		$querySuccess = $this->_dbc->query($data, "INSERT INTO facebook_users(facebook_id, user_id, first_name, last_name, email, creation_date) VALUES (?,?,?,?,?,?)", array($facebookID, $userID, $firstName, $lastName, $email, $date) );

		$this->_dbc->pop_connection();

		if(!$querySuccess)
		{
			$this->_l->log(" >> userDAO->create: Could not add user with fb_id = $facebookID into core DB", PEAR_LOG_CRIT );
			$result = -1;
			return false;
		}

		$this->_dbc->push_connection($facebookID, DB_CREDENTIALS);

		$querySuccess = $this->_dbc->query($data,
		    "INSERT INTO facebook_users(facebook_id, user_id) VALUES (?,?)", array($facebookID, $userID) );

		$this->_dbc->pop_connection();

		if(!$querySuccess){
			$this->_l->log(" >> userDAO->create: Could not add user with fb_id = $facebookID into credential DB", PEAR_LOG_CRIT );
			$result = -1;
			return false;
		}

		$result = $userID;
		return true;
	}


	public function getUserID($facebookID, &$result)
	{
		if( isset($this->_userIDs[$facebookID]) ) {
			$result = $_userIDs[$facebookID];
			return true;
	    }
		$key = "fbuid:".$facebookID;
		$result = $this->_mc->get($key);
		if (!$result)
		{
		    $dblayer = new db_connection($facebookID, DB_CREDENTIALS);

			$querySuccess = $this->_dbc->query( $data,
				"SELECT user_id FROM facebook_users WHERE facebook_id = ? LIMIT 1", $facebookID);

			if (!$querySuccess)
			{
				return false;
			}

			if (mysqli_num_rows( $data ) > 0 )
			{
				$result = mysqli_fetch_row( $data );
				$result = $result[0];

				$this->_mc->set($key, $result, MEMCACHE_COMPRESSED, time() + 300);
				$_userIDs[$facebookID] = $result;
			}
			else
			{
				$result = -1;
			}
		}
		else
		{
			$_userIDs[$facebookID] = $result;
		}
		return true;
	}

	/**
	 * returns the basic user information as an object
	 * this will translate the facebook_id into a user_id and then query the user_id cache
	 *
	 * @param int $user_id
	 * @param object $result
	 */
	public function readByFacebookID($facebookID, &$result){

		// first look up the user_id
		if (!$this->getUserID($facebookID, $userID))
		{
			$result = -1;
			return false;
		}

		if( $userID == -1 )
		{
			$result = -1;
			return false;
		}
		$this->_dbc->push_connection($userID);

		//now use that id to look up the user
		$success = $this->readByUserID($userID, $result);
		$this->_dbc->pop_connection();

		if(!$success){
			return false;
		}else{
			return true;
		}
	}

	/**
	 * returns the basic user information as an object
	 *
	 * @param int $user_id
	 * @param object $result
	 */
	public function readByUserID($user_id, &$result){
		$key = "user:".$user_id;

		$data = $this->_mc->get($key);
		if (!$data) {
			$this->_dbc->push_connection($user_id);
			$querySuccess = $this->_dbc->query( $data,
				"SELECT facebook_id, user_id, first_name, last_name, nickname, email, gender, active_character_id, max_achieved_level, unlimited_energy_purchased, invite_installs_generated, last_login_date FROM facebook_users WHERE user_id = ? LIMIT 1", $user_id);

			if ($querySuccess && mysqli_num_rows( $data ) > 0 ){
				$result = mysqli_fetch_object( $data );
				$this->_mc->set($key, $result, MEMCACHE_COMPRESSED, time() + 300);
				$this->_dbc->pop_connection();
				return true;
			}else{
				$result = -1;
				$this->_l->log(" >> userDAO->readByUserID: could not retrieve user requested: $user_id", PEAR_LOG_ERR );
				$this->_dbc->pop_connection();
				return false;
			}
			$this->_dbc->pop_connection();
		}else{
			$result = $data;
			return true;
		}
	}

	/**
	 * returns public user profile data
	 *
	 * @param unknown_type $user_id
	 * @param unknown_type $result
	 */
	public function readUserPublicProfile($user_id, &$result){
		$key = "user:".$user_id;

		$data = $this->_mc->get($key);
		if (!$data) {
			$querySuccess = $this->readByUserID($user_id, $user);
			if ($querySuccess ){
				$result = new stdClass();
				$result->facebook_id = $user->facebook_id;
				$result->user_id = $user->user_id;
				$result->first_name = $user->first_name;
				$result->last_name = $user->last_name;
				$result->gender = $user->gender;
				$result->nickname = $user->nickname;
				$result->email = $user->email;
				return true;
			}else{
				$result = -1;
				$this->_l->log(" >> userDAO->readUserBasics: could not retrieve user requested: $user_id", PEAR_LOG_ERR );
				return false;
			}
		}else{
			$result = new stdClass();
			$result->facebook_id = $data->facebook_id;
			$result->user_id = $data->user_id;
			$result->first_name = $data->first_name;
			$result->last_name = $data->last_name;
			$result->gender = $data->gender;
			$result->nickname = $data->nickname;
			$result->email = $user->email;
			return true;
		}
	}

	/**
	 * updates a user's nickname
	 *
	 * @param int $user_id
	 * @param string $nickname
	 */
	public function updateUserNickname($user_id, $nickname){
		$key = "user:".$user_id;
		$this->_l->log(" >> userDAO->updateUserNickname: user_id $user_id, nickname: $nickname", PEAR_LOG_ERR );
		//get the user
		$success = $this->readByUserID($user_id, $user);
		if(!$success){
			$this->_l->log(" >> userDAO->updateUserNickname: could not retrieve user requested: $user_id", PEAR_LOG_ERR );
			return false;
		}

		//update cached object
		$user->nickname = $nickname;

		//update the db
		$this->_dbc->push_connection($user_id);
		$success = $this->_dbc->query( $result,
			"UPDATE facebook_users SET nickname = ? WHERE user_id = ?",
		array( $nickname, $user_id ));
		$this->_dbc->pop_connection();
		if(!$success){
			$this->_l->log(" >> userDAO->updateUserNickname: could not update user requested: $user_id", PEAR_LOG_ERR );
			return false;
		}

		//update the cache
		$result = $this->_mc->set($key, $user, MEMCACHE_COMPRESSED, time() + 300);

		return true;
	}

	/**
	 * updates a user's gender
	 *
	 * @param int $user_id
	 * @param int $gender
	 */
	public function updateUserGender($user_id, $gender){
		$key = "user:".$user_id;
		//get the user
		$success = $this->readByUserID($user_id, $user);
		if(!$success){
			$this->_l->log(" >> userDAO->updateUserGender: could not retrieve user requested: $user_id", PEAR_LOG_ERR );
			return false;
		}

		//update cached object
		$user->gender = $gender;

		//update the db
		$this->_dbc->push_connection($user_id);
		$success = $this->_dbc->query( $result,
			"UPDATE facebook_users SET gender = ? WHERE user_id = ?",
		array( $gender, $user_id ));

		$this->_dbc->pop_connection();

		if(!$success){
			$this->_l->log(" >> userDAO->updateUserGender: could not update user requested: $user_id", PEAR_LOG_ERR );
			return false;
		}

		//update the cache
		$result = $this->_mc->set($key, $user, MEMCACHE_COMPRESSED, time() + 300);

		return true;
	}

	/**
	 * attempt to read a user's basic profile from the facebook open graph
	 *
	 * @param  $fbUser
	 * @param  $result
	 */
	public function readFacebookBasicProfile($fbUser, $access_token, &$result){
		try{
			if (isset($access_token) && $access_token) {
				$fb_profile = json_decode( file_get_contents( "https://graph.facebook.com/".$fbUser.'?access_token='.$access_token ));
			}
			else {
				$fb_profile = json_decode( file_get_contents( "https://graph.facebook.com/".$fbUser ));
			}
		}catch(Exception $exception){
			$fb_profile = null;
		}
		$result = new stdClass();
		if($fb_profile == null){
			$result->first_name = "";
			$result->last_name = "";
			$result->email = "";
			return false;
		}else{
			$result = $fb_profile;
			return true;
		}
	}


	/**
	 * retrieves a list of user ids for the requested facebook ids
	 * This is very slow... If possible, use the facebook_ids instead.
	 */
	public function getUserIDs( $facebook_ids, &$user_ids )
	{
	    $user_ids = array();
		foreach($facebook_ids as $facebook_id){
		    if($this->getUserID($facebook_id, $user_id)) {
			    array_push($user_ids, $user_id);
			}
		}
		return true;
	}


	/**
     * fetch the list of friends from facebook
     */
    public function getFacebookFriends( $fbUser, &$friends )
    {
        $key = "user_fb_friends:".$fbUser;

        $friends_list = $this->_mc->get($key);
        if($friends_list){
            $friends = $friends_list;
            return true;
        }

		global $message;

		try{
			$fb_friends = json_decode( file_get_contents( "https://graph.facebook.com/".$fbUser."/friends?access_token=".$message->access_token ));
		}catch(Exception $exception){
		    $friends = array();
		    return false;
		}

	    $friends = array();

		foreach($fb_friends->data as $friend){
			array_push($friends, $friend->id);
		}
		// Store this for an hour.  We don't want to be making frequent calls to the graph api.
		$this->_mc->set($key, $friends, MEMCACHE_COMPRESSED, 3600);
		return true;
    }

	public function getFacebookFriendsFullData( $fbUser, &$friends )
	{
		$key = "user_fb_friends:fulldata:".$fbUser;

        $friends_list = $this->_mc->get($key);
        if($friends_list){
            $friends = $friends_list;
            return true;
        }

		global $message;

		try{
			$fb_friends = json_decode( file_get_contents( "https://graph.facebook.com/".$fbUser."/friends?access_token=".$message->access_token ));
		}catch(Exception $exception){
		    $friends = array();
		    return false;
		}

	    $friends = array();

		foreach($fb_friends->data as $friend){
			array_push($friends, $friend);
		}
		// Store this for an hour.  We don't want to be making frequent calls to the graph api.
		$this->_mc->set($key, $friends, MEMCACHE_COMPRESSED, 3600);
		return true;
	}

	/**
	 * gets a friends list from facebook, adds user_id, trims non DnD users
	 * has a default timer of five minutes in which cached values will be used instead
	 *
	 * @param $fbUserId
	 * @param $user_id
	 * @param $access_token
	 */
	public function createUserFriendsList( $fbUser, $user_id, $access_token, &$result, $forceRefreshTimer = 3600 ){

		$key = "user_friends_list:".$user_id;

		$encoded_data = $this->_mc->get($key);

		if($encoded_data){
			$decoded_data = json_decode($encoded_data);
		}else{
			$decoded_data = null;
		}

		// Cache is still good, return it.
		if ($decoded_data && (time() < $decoded_data->lastRefresh + $forceRefreshTimer) ) {
			$result = $decoded_data;
			return true;
		}

		if ( isset($access_token) ) {

            if($this->getFacebookFriends($fbUser, $friends)) {
                $fb_friends_csv = implode(",", $friends);
    			// Convert the friends list into a CSV so we can pull out the FB IDs for testing our tracked users.

				$friendsObj = new stdClass();
				$friendsObj->lastRefresh = time();
				$friendsObj->allFriends = $friends;
				$friendsObj->dndfFriends = array();


				// Check the credentials DBs to see which users exist
				$coreDBFriends = array();
				for ($i = 0; $i < count($GLOBALS['database_list'][DB_CREDENTIALS]); ++$i) {
					$querySuccess = $this->_dbc->queryCredentialsServerIndex($i, $queryData,
						"SELECT facebook_id, user_id
						FROM facebook_users
						WHERE facebook_id in ( $fb_friends_csv )");

					if (!$querySuccess) {
						$this->_l->log(" >> userDAO->createUserFriendsList: could not load Friends from credentials DB $i, fb_friends_csv: $fb_friends_csv", PEAR_LOG_ERR );
						continue;
					}

					while( $user = $queryData->fetch_row() ){
						// Group friends by Core DB
						$coreDB = $this->_dbc->getDBIndex($user[1], DB_CORE);	// Core DB is hashed based on user_id
						if (!isset($coreDBFriends[$coreDB])) {
							$coreDBFriends[$coreDB] = array();
						}
						array_push($coreDBFriends[$coreDB], $user[0]);			// Core DB `facebook_users` table is indexed by facebook_id
					}
				}

				// Look up their full data in the core DBs
				foreach ($coreDBFriends as $coreDB=>$userIDs)
				{
					$fb_friends_csv = implode(",", $userIDs);
					$querySuccess = $this->_dbc->queryServerIndex($coreDB, $queryData,
						"SELECT facebook_id, user_id, first_name, last_name
						FROM facebook_users
						WHERE facebook_id in ( $fb_friends_csv )");

					if (!$querySuccess) {
						$this->_l->log(" >> userDAO->createUserFriendsList: could not load Friends from core DB $coreDB, fb_friends_csv: $fb_friends_csv", PEAR_LOG_ERR );
						continue;
					}

					while( $user = $queryData->fetch_object() ){
						array_push( $friendsObj->dndfFriends, $user );
					}
				}

				ksort( $friendsObj->dndfFriends );


				$encoded_list = json_encode( $friendsObj );
				$result = $friendsObj;
				$this->_mc->set( $key, $encoded_list, MEMCACHE_COMPRESSED, time() + 60 * 60 * 12 );

				return true;
			}else{
				// Could not retrieve friends from facebook.
				if( $encoded_data ){
					// Cache is better than nothing!
					$result = $decoded_data;
					return true;
				}
			}
		}else{
			// Return a blank list since we cant get it right now from facebook or anywhere else
			$friendsObj = new stdClass();
			$friendsObj->lastRefresh = time();
			$friendsObj->allFriends = array();
			$friendsObj->dndfFriends = array();
			$result = $friendsObj;

			return true;
		}
	}


	/**
	 * returns the total number of facebook users
	 *
	 * @param  $result
	 */
	public function readUserTotalCount(&$result){
	    $result = null;
	    for( $i = 0; $i < count($GLOBALS['database_list'][DB_CREDENTIALS]); ++$i )
	    {
		    $success = $this->_dbc->queryServerIndex($i, $queryData, "SELECT COUNT(*) as userCount FROM facebook_users");
		    if(!$success){
			    $this->_l->log(" >> userDAO->readUserTotalCount: could not count facebook users", PEAR_LOG_ERR );
			    return false;
		    }
    		$new_result = mysqli_fetch_object( $queryData );
		    if( $result )
		    {
		        $result->userCount += $new_result->userCount;
    		} else {
    		    $result = $new_result;
    		}
	    }
		return true;
	}

	/**
	 * reads a block of facebook users with an offset
	 *
	 * @param  $offset
	 * @param  $result
	 */
	public function readUserBlock($blockSize, $offset, &$result){
	    // Not used, wasn't ported to support new credentials DB process.
	    if(1) return false;
		$success = $this->_dbc->query( $queryData,
			"SELECT facebook_id, user_id, first_name, last_name, gender, nickname
			FROM facebook_users ORDER BY user_id ASC LIMIT ? OFFSET ?", array($blockSize, $offset));
		if(!$success){
			$this->_l->log(" >> userDAO->readUserBlock: could not read facebook users block, offset:$blockSize, $offset", PEAR_LOG_ERR );
			return false;
		}

		$result = array();
		while( $data= $queryData->fetch_object()){
			//$result[$data->user_id] = $data;
			array_push($result, $data);
		}

		return true;
	}

	/**
	 * gets a lock on updating this user
	 *
	 * @param int $user_id
	 */
	public function getUserLock($user_id){
		$key = "user:".$user_id;
		//get a lock
		$success = $this->_mc->get_lock($key);
		if(!$success){
			$this->_l->log(" >> userDAO->getUserLock: could not lock user requested: $user_id", PEAR_LOG_ERR );
			return false;
		}
		return true;
	}

	/**
	 * clears user update locks
	 *
	 * @param int $user_id
	 */
	public function clearUserLock($user_id){
		$key = "user:".$user_id;
		$this->_mc->clear_lock($key);
	}


	/**
	 * function for updating a users primary email address.
	 *
	 * @param $facebook_id
	 * @param $user_id
	 */
	public function updateUserEmail($facebook_id, $user_id){

	    $this->_dbc->push_connection($user_id);

		// If the facebook_id was not passed in use the user_id to find it.
		if( $facebook_id <= 0 ){
			$foundUser = $this->readByUserID( $user_id, $result );
			if( !$foundUser ){
				$this->_l->log(" >> userDAO->userUpdateEmail: could find facebookID for user: $user_id", PEAR_LOG_ERR );
				$this->_dbc->pop_connection();
				return false;
			}
			else{
				$facebook_id = $result->facebook_id;
			}
		}

		global $message;
		if (isset($message->access_token) && $message->access_token != "fail"){
			$access_token = $message->access_token;
		}
		else {
			$access_token = false;
		}

		// Query facebook for the basic profile.
		// Retry 3 times if facebook response doesn't work in 2 second intervals
		$email = "";
		for ($tries=0; $tries< 3; ++$tries) {
			$success = $this->readFacebookBasicProfile($facebook_id, $access_token, $fbProfile);
			if( $success != false && array_key_exists( 'email', $fbProfile ) ){
				$email = $fbProfile->email;
				break;
			}else{
				usleep(2000);
			}
		}

		if( $email ){
			$querySuccess = $this->_dbc->query(
				$result,
				"UPDATE facebook_users SET email = ? WHERE facebook_id = ?",
				array($email,$facebook_id) );
    		$this->_dbc->pop_connection();
			if($querySuccess){
				return true;
			}else{
				return false;
			}
		}
		$this->_dbc->pop_connection();

		return false;
	}


	/**
	 * Find the active character id in the user>> server.php ->  FAIL. Returned value of 0_sessions table based on the user's id
	 * */
	public function userGetActiveCharacterIDByUser($user_id){
		// Try to get the data from memcache
		$key = "active_character:user".$user_id;
		$data = $this->_mc->get($key);

		// If memcache doesn't have the data, try the mySQL DB.
		if( !$data ){
		    $this->_dbc->push_connection($user_id);
			$querySuccess = $this->_dbc->query( $data,
				"SELECT facebook_id, user_id, first_name, last_name, nickname, email, gender, active_character_id, max_achieved_level, unlimited_energy_purchased  FROM facebook_users WHERE user_id = ?", $user_id);

			if( $querySuccess && mysqli_num_rows( $data ) > 0 ){
				$userResult = mysqli_fetch_object( $data );
				$this->_mc->set($key, $userResult->active_character_id, MEMCACHE_COMPRESSED, time() + 172800);
				$userResult = $userResult->active_character_id;
				$this->_l->log(" >> userDAO->userGetActiveCharacterIDByUser: retrieved active character for requested $user_id", PEAR_LOG_ERR );
				$this->_dbc->pop_connection();
			}else{
				$this->_l->log(" >> userDAO->userGetActiveCharacterIDByUser: could not retrieve character for requested: $user_id", PEAR_LOG_ERR );
				$this->_dbc->pop_connection();
				return 0;
			}
		}else{
			// Set the data from memcache.
			$userResult = $data;
		}

		return $userResult;
	}
	

	/**
	 * updates an exisiting facebook session with the selected character_id
	 *
	 * @param string $user_id
	 * @param int $character_id
	 */
	public function userUpdateActiveCharacterID($user_id, $character_id){
		$key = "active_character:user".$user_id;
		$data = $this->_mc->get($key);

		// TODO? Confirm the character belongs to the current user
		if( $data == $character_id ) return true;

        $this->_dbc->push_connection( $user_id );
		$querySuccess = $this->_dbc->query(
			$result,
			"UPDATE facebook_users
			SET active_character_id = ?
			WHERE user_id = ?  LIMIT 1", array( $character_id, $user_id) );
	    $this->_dbc->pop_connection();

		if ($querySuccess){
			 $this->_mc->set($key, $character_id, MEMCACHE_COMPRESSED, time() + 172800);
			return true;
		}else{
			return false;
		}

	}


	/**
	 * returns the user_id based on a user_character_id
	 *
	 * @param int $user_id
	 * @param object $result
	 */
	public function readUserByCharacterID( $user_character_id, &$result ){
	    $charDAO = charactersDAO::instance();
	    $user_id = $charDAO->getUserIDForChar( $user_character_id );

		return $this->readByUserID($user_id, $result);
	}

	public function userGrantUnlimitedEnergy( $user_id, $value, &$result )
	{
		$foundUser = $this->readByUserID( $user_id, $result );

		if( !$foundUser ){
			$this->_l->log(" >> userDAO->userGrantUnlimitedEnergy: could find user: $user_id", PEAR_LOG_ERR );
			return false;
		}

		$dblayer = new db_connection($user_id);

		$querySuccess = $this->_dbc->query(
			$result,
			"UPDATE facebook_users SET unlimited_energy_purchased = ? WHERE user_id = ?",
			array($value, $user_id) );

		$result = 0;

		if($querySuccess){
		
			require_once $GLOBALS['application_dir'].'/private/achievements/achievementsCredit.php';
			$completed_acheivement = new stdClass();
			if ($value != 0 && achievementsCredit( AchievementTypes::ACHIEVEMENT_HaveADrink, $user_id, 1, true, $completed_achievement ))
			{
				require_once $GLOBALS['application_dir'] . '/private/kontagent/kontagent.php';
				require_once $GLOBALS['application_dir'] . '/private/user/userDAO.php';
				$user_dao = userDAO::instance();
				$kontagent = kontagent::instance();
				
				$fb_user_row = 0;
				
				$user_dao->readByUserID($user_id, $fb_user_row);
				
				$kontagent = kontagent::instance();
				$kontagent->customEvent(
					$fb_user_row->facebook_id,
					"earned_unlimited_energy",
					0,
					$fb_user_row->max_achieved_level,
					"goal_step_completions",
					"have_a_drink" );
			}
		
			$result = $value;

			$this->_mc->delete("user:".$user_id);

			return true;
		}else{
			return false;
		}

		return false;
	}
	
	// Credits a user for a invitation acceptance. This only counts brand new users.
	
	public function creditInviteInstall($user_id)
	{
		$user = new stdClass();
		
		$foundUser = $this->readByUserID( $user_id, $user );

		if( !$foundUser ){
			$this->_l->log(" >> userDAO->creditInviteInstall: could find user: $user_id", PEAR_LOG_ERR );
			return false;
		}

		$dblayer = new db_connection($user_id);

		require_once $GLOBALS['application_dir'].'/private/inviteRewards/inviteRewardsDAO.php';
		$inviteRewardsDAO = inviteRewardsDAO::instance();
		$rewards = array();
		
		if (!$inviteRewardsDAO->readInviteRewards($rewards))
		{
			$this->_l->log(" >> userDAO->creditInviteInstall: Couldn't read current invite rewards info.", PEAR_LOG_ERR );
			return false;
		}
		
		$max_count = $rewards[count($rewards)-1]->invite_count;
		
		if ($user->invite_installs_generated < $max_count)
		{
			$new_count = $user->invite_installs_generated + 1;
			
			$querySuccess = $this->_dbc->query(
				$queryData,
				"UPDATE facebook_users SET invite_installs_generated = ? WHERE user_id = ?",
				array($new_count, $user_id) );

			if($querySuccess)
			{
				$this->_mc->delete("user:".$user_id);
			}
			else
			{
				return false;
			}
			
			$reward = 0;
			
			if ($inviteRewardsDAO->checkInviteRewardItem($new_count, $reward))
			{
				// If there's a reward associated with this item, gift it to the player.

				if ($reward > 0)
				{
					require_once $GLOBALS['application_dir'].'/private/gifts/giftsPost.php';
					
					$success = sendGift($reward, -1, -3, $user_id, $result);
				}
			}
			else
			{
				return false;
			}
			
			return true;
		}
		else
		{
			// We're already at the maximum defined reward count, so just return true.
			return true;
		}

		return false;
	}
	
	public function updateLastLoginDate($user_id)
	{
		$user = new stdClass();
		
		$foundUser = $this->readByUserID( $user_id, $user );

		if( !$foundUser ){
			$this->_l->log(" >> userDAO->updateLastLoginDate: could find user: $user_id", PEAR_LOG_ERR );
			return false;
		}

		// Creates a timestamp for the current date, excluding the time of day.
		$new_timestamp = mktime(0, 0, 0, date("n"), date("j"), date("Y"));
		$dblayer = new db_connection($user_id);
		$querySuccess = $this->_dbc->query(
			$queryData,
			"UPDATE facebook_users SET last_login_date = ? WHERE user_id = ?",
			array($new_timestamp, $user_id) );

		if($querySuccess)
		{
			$this->_mc->delete("user:".$user_id);
		}
		else
		{
			$this->_l->log(" >> userDAO->updateLastLoginDate: error updating login date: $user_id", PEAR_LOG_ERR );
			return false;
		}
		
		return true;
	}
	
	public function getInviteInstalls($user_id, &$result)
	{
		$result = new stdClass();
		
		$foundUser = $this->readByUserID( $user_id, $result );
		
		if( !$foundUser )
		{
			$this->_l->log(" >> userDAO->getInviteInstalls: could find user: $user_id", PEAR_LOG_ERR );
			return false;
		}
		
		$result = $foundUser->invite_installs_generated;
		
		return true;
	}

}

?>
