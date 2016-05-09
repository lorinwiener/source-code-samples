<script type="text/javascript">

<?php

	date_default_timezone_set('America/Los_Angeles');
	$scriptCall = true;
	$isUserResponse = false; 
	require_once 'private/util/globals.php';
	require_once $GLOBALS['application_dir'].'/private/util/log_state.php';
	
	require_once $GLOBALS['application_dir'].'/private/kontagent/kontagent.php';
	
	global $l;
		
	if( $_REQUEST && isset($_REQUEST['ids'] ) ){
		$recipients = $_REQUEST['ids'];
	}
	else{
		// User must have cancelled the request, pass along an empty string
		$recipients = array();
	}
	
	if( $_REQUEST && isset($_REQUEST['sender_id'] ) ){
		$sender_id = $_REQUEST['sender_id'];
	}
	
	if ($_REQUEST && isset($_REQUEST['invite_tag'])) {
		$invite_tag = $_REQUEST['invite_tag'];
	}

	require_once $GLOBALS['application_dir'].'/private/kontagent/kontagent.php';
	$kontagent = kontagent::instance();
	if( count( $recipients ) > 0 ){
		$invite_index = 0;
		while( $invite_index < count( $recipients ) ){ 
			$kontagent->inviteSent( $sender_id, $recipients[$invite_index], $invite_tag );
			
			// INCREMENT KONTAGENT GOAL COUNT GC1 FOR FIRST INVITE
			require_once $GLOBALS['application_dir'].'/private/user/userDAO.php';
			userDAO::instance()->readByFacebookID( $sender_id, $user );
			if( !$user->invite ) {
				userDAO::instance()->setUserInvite( $user->user_id, 1 );
				$kontagent->goalCounts( $user->user_id, 1, 1 );
				//$kontagent->userFirstInvite( $sender_id );
			}
			
			// LW - Increment Energy when player invites a Facebook friend
			/*require_once $GLOBALS['application_dir'].'/private/user/userDAO.php';
			userDAO::instance()->readByFacebookID( $sender_id, $user );
			
			require_once $GLOBALS['application_dir'].'/private/user/userUpdateStats.php';
			userUpdateEnergy( $user->user_id, 1);*/
			
			++$invite_index;
		}
	} 
	
	echo 'parent.closeInviteForm();';
	
?>

</script>