<!--- 
/** 
* 
Return the relative path from startPath to destinationPath.
Paths can be system paths (C:\myroot\mydir\myfile.cfm) or url (http://www.mydomain/myfile.cfm).
Different kinds of paths (system and url) can't be mixed
* @access      public
* @output      suppressed 
* @param       startPath (string)            Required. Full starting path
* @param       destinationPath (string)      Required. Full destination path
* @return      string
* @author      Massimo Foti (massimo@massimocorner.com)
* @version     3.0, 2008-12-02
 */
  --->
<cffunction name="getRelativePath" access="public" output="false" returntype="string" hint="
Return the relative path from startPath to destinationPath.
Paths can be system paths (C:\myroot\mydir\myfile.cfm) or url (http://www.mydomain/myfile.cfm).
Different kinds of paths (system and url) can't be mixed">
	<cfargument name="startingPath" type="string" required="true" hint="Full starting path">
	<cfargument name="destinationPath" type="string" required="true" hint="Full destination path">
	<cfscript>
	// In case we have absolute local paths, turn backward to forward slashes
	var startPath = Replace(arguments.startingPath, "\","/", "ALL"); 
	var endPath = Replace(arguments.destinationPath, "\","/", "ALL"); 
	// Declare variables
	var i = 1;
	var j = 1;
	var endBase = "";
	var commonStr = "";
	var retVal = "";
	var whatsLeft = "";
	var slashPos = "";
	var slashCount = 0;
	var dotDotSlash = "";
	// Special case, paths are the same
	if(startPath EQ endPath){
		return "";
	}
	// Special case, the files are both inside the same base directory
	if(GetDirectoryFromPath(startPath) EQ GetDirectoryFromPath(endPath)){
		return GetFileFromPath(endPath);
	}
	// If the starting path contains more directories, the destination path is our starting point
	if(ListLen(startPath, "/") GT ListLen(endPath, "/")){
		endBase = GetDirectoryFromPath(endPath);
	}
	// Else the start path is the starting point
	else{
		endBase = GetDirectoryFromPath(startPath);
	}
	// Check if the two paths share a base path and store it into the commonStr variable
	for(i; i LTE Len(endBase); i=i+1){
		// Compare one character at time
		if(Mid(startPath, i, 1) EQ Mid(endPath, i, 1)){
			commonStr = commonStr & Mid(startPath, i, 1);
		}
		else{
			break;
		}
	}
	// We just need the common base directory
	commonStr = GetDirectoryFromPath(commonStr);
	// If there is a common base path, remove it
	if(Len(commonStr) GT 0){
		whatsLeft = Mid(startPath, Len(commonStr)+1, Len(startPath));
	}
	else{
		whatsLeft = startPath;
	}
	slashPos = Find("/", whatsLeft);
	// Count how many directories we have to climb
	while(slashPos NEQ 0){
		slashCount = slashCount + 1;
		slashPos = Find("/", whatsLeft, slashPos+1);
	}
	// Append "../" for each directory we have to climb
	for(j; j LTE slashCount; j=j+1){
		dotDotSlash = dotDotSlash & "../";
	}
	// Assemble the final path
	retVal = dotDotSlash & Mid(endPath, Len(commonStr)+1, Len(endPath));
	return retVal;
	</cfscript>
</cffunction>