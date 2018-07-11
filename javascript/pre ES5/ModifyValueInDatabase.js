function modifyValueInDatabaseViaRequestBody(URL, requestBody) {    

   var http = Sys.OleObject("MSXML2.XMLHTTP");
   http.open("PUT", URL, false);
   http.setRequestHeader("Content-Type", "application/xml");
   http.send(requestBody);
   
   if (http.status == 200) {
     Log.Message("ModifyValueInDatabase Script successfully executed a PUT to URL: " + URL + " with the request body " + requestBody);
   } else {
     Log.Error("ModifyValueInDatabase Script received error " + http.status + " in response from a PUT to URL: " + URL + " with the request body " + requestBody)
   }
   
   /*
   Log.Message(http.getAllResponseHeaders());
   Log.Message(http.statusText);
   Log.Message(http.responseText);
   Log.Message(http.responseXML.text);
   */
   
}

function modifyValueInDatabaseViaODBC(databaseName, tableName, rowNumber, columnName, newValue)
{
  var tableName = tableName;
  var recNo = rowNumber; // Note the record count is 0 based
  //  See the "http://www.connectionstrings.com/" page to find the needed connection string
  var connectionString = "Driver={MySQL ODBC 5.1 Driver};Server=" + Project.Variables.nightlyBuildDomainName + ".smartequip.net;Database=" + databaseName + ";User=root; Password=insecure;Option=3;";
  var arrayColumns = new Array(columnName);
  var arrayValues = new Array(newValue);
  updateTable(connectionString, tableName, recNo, arrayColumns, arrayValues);
}

function updateTable(connectionString, tableName, recNo, arrayColumns, arrayValues)
{
  var adOpenKeyset = 1;
  var adLockOptimistic = 3;
  var adCmdTable = 2;
  var connection = Sys.OleObject("ADODB.Connection");
  connection.ConnectionString = connectionString;
  connection.Open();
  var recordset = Sys.OleObject("ADODB.Recordset");
  recordset.Open(tableName, connection, adOpenKeyset, adLockOptimistic, adCmdTable);
  recordset.MoveFirst();
  var recCount = recordset.RecordCount;
  for (var recId = 0; recId < recNo; recId++)  {
      recordset.MoveNext();
  }
  recordset.Update(arrayColumns, arrayValues);
  recordset.Close();
  connection.Close();
}

function deleteUserViaODBC(databaseName, username)
{
  var adOpenKeyset = 1;
  var adLockOptimistic = 3;
  var adCmdTable = 2;
  var connection = Sys.OleObject("ADODB.Connection");
  connection.ConnectionString = "Driver={MySQL ODBC 5.1 Driver};Server=" + Project.Variables.nightlyBuildDomainName + ".smartequip.net;Database=" + databaseName + ";User=root; Password=insecure;Option=3;";
  connection.Open();
	connection.Execute("DELETE FROM user_contactgroups WHERE userid IN (SELECT userid FROM users  WHERE username ='"  + username +  "')");
	connection.Execute("DELETE FROM usergroups_users WHERE userid IN (SELECT userid FROM users  WHERE username ='"  + username +  "')");
	connection.Execute("DELETE FROM users WHERE  username = '" + username + "'");
  connection.Close();
}