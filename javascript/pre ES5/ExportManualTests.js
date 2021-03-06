var projectTestItems, milestonesFolder, milestonesFolderItemCount, milestoneFolder, milestoneFolderItemCount;
var sprintFolder, sprintFolderItemCount, manualTestsFolder, manualTestsFolderItemCount;
var adminFolder, userManagementFolder;
var manualTest, manualTestName, manualTestFilepath, manualTestTCMTFilename;
var bodyTagStartIndex, bodyTagEndIndex, bodyTagText;
var xmlDoc, xmlNodeList, propertyNodeList, node, nodeName, typeNameNode, manualTestNameNode;
var rootNode, configNode, resumeNode, stepInfoNode;
var manualTestNameNode, stepInfoCountNode, testEnabledNode;
var htmlTestTitle, htmlTestDescriptionTitle, htmlTestDescription, htmlTestInstructionsURL;
var AFileName, htmText;  
var stepInfoCaptionNode, stepInfoDescriptionNode, stepInfoInstructionsURLNode;
var stepInfoNotesNode, stepInfoNodeChildNodesLength;
var numberOfSteps, stepNode, stepNodeName, stepCaptionNode, stepDescriptionNode, stepInstructionsURLNode, stepNotesNode;
var stepNotesAndComments, htmText;
var milestonesFolder, milestoneFolderCount, milestoneFolder, milestoneFolderCount, sprintFolderCount;
var sprintFolder, sprintFolderChildCount, testTypeFolderName, manualTestsFolder, moduleFolderCount;
var moduleFolderCount, moduleFolder, moduleFolder, functionsFolderCount, functionFolder, manualTestsCount;
var manualTest;

function ExportManualTests() {
  DeleteHtmlFile();  
  CreateSelectedHtmlManualTests();
  CreateHtmlTableOfContents();   
}

function CreateSelectedHtmlManualTests() {

  aqUtils.Delay(500, "Creating Manual Test Content...");    
  WriteContentToHtmlFile("<H2><P ALIGN=Center><b>" + "Manual Tests For Warranty/SmartCare Project" + "</b></H2>");    
  WriteContentToHtmlFile("<H4><P ALIGN=Center>" + aqDateTime.Now() + "</H4>");
  WriteContentToHtmlFile("<HR>");
  projectTestItems = Project.TestItems;
  milestonesFolder = projectTestItems.TestItem(0);
  milestoneFolderCount = milestonesFolder.ItemCount;
  for (var i=0; i<milestoneFolderCount; i++) {
    milestoneFolder = milestonesFolder.TestItem(i);
    sprintFolderCount = milestoneFolder.ItemCount;
    for (var j=0; j<sprintFolderCount; j++) {
      sprintFolder = milestoneFolder.TestItem(j);
      sprintFolderChildCount = sprintFolder.ItemCount;
      for (k=0; k<sprintFolderChildCount; k++) {
        testTypeFolderName = sprintFolder.TestItem(k).Name;
        if (testTypeFolderName == "Manual Tests") {
          manualTestsFolder = sprintFolder.TestItem(k);
          moduleFolderCount = manualTestsFolder.ItemCount;
          for (l=0; l<moduleFolderCount; l++) {
            moduleFolder = manualTestsFolder.TestItem(l);
            functionsFolderCount = moduleFolder.ItemCount;
            for (m=0; m<functionsFolderCount; m++) {
               functionFolder = moduleFolder.TestItem(m);
               manualTestsCount = functionFolder.ItemCount;
               var manualTestSelectedCount = 0;
               for (z=0; z<manualTestsCount; z++) {
                 manualTest = functionFolder.TestItem(z);
                 if (manualTest.Enabled == true) {
                    manualTestSelectedCount++;
                 }
               }
               if (milestoneFolder.Enabled == true && sprintFolder.Enabled == true && moduleFolder.Enabled == true && functionFolder.Enabled == true && manualTestsCount > 0 && manualTestSelectedCount > 0) {
                 WriteContentToHtmlFile("<H3><b><u>" + milestoneFolder.Name + " \\ " + sprintFolder.Name + " \\ " + moduleFolder.Name + " \\ " + functionFolder.Name + "</u></b></H3>");
                 WriteContentToHtmlFile("<p>");
               }
               for (n=0; n<manualTestsCount; n++) {
                  manualTest = functionFolder.TestItem(n);
                  //if (manualTest.Enabled == true) {
                  manualTestName = manualTest.Name;
                  manualTestFilepath = Project.ConfigPath + "ManualTests\\" + manualTestName + "\\";
                  manualTestTCMTFilename = manualTestName + ".tcMT";
                  AddManualTestToHTMLDoc();
                  //}                                                              
               }
               WriteContentToHtmlFile("<HR>");
            }
          }
        }
      }
    }
  }
  
}

