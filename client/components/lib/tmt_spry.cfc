<!---
/** 
* tmt_spry ColdFusion Component 
* RA component that make it simpler to integrate Spry with ColdFusion. ColdFusion 7 or above required
* @output      supressed 
* @author      Massimo Foti (massimo@massimocorner.com).
* @version     1.0, 2008-05-15
 */
  --->
<cfcomponent output="false" hint="A component that make it simpler to integrate Spry with ColdFusion. ColdFusion 7 or above required">

	<!--- Ensure this file gets compiled using iso-8859-1 charset --->
	<cfprocessingdirective pageencoding="iso-8859-1">

	<!--- 
	/** 
	* Marshall a CFML query into a Spry's dataset that can be used inline inside JavaScript code
	* @access      public
	* @output      suppressed 
	* @param       inputData (query)             Required. Query to be converted
	* @param       datasetName (string)          Required. Dataset name
	* @return      string
	 */
	  --->
	<cffunction name="toDataSet" access="public" output="false" returntype="string" hint="Marshall a CFML query into a Spry's dataset that can be used inline inside JavaScript code">
		<cfargument name="inputData" type="query" required="yes" hint="Query to be converted">
		<cfargument name="datasetName" type="string" required="yes" hint="Dataset name">
		<cfset var retStr = "">
		<cfset var jsStr = "">
		<cfset var fieldsList = LCase(arguments.inputData.columnList)>
		<cfset var jsRow = "">
		<cfset var x = "">
		<cfset var fieldStr = "">
		<cfloop query="arguments.inputData">
			<cfset jsRow = 'ds_RowID: "ROWID-#CurrentRow#"'>
			<cfloop index="x" list="#fieldsList#">
				<cfset fieldStr = x & ': "' & JSStringFormat(arguments.inputData[x][arguments.inputData.currentRow]) & '"'>
				<cfset jsRow = ListAppend(jsRow, fieldStr)>
			</cfloop>
			<cfset jsRow = "{ " & jsRow & " }">
			<cfif arguments.inputData.CurrentRow NEQ arguments.inputData.RecordCount>
				<cfset jsRow = jsRow & ',' & Chr(13)& Chr(10)>
			</cfif>
			<cfset jsStr = jsStr & jsRow>
		</cfloop>
		<cfsavecontent variable="retStr">
			<cfoutput>
			var #arguments.datasetName# = new Spry.Data.DataSet();
			#arguments.datasetName#.data = [
				#jsStr#
			];
			var #arguments.datasetName#tmtHash = [];
			for(var i = 0; i < #arguments.datasetName#.data.length; i++){
				#arguments.datasetName#tmtHash[i] = #arguments.datasetName#.data[i];
			}
			#arguments.datasetName#.dataHash = #arguments.datasetName#tmtHash;
			#arguments.datasetName#.loadData();
			</cfoutput>
		</cfsavecontent>
		<cfreturn retStr>
	</cffunction>

	<!--- 
	/** 
	* Marshall a CFML query into a tmt.spry.Dataset dataset (seee: http://www.massimocorner.com/libraries/spry/dataset/) that can be used inline inside JavaScript code
	* @access      public
	* @output      suppressed 
	* @param       inputData (query)             Required. Query to be converted
	* @param       datasetName (string)          Required. Dataset name
	* @return      string
	 */
	  --->
	<cffunction name="toTmtDataSet" access="public" output="false" returntype="string" hint="Marshall a CFML query into a tmt.spry.Dataset dataset (seee: http://www.massimocorner.com/libraries/spry/dataset/) that can be used inline inside JavaScript code">
		<cfargument name="inputData" type="query" required="yes" hint="Query to be converted">
		<cfargument name="datasetName" type="string" required="yes" hint="Dataset name">
		<cfset var retStr = "">
		<cfset var jsStr = "">
		<cfset var fieldsList = LCase(arguments.inputData.columnList)>
		<cfset var jsRow = "">
		<cfset var x = "">
		<cfset var fieldStr = "">
		<cfloop query="arguments.inputData">
			<cfset jsRow = "">
			<cfloop index="x" list="#fieldsList#">
				<cfset fieldStr = x & ': "' & JSStringFormat(arguments.inputData[x][arguments.inputData.currentRow]) & '"'>
				<cfset jsRow = ListAppend(jsRow, fieldStr)>
			</cfloop>
			<cfset jsRow = "{ " & jsRow & " }">
			<cfif arguments.inputData.CurrentRow NEQ arguments.inputData.RecordCount>
				<cfset jsRow = jsRow & ',' & Chr(13)& Chr(10)>
			</cfif>
			<cfset jsStr = jsStr & jsRow>
		</cfloop>
		<cfsavecontent variable="retStr">
			<cfoutput> 
			var #arguments.datasetName#_tmtDataRows = [ 
				#jsStr#
			];
			var #arguments.datasetName# = new tmt.spry.Dataset();
			#arguments.datasetName#.insertRows(#arguments.datasetName#_tmtDataRows);
			</cfoutput>
		</cfsavecontent>
		<cfreturn retStr>
	</cffunction>

	<!--- 
	/** 
	* Serialize a ColdFusion query into an XML string that can be easily consumed by Spry. All XML tags will be in lowercase
	* @access      public
	* @output      suppressed 
	* @param       inputData (query)             Required. Query to be converted
	* @param       rootTag (string)              Optional. Default to dataset. Optional. Name to be used for XML's root node. Default to *dataset*
	* @param       rowTag (string)               Optional. Default to row. Optional. Name to be used for row node. Default to *row*
	* @return      string
	 */
	  --->
	<cffunction name="toXML" access="public" output="false" returntype="string" hint="Serialize a ColdFusion query into an XML string that can be easily consumed by Spry. All XML tags will be in lowercase">
		<cfargument name="inputData" type="query" required="yes" hint="Query to be converted">
		<cfargument name="rootTag" type="string" required="no" default="dataset" hint="Optional. Name to be used for XML's root node. Default to *dataset*">
		<cfargument name="rowTag" type="string" required="no" default="row" hint="Optional. Name to be used for row node. Default to *row*">
		<cfset var fieldsList = LCase(arguments.inputData.columnList)>
		<cfset var xmlStr = "<#arguments.rootTag#>">
		<cfset var x = "">
		<cfset var rowStr = "">
		<cfloop query="arguments.inputData">
			<cfset rowStr = "">
			<cfloop index="x" list="#fieldsList#">
				<cfset rowStr = rowStr & "<" & x & ">" & XMLFormat(arguments.inputData[x][arguments.inputData.currentRow]) & "</" & x & ">">
			</cfloop>
			<cfset xmlStr = xmlStr & "<#arguments.rowTag#>" & rowStr & "</#arguments.rowTag#>" & Chr(13)& Chr(10)>
		</cfloop>
		<cfset xmlStr = xmlStr & "</#arguments.rootTag#>">
		<cfreturn xmlStr>
	</cffunction>

</cfcomponent>