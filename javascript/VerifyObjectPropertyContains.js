function VerifyObjectPropertyContains(curPropertyValue, argPropertyValue) {

		if (aqString.Contains(curPropertyValue, argPropertyValue, 0, true) != -1) {
			  return true;
		 } else {
			  return false;
		}
	                              
}