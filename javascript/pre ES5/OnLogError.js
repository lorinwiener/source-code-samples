function OnLogError(Sender, LogParams)
{
  Log.Warning("Keyword Test Failed!");
  Log.Picture(Sys.Desktop.ActiveWindow(), "Here is what the screen looked like when the error occured.", "Extended Message Text", pmHighest);
  aqUtils.Delay (1000, "Waiting for log to complete");
  Runner.Stop(true);  
}
