<?php

	error_reporting(E_ALL ^ E_NOTICE);
   	ini_set("display_errors", 1);

   	include(".\_envconfig.php");


   	class FCDataAccess
   	{
    	private function GetConnection()
      	{	// setup ODBC connection
         	$connection = odbc_connect(get_dbName(),get_dbUserName(),get_dbPassword());
         	return $connection;
      	}


      	private function GetActivityTrackingConnection()
      	{	// setup ODBC connection
         	$connection = odbc_connect(get_dbName(),get_dbUserName(),get_dbPassword());
         	return $connection;
      	}


		public function save_jpg($bitmapDataArray, $name, $userID, $userDirectory)
		{

			$uniqueID = uniqid();
			$data = $bitmapDataArray->data;

			$userDirectory .= $userID;

			$filename = $name . "_" . $uniqueID . ".jpg";

			$filePath = $userDirectory . "/" . $filename;

			if (!file_exists($userDirectory))
				mkdir($userDirectory );

			file_put_contents($filePath, $data);

			return $filename;
		}


		public function detect_facial_features($name, $userID, $userDirectory)
		{
			$userDirectory .= $userID;

			$filePath = $userDirectory . "/" . $name;

			exec("fd.exe " . $filePath, $output);

			return array($output[0]);
		}



		 /**
		 Creates a user based on the information passed in.  Return either the new UserID or 'FAIL'  This has neither a Session ID nor a UserID in the parameter list because at the time of creating a user we would not have either piece of data.
		 *
		 *@param $EMail(string) EMail
		 */
		 function getID($Email)
		 {
        	$connection = $this->GetActivityTrackingConnection();
			$retVal = -1;
			$sql = "select fc_user_id from fc_users where email_addr='" . $Email . "'";
			$result = odbc_exec($connection, $sql);
			while( odbc_fetch_row($result) )
			{
				$retVal = odbc_result($result, 1);
			}

			odbc_close($connection);
			return $retVal;
		 }


     	 public function RecordUserSession($EMail, $AppID)
     	 {
        	$RetVal = -1;

        	$UserAgent = $_SERVER['HTTP_USER_AGENT'];
        	$IPAddr    = $_SERVER['REMOTE_ADDR'];
        	$Referrer  = $_SERVER['HTTP_REFERER'];
        	$connection = $this->GetActivityTrackingConnection();

			$sql  = "select user_session_id from user_sessions, fc_users ";
			$sql .= "where app_id= " . $AppID . " and user_sessions.fc_user_id = fc_users.fc_user_id ";
			$sql .= "and fc_users.email_addr='" . $EMail . "' ";
			$sql .= "and DATEDIFF(minute, session_end_dt, GetDate()) < 5 ";
			$sql .= "order by session_end_dt desc";

        	$result = odbc_exec($connection, $sql);

			while( odbc_fetch_row($result) )
			{
				$RetVal = odbc_result( $result, 1 );
				break;
			}

			odbc_close($connection);

        	return $RetVal;
     	}




		 /*
		 Creates a user based on the information passed in.  Return either the new UserID or 'FAIL'  This has neither a Session ID nor a UserID in the parameter list because at the time of creating a user we would not have either piece of data.
		 *
		 *@param $FirstName(string) User's First Name
		 *@param $LastName(string) User's Last Name
		 *@param $EMail(string) EMail
		 *@param $Gender(string) Gender
		 *@param Session ID(int)
		 *@param userDirectory (string)
		 */
		 function create_user($FirstName, $LastName, $Email, $Gender, $SessionID, $userDirectory )
		 {
        	$connection = $this->GetActivityTrackingConnection();

			$IPAddr = $_SERVER['REMOTE_ADDR'];

			$retVal = $this->getID($Email);

			if ($retVal == -1)
			{
				$sql  = "insert into fc_users (first_name, last_name, email_addr, gender ) values ('". $FirstName . "', '";
				$sql .= $LastName . "', '" . $Email . "', '" . $Gender ."')";

        		$result = odbc_exec($connection, $sql);

               	$sql = "SELECT @@IDENTITY AS ID";
	           	$result = odbc_exec($connection, $sql);
               	while( odbc_fetch_row($result) )
               	{
	            	$retVal = odbc_result( $result, 1 );
					$userDirectory .= $RetVal;
					if (!file_exists($userDirectory))
						mkdir($userDirectory );
					break;
               	}
            }

			if ($retVal > -1)
			{	// we have created the user or the user has logged in, update
				// the session setting user id and login date
				$sql  = "update user_sessions set fc_user_id=" . $retVal . ", login_dt=GetDate(), session_end_dt=GetDate() where user_session_id= " . $SessionID;
//				return $sql;
	           	$result = odbc_exec($connection, $sql);
			}

			odbc_close($connection);

			return $retVal;
		  }

		  public function getIpAddress()
		  {
		  	$ipAddress = gethostbyaddr($_SERVER['REMOTE_ADDR']);

		  	return $ipAddress;
		  }

		  public function getMachineName()
		  {
		  	$machineName = GetHostByName($REMOTE_ADDR);

		  	return $machineName;
		  }

 		public function SendEmail($userID, $toEmail, $toName, $fromEmail, $fromName, $subject, $message, $userDirectory, $realFilePath, $finalResultBitmapFilename, $productURL, $applicationImagesDirectoryURL, $finalImageWidth, $finalImageHeight)
		{
			$uniqueID = uniqid();

			$myFilePath = $userDirectory . $userID . "/" . $finalResultBitmapFilename;

			copy($myFilePath, $userDirectory  . $userID . "/email_".$uniqueID.".jpg");

			$realFilePath .= $userID . "/email_".$uniqueID.".jpg";

			$finalImageURL = $realFilePath;

			$emailGraphicsDirectory = $applicationImagesDirectoryURL . "email/";

			require('Swift.php');
			require('./Swift/Connection/SMTP.php');

			$mailer = new Swift(new Swift_Connection_SMTP('smtp.com'));

			if ($mailer->isConnected()) //Optional
			{
				//You can call authenticate() anywhere before calling send()
				if ($mailer->authenticate('lancome@mail.lancome-usa.com', 'shawshank'))
				{
					$html_part = "
					<center>
					<table id='Table_01' width='700' height='500' border='0' cellpadding='0' cellspacing='0'>
					<tr>
						<td colspan='3'>
							<a href='" .$productURL . "'>  <img src='" . $emailGraphicsDirectory. "email_01.jpg' alt=''> </a> </td>
					</tr>
					<tr>
						<td>
							<a href='" .$productURL . "'>  <img src='" . $emailGraphicsDirectory. "email_02.jpg' alt=''> </a></td>
						<td>
							<div align='" . "center" . "'> <a href='" .$productURL . "'>   <img src='" . $finalImageURL . "' border='0'> </a> </div> </td>
						<td>
							<img src='" . $emailGraphicsDirectory. "email_04.jpg' alt=''></td>
					</tr>
					<tr>
						<td>
							<img src='" . $emailGraphicsDirectory. "email_05.jpg' alt=''></td>
						<td>
							" . $message. "</td>
						<td>
							<img src='" . $emailGraphicsDirectory. "email_07.jpg' alt=''></td>
					</tr>
					</table>
					&copy; 2013 <a href='http://www.facecake.com'> FaceCake Marketing Technologies </a> , Inc. All Rights Reserved.<br>
					FaceCake is a registered trademark of FaceCake Marketing Technologies, Inc.
					<br>
					<a href='http://cache.facecake.com/prod/tob/privacy_policy.html'>PRIVACY POLICY</a>
					</center>
					";


					$mailer->addPart($html_part, 'text/html');
					$mailer->setReplyTo('lancome@mail.lancome-usa.com');

					$to_email 	= '"' . $toName . '" <' . $toEmail . '>';
					$from_email = '"' . $fromName . ' (' . $fromEmail . ')" <lancome@facecake.com>';

					$mailer->send($to_email,$from_email,$subject);
				}
				$mailer->close();
			}

			$confirm = 1;

			return $confirm;
		}
   }
?>