function AddManualTestToHTMLDoc() {

  xmlDoc = Sys.OleObject("Msxml2.DOMDocument.4.0"); 
  xmlDoc.async = false;  
  xmlDoc.load(manualTestFilepath + manualTestTCMTFilename);
  if(xmlDoc.parseError.errorCode != 0) {
    s = "Reason:\t" + xmlDoc.parseError.reason + "\n" +
        "Line:\t" + aqConvert.VarToStr(xmlDoc.parseError.line) + "\n" + 
        "Pos:\t" + aqConvert.VarToStr(xmlDoc.parseError.linePos) + "\n" + 
        "Source:\t" + xmlDoc.parseError.srcText;
    Log.Error("Cannot parse the document.", s); 
    return;
  }  
  xmlNodeList = xmlDoc.getElementsByTagName("Node");  
  rootNode = xmlNodeList.item(0);
  configNode = rootNode.childNodes.item(0);
  resumeNode = configNode.childNodes.item(0);  
  stepInfoNode = configNode.childNodes.item(1);       
  typeNameNode = rootNode.childNodes.item(6);  
  manualTestNameNode = configNode.childNodes.item(2);
  testEnabledNode = resumeNode.childNodes.item(0);
  stepInfoNodeChildNodesLength = stepInfoNode.childNodes.length;
  stepInfoCountNode = stepInfoNode.childNodes.item(stepInfoNodeChildNodesLength - 3);
  stepInfoCaptionNode = stepInfoNode.childNodes.item(stepInfoNodeChildNodesLength-14);
  stepInfoDescriptionNode = stepInfoNode.childNodes.item(stepInfoNodeChildNodesLength-12);
  stepInfoInstructionsURLNode = stepInfoNode.childNodes.item(stepInfoNodeChildNodesLength-8);
  stepInfoNotesNode = stepInfoNode.childNodes.item(stepInfoNodeChildNodesLength-4);
  htmlTestTitle = stepInfoCaptionNode.getAttribute("value");
  htmlTestDescriptionTitle = stepInfoCaptionNode.getAttribute("value");
  htmlTestDescription = stepInfoNode.childNodes.item(stepInfoNodeChildNodesLength-12);
  htmlTestInstructionsURL = stepInfoInstructionsURLNode.getAttribute("value");
  if (htmlTestInstructionsURL.length > 0) {
    AFileName = Project.ConfigPath + "ManualTests\\" + manualTestNameNode.getAttribute("value") + "\\" + htmlTestInstructionsURL;
    htmText = aqFile.ReadWholeTextFile(AFileName, aqFile.ctUnicode);
    bodyTagStartIndex = aqString.Find(htmText, "<BODY>", 0, true);
    bodyTagEndIndex = aqString.Find(htmText, "</BODY>", 0, true);
    bodyTagText = aqString.SubString(htmText, bodyTagStartIndex+6, bodyTagEndIndex-6-bodyTagStartIndex);
  } else {
    bodyTagText = "";
  }
  numberOfSteps = Number(stepInfoCountNode.getAttribute("value"));  
  WriteContentToHtmlFile("<br>");
  WriteContentToHtmlFile("<H4><BLOCKQUOTE><b>" + "          " + "<A name=" + manualTestNameNode.getAttribute("value") + ">" + manualTestNameNode.getAttribute("value") + "</A>" + "</b></BLOCKQUOTE></H4>");
  WriteContentToHtmlFile("<p>");
  WriteContentToHtmlFile("<H5><BLOCKQUOTE><BLOCKQUOTE>" + "<u>Description</u> : " + stepInfoDescriptionNode.getAttribute("value") + "</BLOCKQUOTE></BLOCKQUOTE></H5>");      
  WriteContentToHtmlFile("<p>");
  if (bodyTagText.length > 0 && stepInfoNotesNode.getAttribute("value").length > 0) { 
      WriteContentToHtmlFile("<H5><BLOCKQUOTE><BLOCKQUOTE>" + "<u>Instructions</u> : " + bodyTagText + "<i>" + "   (Note: " + stepInfoNotesNode.getAttribute("value") + ")" + "</i></BLOCKQUOTE></BLOCKQUOTE></H5>");
      WriteContentToHtmlFile("<p>");
  } else if (bodyTagText.length > 0 && stepInfoNotesNode.getAttribute("value").length == 0) {
      WriteContentToHtmlFile("<H5><BLOCKQUOTE><BLOCKQUOTE>" + "<u>Instructions</u> : " + bodyTagText + "</BLOCKQUOTE></BLOCKQUOTE></H5>");
      WriteContentToHtmlFile("<p>");
  } else if (bodyTagText.length == 0 && stepInfoNotesNode.getAttribute("value").length > 0) {
      WriteContentToHtmlFile("<H5><BLOCKQUOTE><BLOCKQUOTE><i>" + "(Note: " + stepInfoNotesNode.getAttribute("value") + ")" + "</i></BLOCKQUOTE></BLOCKQUOTE></H5>");
      WriteContentToHtmlFile("<p>");
  } 
  for (var i=0; i<numberOfSteps; i++) {
    stepNode = stepInfoNode.childNodes.item(i);
    stepNodeName =  stepNode.getAttribute("name");
    if (stepNodeName == "step" + i + "info") {
       stepCaptionNode = stepNode.childNodes.item(0);
       stepDescriptionNode = stepNode.childNodes.item(2);
       stepInstructionsURLNode = stepNode.childNodes.item(6);
       stepNotesNode = stepNode.childNodes.item(10);
       AFileName = Project.ConfigPath + "ManualTests\\" + manualTestNameNode.getAttribute("value") + "\\" + stepInstructionsURLNode.getAttribute("value");
       if (AFileName.length > 0) {
         htmText = aqFile.ReadWholeTextFile(AFileName, aqFile.ctUnicode);
         bodyTagStartIndex = aqString.Find(htmText, "<BODY>", 0, true);
         bodyTagEndIndex = aqString.Find(htmText, "</BODY>", 0, true);
         bodyTagText = aqString.SubString(htmText, bodyTagStartIndex+6, bodyTagEndIndex-6-bodyTagStartIndex);
       }
       stepNotesAndComments = stepNotesNode.getAttribute("value");
       if (stepNotesAndComments.length > 0) {
          WriteContentToHtmlFile("<H5><BLOCKQUOTE><BLOCKQUOTE><BLOCKQUOTE><u>" + "Step " + (i+1) + "</u>" + ": " + bodyTagText + "<i>" + "   (Note: " + stepNotesAndComments + ")" + "</i>" + "</BLOCKQUOTE></BLOCKQUOTE></BLOCKQUOTE></H5>");
       } else {
          WriteContentToHtmlFile("<H5><BLOCKQUOTE><BLOCKQUOTE><BLOCKQUOTE><u>" + "Step " + (i+1) + "</u>" + ": " + bodyTagText + "</BLOCKQUOTE></BLOCKQUOTE></BLOCKQUOTE></H5>");
       }
       WriteContentToHtmlFile("<p>");
    }
    WriteContentToHtmlFile("<p>");
  }
}

