function verifyObjectDoesNotExist(argObjProperty, argObjPropertyValue)
{
  var PropArray, ValuesArray, ConvertedPropArray, ConvertedValuesArray, p, w; 
  // Creates arrays of property names and values
  PropArray = new Array(argObjProperty);
  ValuesArray = new Array(argObjPropertyValue);
  // Converts arrays
  ConvertedPropArray = ConvertJScriptArray(PropArray);
  ConvertedValuesArray = ConvertJScriptArray(ValuesArray);
  // Searches for the window
  p = Aliases.Sys.iexplore2.pageSmartequip.objectSeweb;
  w = p.FindChild(ConvertedPropArray, ConvertedValuesArray);
  if (w.Exists)
    Log.Error("An object was found that should not exist");    
}

function ConvertJScriptArray(AArray)
{
  // Uses the Dictionary object to convert a JScript array
  var objDict = Sys.OleObject("Scripting.Dictionary");
  objDict.RemoveAll();
  for (var j in AArray)
    objDict.Add(j, AArray[j]);
  return objDict.Items();
}