<!--- 
/** 
* Copyright 2004-2006 massimocorner.com
* tmt_csv ColdFusion Component 
* Convert CSV strings into query objects and vice-versa
* @output      supressed 
* @author      Massimo Foti (massimo@massimocorner.com), with contributions from Giampaolo Bellavite (giampaolo@bellavite.com)
* @version     2.1.2, 2006-12-19
 */
  --->
<cfcomponent output="false" hint="Convert CSV strings into query objects and vice-versa">
	
	<!--- Ensure this file gets compiled using iso-8859-1 charset --->
	<cfprocessingdirective pageencoding="iso-8859-1">
	
	<!--- Set instance variables --->
	<cfscript>
	variables.delimiter = ",";
	variables.quotechar = '"';
	variables.trimCells = true;
	// Using commas and double quotes the pattern would looks like:
	// ("[^,]*)(,)(.*?"),
	variables.magicPattern ="(#variables.quotechar#[^#variables.delimiter#]*)(#variables.delimiter#)(.*?#variables.quotechar#)#variables.delimiter#";
	variables.magicStr = "§§§§";
    </cfscript>
	
	<!--- 
	/** 
	* Pseudo-constructor, it ensure custom settings are loaded inside the CFC. 
	  Use it only if you want to modify default settings
	* @access      public
	* @output      suppressed 
	* @param       delimiter (string)            Required. Default to false. Set delimiter char. Default to comma
	* @param       quotechar (string)            Required. Default to false. Set quoting char. Default to double quotes
	* @param       trimCells (boolean)           Required. Default to false. 
				   By default content inside cells will be trimmed before turning it into a query object. 
				   Set this to false if you want to keep leading and trailing space
	 */
	  --->
	<cffunction name="init" output="false" access="public" hint="
		Pseudo-constructor, it ensure custom settings are loaded inside the CFC. 
		Use it only if you want to modify default settings">
		<cfargument name="delimiter" type="string" required="true" default="false" hint="Set delimiter char. Default to comma">
		<cfargument name="quotechar" type="string" required="true" default="false" hint="Set quoting char. Default to double quotes">
		<cfargument name="trimCells" type="boolean" required="true" default="false" hint="
			By default content inside cells will be trimmed before turning it into a query object. 
			Set this to false if you want to keep leading and trailing space">
		<cfscript>
		if(arguments.trimCells){
			variables.trimCells = true;
		}
		else{
			variables.trimCells = false;
		}
		if(IsDefined('arguments.delimiter')){
			variables.delimiter = arguments.delimiter;
		}
		if(IsDefined('arguments.quotechar')){
			variables.quotechar = arguments.quotechar;
		}
		</cfscript>
		<cfreturn this>
	</cffunction>
	
	<!--- 
	/** 
	* Turn a string into an array of lines, using java.io.BufferedReader to maximize performances
	* @access      public
	* @output      suppressed 
	* @param       inString (string)             Required. Incoming string
	* @exception   tmt_csv
	* @return      array
	 */
	  --->
	<cffunction name="string2linesArray" access="public" output="false" returntype="array" hint="Turn a string into an array of lines, using java.io.BufferedReader to maximize performances">
		<cfargument name="inString" type="string" required="yes" hint="Incoming string">
		<cfscript>
		var linesArray = ArrayNew(1);
		var jReader = createObject("java","java.io.StringReader").init(arguments.inString);
		var jBuffer = createObject("java","java.io.BufferedReader").init(jReader);
		var line = jBuffer.readLine();	
		</cfscript>
		<cftry>
			<!--- 
			Unlike Java, CFML has no notion of null, but this is quite a special case. 
			Whenever readLine() reach the end of the file, it return a Java null, 
			as soon as the BufferedReader return null, ColdFusion "erase" the line variable, making it undefined. 
			Here we leverage this somewhat weird behavior by using it as test condition for the loop
			 --->
			<cfloop condition="#IsDefined("line")#">
				<cfset ArrayAppend(linesArray, line)>
				<cfset line=jBuffer.readLine()>
			</cfloop>
			<cfset jBuffer.close()>
			<cfcatch type="any">
				<!--- Something went wrong; we better close the stream anyway, just to be safe and leave no garbage behind --->
				<cfset jBuffer.close()>
				<cfthrow message="tmt_csv: Failed to read lines from string" type="tmt_csv">
			</cfcatch>
		</cftry>
		<cfreturn linesArray>
	</cffunction>
	
	<!--- 
	/** 
	* Turn an array of delimited strings into a CFML query
	* @access      public
	* @output      suppressed 
	* @param       linesArray (array)            Required. An array of lines
	* @param       columnsList (string)          Optional. Default to #list2ColumnNames(arguments.linesArray[1])#. Comma delimited list of columns. Default to the column names available inside the first line
	* @param       readFirstLine (boolean)       Optional. Default to false. By default the first line will be skipped (assuming it contains column names). Set this to true if you want to parse the first line as well
	* @return      query
	 */
	  --->
	<cffunction name="lines2query" access="public" output="false" returntype="query" hint="Turn an array of delimited strings into a CFML query">
		<cfargument name="linesArray" type="array" required="yes" hint="An array of lines">
		<cfargument name="columnsList" type="string" required="no" default="#list2ColumnNames(arguments.linesArray[1])#" hint="Comma delimited list of columns. Default to the column names available inside the first line">
		<cfargument name="readFirstLine" type="boolean" required="no" default="false" hint="By default the first line will be skipped (assuming it contains column names). Set this to true if you want to parse the first line as well">
		<cfscript>
		var columnsArray = ListToArray(arguments.columnsList);
		var csvQuery = QueryNew(arguments.columnsList);
		var placeHolderLine = "";
		var i = 1;
		var j = 1;
		var cellsArray = "";
		var queryCell = "";
		</cfscript>
		<!--- Loop over each line inside the array --->
		<cfloop index="i" from="#IIf(arguments.readFirstLine, 1, 2)# " to="#ArrayLen(arguments.linesArray)#">
			<!--- For each line, add a new row to the query --->
			<cfset QueryAddRow(csvQuery, 1)>
			<!--- 
			Delimiters chars inside cells make very hard to properly parse a delimited string. 
			In order to make things simpler, we replace them with magic strings. 
			After we are done, we will put back the delimiter chars. 
			It's definitely not the most elegant solution, but it does the job (most of the times)
			 --->
			<cfset placeHolderLine=arguments.linesArray[i].replaceAll(variables.magicPattern, "$1#variables.magicStr#$3,")>
			<!--- 
			Split the string and turn it into an array. It's easier than handling it as a list, 
			since CFML cause troubles as soon as the list contains an empty element
			 --->
			<cfset cellsArray=placeHolderLine.split(variables.delimiter)>
			<!--- 
			Loop over the array only up to the amount of columns we have. 
			This way if the line contains more fields than we expect, we simply ignore them and degrade gracefully
			 --->
			<cfloop index="j" from="1" to="#ArrayLen(columnsArray)#">
				<!--- 
				Here we handle a very special case, if the last cell in the line is empty, 
				the cell's array will contains one element less than needed, 
				so we insert an empty string instead
				 --->
				<cfif ArrayLen(cellsArray) GTE j>
					<!--- Get the current field content out of the array --->
					<cfset queryCell=cleanUpCSV(cellsArray[j])>
					<cfelse>
					<!--- The cell is empty (it's the last one in the line) --->
					<cfset queryCell="">
				</cfif>
				<!--- Get the relevant column out of the columnsArray and insert the field content inside it --->
				<cfset QuerySetCell(csvQuery, columnsArray[j], queryCell)>
			</cfloop>
		</cfloop>
		<cfreturn csvQuery>
	</cffunction>
	
	<!--- 
	/** 
	* Turn a delimited string into a CFML query
	* @access      public
	* @output      suppressed 
	* @param       csvString (string)            Required. Delimited string
	* @param       columnsList (string)          Optional. Comma delimited list of columns. Default to the column names available inside the first line
	* @param       readFirstLine (boolean)       Optional. Default to false. By default the first line will be skipped (assuming it contains column names). Set this to true if you want to parse the first line as well
	* @return      query
	 */
	  --->
	<cffunction name="string2query" access="public" output="false" returntype="query" hint="Turn a delimited string into a CFML query">
		<cfargument name="csvString" type="string" required="yes" hint="Delimited string">
		<cfargument name="columnsList" type="string" required="no" hint="Comma delimited list of columns. Default to the column names available inside the first line">
		<cfargument name="readFirstLine" type="boolean" required="no" default="false" hint="By default the first line will be skipped (assuming it contains column names). Set this to true if you want to parse the first line as well">
		<cfscript>
		var lines = string2linesArray(arguments.csvString);
		var columns = "";
		if(isDefined("arguments.columnsList")){
			columns = arguments.columnsList;
		}
		else{
			columns= list2ColumnNames(lines[1]);
		}
		</cfscript>
		<cfreturn lines2query(lines, columns, arguments.readFirstLine)>
	</cffunction>
	
	<!--- 
	/** 
	* Transform a query result into a CSV formatted string
	* @access      public
	* @output      suppressed 
	* @param       query (query)                 Required. CFML query object
	* @return      string
	 */
	  --->
	<cffunction name="query2CSV" access="public" output="false" returntype="string" hint="Transform a query result into a CSV formatted string">
		<cfargument name="query" type="query" required="yes" hint="CFML query object">
		<cfargument name="columnList" type="string" required="no" hint="Sorted list of columns">
		<cfargument name="includeHeaders" type="boolean" required="no" default="yes" hint="Set this to false if you do not want headers">
		<cfscript>
		var cvsStr = "";
		var columns = "";
		var i = 1;
		var j = 1;	
		var cr = chr(13) & chr(10);
		if (NOT structKeyExists(arguments,'columnList')){
			arguments.columnList = arguments.query.columnList;
		}
		columns = listToArray(arguments.columnList);
		if(arguments.includeHeaders EQ true){
			for(i=1; i LTE arrayLen(columns); i=i+1){
				cvsStr = cvsStr & columns[i] & variables.delimiter;
			}
		}
		cvsStr = cvsStr & cr;
		for(i=1; i LTE query.recordCount; i=i+1){
			for(j=1; j LTE arrayLen(columns); j=j+1){
				cvsStr = cvsStr & makeCSVsafe(query[columns[j]][i]) & variables.delimiter;
			}		
			cvsStr = cvsStr & cr;
		}
		return cvsStr;	
		</cfscript>
	</cffunction>
	
	<!--- Private methods --->
	
	<!--- 
	/** 
	* Perform a series of operation on the string in order to make it safe for CSV
	* @access      private
	* @output      suppressed 
	* @param       fieldString (string)          Required. String to sanitize
	* @return      string
	 */
	  --->
	<cffunction name="makeCSVsafe" access="private" output="false" returntype="string" hint="Perform a series of operation on the string in order to make it safe for CSV">
		<cfargument name="fieldString" type="string" required="yes" hint="String to sanitize">
		<cfscript>
		var fieldValue = arguments.fieldString;
		// If the field contains quote chars or separator, we must massage it
		if(
			(Find(variables.quotechar, fieldValue) GT 0)
			OR
			(Find(variables.delimiter, fieldValue) GT 0)
		){
			// First escape quote chars
			fieldValue = Replace(fieldValue, variables.quotechar, variables.quotechar & variables.quotechar, "ALL");
			// Then we quote the quole field
			fieldValue = variables.quotechar & fieldValue & variables.quotechar;
		}
		return fieldValue;
		</cfscript>
	</cffunction>
	
	<!--- 
	/** 
	* Perform a series of operation on the string (remove escaping, trimming and so on)
	* @access      private
	* @output      suppressed 
	* @param       fieldString (string)          Required. String to clean up
	* @return      string
	 */
	  --->
	<cffunction name="cleanUpCSV" access="private" output="false" returntype="string" hint="Perform a series of operation on the string (remove escaping, trimming and so on)">
		<cfargument name="fieldString" type="string" required="yes" hint="String to clean up">
		<cfscript>
		var fieldValue = arguments.fieldString;
		// Remove the magic strings and put back the delimiters
		fieldValue = fieldValue.replaceAll(variables.magicStr, variables.delimiter);	
		// Trim spaces
		if(variables.trimCells){
			fieldValue = Trim(fieldValue);
		}
		// Clean escaped quote chars 
		fieldValue = Replace(fieldValue, variables.quotechar & variables.quotechar, variables.quotechar, "ALL");
		// Remove leading and trailing quote chars
		if(fieldValue.startsWith(variables.quotechar)){
			fieldValue = REReplace(fieldValue, '^"', "");
		}
		if(fieldValue.endsWith(variables.quotechar)){
			fieldValue = REReplace(fieldValue, '"$', "");
		}
		return fieldValue;
		</cfscript>
	</cffunction>
	
	<!--- 
	/** 
	* Assure the colums list always use a comma as separator
	* @access      private
	* @output      suppressed 
	* @param       columnsList (string)          Required. Delimited list of columns
	* @return      string
	 */
	  --->
	<cffunction name="list2ColumnNames" access="private" output="false" returntype="string" hint="Assure the colums list always use a comma as separator">
		<cfargument name="columnsList" type="string" required="yes" hint="Delimited list of columns">
		<!--- Remove invalid characters from columnsList --->
		<cfset arguments.columnsList = ReReplaceNoCase(arguments.columnsList,'[^\w#variables.delimiter#]','_','ALL')>
		<!---  Be sure to use comma as list separator for columns --->
		<cfreturn ListChangeDelims(arguments.columnsList, ",", variables.delimiter)>
	</cffunction>
	
</cfcomponent>