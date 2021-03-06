function emailTestResults() {

  // Save the log as .html
  
  var localPath = "C:\\Shared\\";
  var externalPath = "\\" + "\\" + Sys.HostName + "\\Shared\\";
  
  var currentDate = String(aqDateTime.GetMonth(aqDateTime.Now())) + "_" + String(aqDateTime.GetDay(aqDateTime.Now()) + "_" + aqDateTime.GetYear(aqDateTime.Now()));
  var currentTime = String(aqDateTime.GetHours(aqDateTime.Now())) + "_" + String(aqDateTime.GetMinutes(aqDateTime.Now())) + "_" + String(aqDateTime.GetSeconds(aqDateTime.Now()));
  
  var fileName = "warranty_smartCare_testRunResults_" + String(currentDate) + "_" + String(currentTime) + ".mht";
    
  var fullyQualifiedLocalFilePathName = localPath + fileName;  
  var fullyQualifiedExternalFilePathName = externalPath + fileName;
  
  Log.SaveResultsAs(fullyQualifiedLocalFilePathName, 1);
  
  // Extract test results filename from TestRunSummary.xml
  
  var file, line, startPos, endPos, testRunResultsSummaryFilename;
  var TestRunSummaryFile = fullyQualifiedLocalFilePathName + "\\"  + "TestRunSummary.xml" 
  file = aqFile.OpenTextFile(TestRunSummaryFile, aqFile.faRead, aqFile.ctANSI);
  file.Cursor = 0;
  while(!file.IsEndOfFile()){
    line = file.ReadLine();
  }
  file.Close();
  startPos = aqString.Find(line, "<![CDATA[", 0, true);
  endPos = aqString.Find(line, "]]></TestRunSummary>", 0, true);
  testRunResultsSummaryFilename = aqString.Substring(line,startPos + 9, endPos-43);
  
  // Extract test run data from test run results file
  
  var testRunResultsSummaryURL = "file:" + "///" + "C:" + "/" + "Shared" + "/" + fileName + "/" + testRunResultsSummaryFilename;
  
	TestedApps.iexplore.Run();
	
  Sys.Process("iexplore").ToUrl(testRunResultsSummaryURL);
  
  var page = Sys.Process("iexplore").Page("file:///C:/Shared/" + fileName + "/" + testRunResultsSummaryFilename);
  
  var totalNumberOfProjectTestItemsString = page.Panel(0).innerText;
  var totalNumberOfProjectTestItemsExecutedString = page.Panel(1).innerText;
  var totalNumberOfProjectTestItemsExecutedSucessfullyString = page.Panel(2).innerText;
  var totalNumberOfProjectTestItemsFailedString = page.Panel(3).innerText;
  var footnote = page.TextNode(1).innerText;
  
  startPos = aqString.Find(totalNumberOfProjectTestItemsString, ": ", 0, true);
  endPos = aqString.Find(totalNumberOfProjectTestItemsString, "(", 0, true);
  var totalNumberOfProjectTestItems = aqString.Substring(totalNumberOfProjectTestItemsString, startPos+2, endPos-startPos-2);
  
  startPos = aqString.Find(totalNumberOfProjectTestItemsExecutedString, ": ", 0, true);
  endPos = aqString.Find(totalNumberOfProjectTestItemsExecutedString, "(", 0, true);
  var totalNumberOfProjectTestItemsExecuted = aqString.Substring(totalNumberOfProjectTestItemsExecutedString, startPos+2, endPos-startPos-2);
  
  startPos = aqString.Find(totalNumberOfProjectTestItemsExecutedSucessfullyString, ": ", 0, true);
  endPos = aqString.Find(totalNumberOfProjectTestItemsExecutedSucessfullyString, "(", 0, true);
  var totalNumberOfProjectTestItemsExecutedSucessfully = aqString.Substring(totalNumberOfProjectTestItemsExecutedSucessfullyString, startPos+2, endPos-startPos-2);
  
  startPos = aqString.Find(totalNumberOfProjectTestItemsFailedString, ": ", 0, true);
  endPos = aqString.Find(totalNumberOfProjectTestItemsFailedString, "(", 0, true);
  var totalNumberOfProjectedTestItemsFailed = aqString.Substring(totalNumberOfProjectTestItemsFailedString, startPos+2, endPos-startPos-2);
  
  var subject;
    
  if (aqConvert.StrToInt(totalNumberOfProjectedTestItemsFailed)== 0) {
    subject = "Warranty/SmartCare Test Run Passed!";
  } else {
    subject = "Warranty/SmartCare Test Run Failed";
  }
  
  var body;
  
  if (aqConvert.StrToInt(totalNumberOfProjectedTestItemsFailed) > 0) {
    body = subject + "\r\n\n" + totalNumberOfProjectedTestItemsFailed + "of " + aqConvert.IntToStr(aqConvert.StrToInt(totalNumberOfProjectTestItemsExecuted)-1) + " test cases run failed.";
  } else {
    body = subject + "\r\n\n" + "All " + aqConvert.IntToStr(aqConvert.StrToInt(totalNumberOfProjectTestItemsExecuted)-1) + " test cases run passed.";
  }
  
  body = body + "\r\n\n" + "Detailed test results available at: " + fullyQualifiedExternalFilePathName;

  // Email log link to team members if tests were run on QATESTEXECUTE machine
  if (Sys.HostName == Project.Variables.testExecuteServerDomainName) {
    // Only email failed test results to entire group
    if (aqConvert.StrToInt(totalNumberOfProjectedTestItemsFailed) > 0) {
      // All Development team members get email
      if (SendMail("areyes@smartequip.com,cjiang@smartequip.com,jjoy@smartequip.com,kathota@smartequip.com,lwiener@smartequip.com,mchu@smartequip.com,nvyas@smartequip.com,pdogbey@smartequip.com,rbolourian@smartequip.com,rmartin@smartequip.com,vchutke@smartequip.com,cmortell@smartequip.com", "mail-irvnca.smartequip.net", Sys.Hostname, "donotreply@smartequip.com", subject, body)) {
        Log.Message("An email containing TestRun results was sent successfully.");
      } else {
        Log.Warning("An email containing TestRun results was NOT sent successfully!");
      }
    } else {
        // Only QA team members get email
        if (SendMail("lwiener@smartequip.com, areyes@smartequip.com, rmartin@smartequip.com", "mail-irvnca.smartequip.net", Sys.Hostname, "donotreply@smartequip.com", subject, body)) {
          Log.Message("An email containing TestRun results was sent successfully.");
        } else {
          Log.Warning("An email containing TestRun results was NOT sent successfully!");
        }
    }
 }
  
  // Delete html log
  var aqFolderInfoObj = aqFileSystem.GetFolderInfo(fullyQualifiedLocalFilePathName);
  aqFolderInfoObj.Delete(true); 
  
  // Save log as .mht
  Log.SaveResultsAs(fullyQualifiedLocalFilePathName, 2);
	
	// Open .mht file in browser
  Sys.Process("iexplore").ToUrl("C:\\Shared\\" + fileName);
	
}