function VerifyObjectExists(argObjProperty, argObjPropertyValue)
{
  var  PropNames, PropValues, ConvertedPropArray, ConvertedValuesArray;
  PropNames = new Array(argObjProperty);
  PropValues = new Array(argObjPropertyValue);
  ConvertedPropArray = ConvertJScriptArray(PropNames);
  ConvertedValuesArray = ConvertJScriptArray(PropValues);
  if (Aliases.Sys.iexplore.pageUserListSmartcare.panelPage.panelContent.panelMain.tableUsers.Find(ConvertedPropArray, ConvertedValuesArray, 1000, true).Exists == true) {
     return true;
  } else {
     return false;
  }
}

function ConvertJScriptArray(AArray)
{
  //Uses the Dictionary object to convert a JScript array.
  var objDict = Sys.OleObject("Scripting.Dictionary");
  objDict.RemoveAll();
  for(j = 0; j < AArray.length; j++)
    objDict.Add(j, AArray[j]);
  return objDict.Items();
}