function DeleteHtmlFile() {
  var htmBatchExportFileFullyQualifiedPath = Project.ConfigPath + "ManualTests\\" + "ManualTestsNav.htm";
  if (aqFile.Exists(htmBatchExportFileFullyQualifiedPath)) {
    aqFile.Delete(htmBatchExportFileFullyQualifiedPath);
  }
  var htmBatchExportFileFullyQualifiedPath = Project.ConfigPath + "ManualTests\\" + "ManualTestsContent.htm";
  if (aqFile.Exists(htmBatchExportFileFullyQualifiedPath)) {
    aqFile.Delete(htmBatchExportFileFullyQualifiedPath);
  }
} 

function WriteNavToHtmlFile(bodyTag) {
  var htmBatchExportFileFullyQualifiedPath = Project.ConfigPath + "ManualTests\\" + "ManualTestsNav.htm";
  var htmlHeader = '<HTML><HEAD><META name=GENERATOR content="MSHTML 8.00.6001.18943"><STYLE>BODY {FONT-FAMILY: "Arial"; FONT-SIZE: small}</STYLE></HEAD><BODY>';
  var htmlFooter = '</BODY></HEAD>';
  aqUtils.Delay(25, "Writing Manual Tests To HTML File...");
  if (!aqFile.Exists(htmBatchExportFileFullyQualifiedPath)) { 
      aqFile.Create(htmBatchExportFileFullyQualifiedPath);
      aqFile.WriteToTextFile(htmBatchExportFileFullyQualifiedPath, htmlHeader + "\r\n", aqFile.ctUnicode, false);
      aqFile.WriteToTextFile(htmBatchExportFileFullyQualifiedPath, "<p>" + "\r\n", aqFile.ctUnicode, false);
      aqFile.WriteToTextFile(htmBatchExportFileFullyQualifiedPath, bodyTag + "\r\n", aqFile.ctUnicode, false);
      aqFile.WriteToTextFile(htmBatchExportFileFullyQualifiedPath, "<p>" + "\r\n", aqFile.ctUnicode, false);
  } else if (bodyTag.length > 0) {
      aqFile.WriteToTextFile(htmBatchExportFileFullyQualifiedPath, bodyTag + "\r\n", aqFile.ctUnicode, false);
      aqFile.WriteToTextFile(htmBatchExportFileFullyQualifiedPath, "<p>" + "\r\n", aqFile.ctUnicode, false);
  } else {
      aqFile.WriteToTextFile(htmBatchExportFileFullyQualifiedPath, htmlFooter, aqFile.ctUnicode, false);
  }
} 

