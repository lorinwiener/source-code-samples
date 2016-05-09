<?php
//_________________________________________________________________________________________________
//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
//  Confidential
//
//  careers.php
//
//  © Liquid Entertainment
//
//  Description:
//   a user's careers represented as an object
//_________________________________________________________________________________________________
//¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

class careers {
	public $contents;
	public $activeCareer;

	function __construct( $user_id ) {
		$this->load( $user_id );
	}

	/**
	 * loads a user's careers with a given user ID.
	 * 
	 * @param int $user_id
	 */
	public function load( $user_id ) {
		$career_DAO = careersDAO::instance();
		
		$career_DAO->checkAndCreateDefaultCareers( $user_id );
		
		$success = $career_DAO->readByUserID( $user_id, $result );
		
		if( !$success ) {
			$this->contents = array();
			return false;
		}
		
		$this->contents = $result;
		
		for( $index = 0; $index < count( $result ); ++$index ) {
			if( $result[$index]->active ) {
				$this->activeCareer = $result[$index]->career_id;
			}
		}

		return true;
	}
}

?>