<?php
//_________________________________________________________________________________________________
//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
//  Confidential
//
//  careersDAO.php
//
//  © Liquid Entertainment
//
//  Description:
//   career DAO
//_________________________________________________________________________________________________
//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯


class careersDAO{
	
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
			self::$_instance = new careersDAO();
		}
		return self::$_instance;
	}
	
	private function __clone()
	{
	}
	
	/**
	 * checks to see if any careers exist and if not it create's default ones.
	 * 
	 * @param int $user_id
	 */
	public function checkAndCreateDefaultCareers( $user_id ) {
		$success = $this->readByUserID( $user_id, $result );
		if( !$success ) {
			// Insert in the default careers for new users.
			$querySuccess = $this->_dbc->query( $data, "SELECT career_id FROM careers" );
			$default_career_id = '7';
			if( $querySuccess ) {
				while( $row = mysqli_fetch_row( $data )) {
					if( $row[0] == '4'  || $row[0] == '6' ) {
						$unlocked = 0;
					} else {
						$unlocked = 1;
					}
					$active_career = $row[0] == $default_career_id;
					$querySuccess = $this->_dbc->query( $dummyresult, 
						"INSERT INTO user_careers(
						user_id, career_id, experience, current_level, max_level, active, unlocked )
						VALUES (?,?,?,?,?,?,?)", array( $user_id, $row[0], 0, 0, 0, $active_career, $unlocked ));
				}
			}
		}
	}
	
	/**
	 * returns the basic careers information as an object
	 * 
	 * @param int $user_id
	 * @param object $result
	 */
	public function readByUserID( $user_id, &$result ) {
		$key = "careers:user:".$user_id;
		$data = $this->_mc->get( $key );
		if( !$data ) {

			$querySuccess = $this->_dbc->query( $data, "
				SELECT user_careers.user_career_id, user_careers.career_id, user_careers.experience, 
					user_careers.current_level,	user_careers.max_level, 
					user_careers.active, user_careers.unlocked, careers.role, careers.bonus_percent
				FROM user_careers
				LEFT JOIN careers
				ON user_careers.career_id = careers.career_id
				WHERE user_careers.user_id = ?", array( $user_id ));
			if( $querySuccess && mysqli_num_rows( $data )) {
				$result = array();
				while( $career = mysqli_fetch_object( $data )) {
					array_push( $result, $career );
				}
				$this->_mc->set( $key, $result, MEMCACHE_COMPRESSED, time() + 300 );
			} else {
				$result = -1;
				return false;
			}
			
		} else {
			$result = $data;
		}
		return true;
	}
	
	/**
	 * returns the basic career information as an object
	 * 
	 * @param int $user_id
	 * @param int $career_id
	 * @param object $result
	 */
	public function readSingleCareerByUserID( $user_id, $career_id, &$result ) {
		$key = "careers:user:".$user_id;
		$data = $this->_mc->get( $key );
		if( !$data ) {

			$success = $this->readByUserID( $user_id, $data );
			if( !$success ) {
				return false;
			}

		}
		for( $index = 0; $index < count( $data ); ++$index ) {
			if( $data[$index]->career_id == $career_id ) {
				$result = $data[$index];
				return true;
			}
		}
		return false;
	}
	
	/**
	 * updates a user's career
	 * 
	 * @param int $user_id
	 * @param int $career_id
	 * @param int $xp
	 * @param int $current_level
	 * @param int $max_level
	 * @param int $active
	 */
	public function updateCareer( 
		$user_id, 
		$career_id, 
		$xp, 
		$current_level, 
		$max_level, 
		$active, 
		$unlocked = -1 ) {
		
		$key = "careers:user:".$user_id;
		
		//get the career
		$success = $this->readByUserID( $user_id, $careers );
		if( !$success ) {
			$this->_l->log(" >> careersDAO->updateCareer: could not retrieve user requested: $user_id", PEAR_LOG_ERR );
			return false;
		}
		
		// update career object
		for( $index = 0; $index < count( $careers ); ++$index ) {
			if( $careers[$index]->career_id == $career_id ) {
				
				$careers[$index]->experience 		= $xp;
				$careers[$index]->current_level 	= $current_level;
				$careers[$index]->max_level 		= $max_level;
				$careers[$index]->active			= $active;
				if( $unlocked != -1 ) {
					$careers[$index]->unlocked	= $unlocked;
				} else {
					$unlocked = $careers[$index]->unlocked;
				}
				break;
			}
		}
		
		$querySuccess = $this->_dbc->query( $data, "
			UPDATE user_careers 
			SET experience = ?, current_level = ?, max_level = ?, active = ?, unlocked = ? 
			WHERE user_id = ? 
			AND career_id = ?",
			array( $xp, $current_level, $max_level, $active, $unlocked, $user_id, $career_id ));
		if( !$querySuccess ) {
			$this->_l->log(" >> careersDAO->updateCareer: could not update user requested: $user_id", PEAR_LOG_ERR );
			return false;
		}
		
		//update the cache
		$result = $this->_mc->replace( $key, $careers, MEMCACHE_COMPRESSED, time() + 300 );
		if( !$result ) {
			$result = $this->_mc->set( $key, $careers, MEMCACHE_COMPRESSED, time() + 300 );
		}
		
		return true;
	}
	
	/**
	 * returns the user's current active project as an object
	 * 
	 * @param int $user_id
	 * @param object $result
	 */
	public function readActiveCareer( $user_id, &$result ) {
		$success = $this->readByUserID( $user_id, $careers );
		// search for the active career
		for( $index = 0; $index < count( $careers ); ++$index ) {
			if( $careers[$index]->active == 1 ) {
				$result = $careers[$index];
				return true;
			}
		}
		return false;
	}
	
	/**
	 * returns the career leveling curve information as an object
	 * 
	 * @param int $career_id
	 * @param object $result
	 */
	public function readCareerLevelsByID( $career_id, &$result ) {
		$key = "career_levels:".$career_id;
		$data = $this->_mc->get( $key );
		if( !$data ) {

			$querySuccess = $this->_dbc->query( $data,
				"SELECT experience, level FROM career_levels WHERE career_id = ? ORDER BY level DESC", array( $career_id ));
			
			if( $querySuccess && mysqli_num_rows( $data )) {
				$result = array();
				while( $career_level = mysqli_fetch_object( $data )) {
					array_push( $result, $career_level );
				}
				$this->_mc->set( $key, $result, MEMCACHE_COMPRESSED, time() + 300 );
			} else {
				$result = -1;
				return false;
			}
			
		} else {
			$result = $data;
		}
		return true;
	}
	
	/**
	 * Remove any career data for a given user.
	 * */
	public function deleteUserCareers( $user_id ){
		// Delete any memcached data.
		$key = "careers:user:".$user_id;
		$this->_mc->delete( $key );
		 
		//Delete from mySQL DB
		$querySuccess = $this->_dbc->query( $data, 
			"DELETE FROM user_careers WHERE user_id = ?", $user_id );

		if( !$querySuccess ){
			$this->_l->log(" >> careersDAO->deleteUserCareers: could not delete records for user_id: $user_id", PEAR_LOG_INFO );
			return false;
		}
		
		return true;
	}
	
	
	/**
	 * adds a lock for updating careers for a user
	 * 
	 * @param int $user_id
	 */
	public function getUserCareerLock($user_id){
		$key = "careers:user:".$user_id;	
		//get a lock
		$success = $this->_mc->get_lock($key);
		if(!$success){
			$this->_l->log(" >> careersDAO->getUserCareerLock: could not lock user requested: $user_id", PEAR_LOG_ERR );
			return false;
		}
		return true;
	}
	
	/**
	 * removes a lock for updating careers for a given user
	 * 
	 * @param int $user_id
	 */
	public function clearUserCareerLock($user_id){
		$key = "careers:user:".$user_id;		
		$this->_mc->clear_lock($key);
	}
}

?>