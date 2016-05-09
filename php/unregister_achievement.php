<?php
  $app_id = '406625216981';
  $app_secret = '2b41d6f4720fef50d381e3eddc783875';

  // Authenticate the user
  session_start();
  if(isset($_REQUEST["code"])) {
     $code = $_REQUEST["code"];
  }

  if(empty($code) && !isset($_REQUEST['error'])) {
    $_SESSION['state'] = md5(uniqid(rand(), TRUE)); //CSRF protection
    $dialog_url = 'https://www.facebook.com/dialog/oauth?' 
      . 'client_id=' . $app_id
      . '&redirect_uri=' . urlencode($canvas_page_url)
      . '&state=' . $_SESSION['state']
      . '&scope=publish_actions';

    print('<script> top.location.href=\'' . $dialog_url . '\'</script>');
    exit;
  } else if(isset($_REQUEST['error'])) { 
    // The user did not authorize the app
    print($_REQUEST['error_description']);
    exit;
  };

  // Get the User ID
  $signed_request = parse_signed_request($_POST['signed_request'],
    $app_secret);
  $uid = $signed_request['user_id'];

  // Get an App Access Token
  $token_url = 'https://graph.facebook.com/oauth/access_token?'
    . 'client_id=' . $app_id
    . '&client_secret=' . $app_secret
    . '&grant_type=client_credentials';

  $token_response = file_get_contents($token_url);
  $params = null;
  parse_str($token_response, $params);
  $app_access_token = $params['access_token'];


  // Un-Register an Achievement for the app
  print('Un-Register Achievement:<br/>');
  $achievement_registration_URL = 'https://graph.facebook.com/' 
    . $app_id . '/achievements';
  $achievement_registration_result=https_delete($achievement_registration_URL,
    'achievement=' . $achievement
      . '&access_token=' . $app_access_token
  );
  print('<br/><br/>');

    
  function https_delete($uri, $postdata) {
    $ch = curl_init($uri);
    //curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_CUSTOMREQUEST, "DELETE");
    curl_setopt($ch, CURLOPT_POSTFIELDS, $postdata);
    $result = curl_exec($ch);
    curl_close($ch);

    return $result;
  }

  function parse_signed_request($signed_request, $secret) {
    list($encoded_sig, $payload) = explode('.', $signed_request, 2); 

    // decode the data
    $sig = base64_url_decode($encoded_sig);
    $data = json_decode(base64_url_decode($payload), true);

    if (strtoupper($data['algorithm']) !== 'HMAC-SHA256') {
      error_log('Unknown algorithm. Expected HMAC-SHA256');
      return null;
    }

    // check sig
    $expected_sig = hash_hmac('sha256', $payload, $secret, $raw = true);
    if ($sig !== $expected_sig) {
      error_log('Bad Signed JSON signature!');
      return null;
    }

    return $data;
  }

  function base64_url_decode($input) {
    return base64_decode(strtr($input, '-_', '+/'));
  }

?>