function WriteContentToHtmlFile(bodyTag) {
  var htmBatchExportFileFullyQualifiedPath = Project.ConfigPath + "ManualTests\\" + "ManualTestsContent.htm";
  var htmlHeader = '<HTML><HEAD><META name=GENERATOR content="MSHTML 8.00.6001.18943"><STYLE>BODY {FONT-FAMILY: "Arial"; FONT-SIZE: small}</STYLE></HEAD><BODY>';
  var htmlFooter = '</BODY></HEAD>';
  aqUtils.Delay(25, "Writing Manual Tests To HTML File...");
  if (!aqFile.Exists(htmBatchExportFileFullyQualifiedPath)) { 
      aqFile.Create(htmBatchExportFileFullyQualifiedPath);
      aqFile.WriteToTextFile(htmBatchExportFileFullyQualifiedPath, htmlHeader + "\r\n", aqFile.ctUnicode, false);
      aqFile.WriteToTextFile(htmBatchExportFileFullyQualifiedPath, "<p>" + "\r\n", aqFile.ctUnicode, false);
      aqFile.WriteToTextFile(htmBatchExportFileFullyQualifiedPath, bodyTag + "\r\n", aqFile.ctUnicode, false);
      aqFile.WriteToTextFile(htmBatchExportFileFullyQualifiedPath, "<p>" + "\r\n", aqFile.ctUnicode, false);
  } else if (bodyTag.length > 0) {
      aqFile.WriteToTextFile(htmBatchExportFileFullyQualifiedPath, bodyTag + "\r\n", aqFile.ctUnicode, false);
      aqFile.WriteToTextFile(htmBatchExportFileFullyQualifiedPath, "<p>" + "\r\n", aqFile.ctUnicode, false);
  } else {
      aqFile.WriteToTextFile(htmBatchExportFileFullyQualifiedPath, htmlFooter, aqFile.ctUnicode, false);
  }
}

function CreateHtmlTableOfContents() {
  
  var anchorList = new Array();
  aqUtils.Delay(500, "Creating Table Of Contents...");
  WriteNavToHtmlFile("<H3><b><u>Index</u></b></H3>");
  projectTestItems = Project.TestItems;
  milestonesFolder = projectTestItems.TestItem(0);
  milestoneFolderCount = milestonesFolder.ItemCount;
  for (var i=0; i<milestoneFolderCount; i++) {
    milestoneFolder = milestonesFolder.TestItem(i);
    sprintFolderCount = milestoneFolder.ItemCount;
    for (var j=0; j<sprintFolderCount; j++) {
      sprintFolder = milestoneFolder.TestItem(j);
      sprintFolderChildCount = sprintFolder.ItemCount;
      for (k=0; k<sprintFolderChildCount; k++) {
        testTypeFolderName = sprintFolder.TestItem(k).Name;
        if (testTypeFolderName == "Manual Tests") {
          manualTestsFolder = sprintFolder.TestItem(k);
          moduleFolderCount = manualTestsFolder.ItemCount;
          for (l=0; l<moduleFolderCount; l++) {
            moduleFolder = manualTestsFolder.TestItem(l);
            functionsFolderCount = moduleFolder.ItemCount;
            for (m=0; m<functionsFolderCount; m++) {
               functionFolder = moduleFolder.TestItem(m);
               manualTestsCount = functionFolder.ItemCount;
               for (n=0; n<manualTestsCount; n++) {
                  manualTest = functionFolder.TestItem(n);
                  if (manualTest.Enabled == true) {
                    anchorList.push(manualTest.Name);
                  }                                                              
               }
            }
          }
        }
      }
    }
    anchorList.sort();
    for (o=0; o<anchorList.length; o++) {
      WriteNavToHtmlFile('<H5><BLOCKQUOTE><A HREF="ManualTestsContent.htm#' + anchorList[o] + '"' + ' target="content"' + ">" + anchorList[o] + '</A></BLOCKQUOTE></H5>');          
    }
  }
  Log.Message("Export of Manual Tests Completed!");
  
}