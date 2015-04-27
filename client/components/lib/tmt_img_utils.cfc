<!--- 
/** 
* Copyright 2008-2009 massimocorner.com
* tmt_img_utils ColdFusion Component 
* Simplify image manipulation. ColdFusion 8 or above required
* @output      supressed 
* @author      Massimo Foti (massimo@massimocorner.com).
* @version     1.1, 2009-03-02
*/
 --->

<cfcomponent output="no" hint="Simplify image manipulation. ColdFusion 8 or above required">

	<!--- Ensure this file gets compiled using iso-8859-1 charset --->
	<cfprocessingdirective pageencoding="iso-8859-1">
	
	<cfscript>
	// Interpolation method for resampling
	variables.interpolation = "mediumQuality";
	// JPEG quality used to encode images
	variables.quality = "0.75";
	// The blur factor used for resampling
	variables.blurFactor = "1";
	// Store the file I/O cfc as an instance variable
	variables.fileObj = "";
	// Suffix used by default
	variables.cropSuffix = "_crop";
	variables.resizeSuffix = "_resized";
	variables.rotateSuffix = "_rotated";
	variables.thumbSuffix = "_thumb";
	variables.watermarkSuffix = "_watermarked";
	</cfscript>
	
	<cffunction name="init" access="public" output="false" hint="
	Pseudo-constructor, it ensure settings are properly loaded inside the CFC. 
	It can also be handy if you want to define settings other than the default">
		<cfargument name="fileObj" type="tmt_file_io" required="true" hint="An instance of tmt_file_io.cfc">
		<cfargument name="interpolation" type="string" required="false" default="#variables.interpolation#" hint="The interpolation method for resampling. Default value is mediumQuality">
		<cfargument name="quality" type="string" required="false" default="#variables.quality#" hint="Defines the JPEG quality used to encode the image. Default value is 0.75">
		<cfargument name="blurFactor" type="numeric" required="false" default="#variables.blurFactor#" hint="The blur factor used for resampling. The higher the blur factor, the more blurred the image (also, the longer it takes to resize the image). Valid values are 1-10. Default value is 1">
		<cfscript>
		variables.fileObj = arguments.fileObj;
		variables.interpolation = arguments.interpolation;
		variables.quality = arguments.quality;
		variables.blurFactor = arguments.blurFactor;
		</cfscript>
		<cfreturn this>
	</cffunction>
	
	<cffunction name="crop" access="public" output="false" returntype="string" hint="Create a subimage, defined by a specified rectangular region">
		<cfargument name="source" type="string" required="true" hint="Original image path, either local or absolute">
		<cfargument name="destination" type="string" required="false" default="#addSuffix(arguments.source, variables.cropSuffix)#" hint="Cropped image path, either local or absolute">
		<cfargument name="x" type="numeric" required="false" default="0" hint="Starting coordinate in the x axis (pixel). Default to 0">
		<cfargument name="y" type="numeric" required="false" default="0" hint="Starting coordinate in the y axis (pixel). Default to 0">
		<cfargument name="width" type="numeric" required="false" default="100" hint="Width of the specified rectangular region (pixel). Default to 100">
		<cfargument name="height" type="numeric" required="false" default="100" hint="Height of the specified rectangular region (pixel). Default to 100">
		<cfargument name="deleteOriginal" type="boolean" required="false" default="false" hint="Delete the original file after the operation. Default to false">
		<cfscript>
		var image = readFile(arguments.source);
		ImageCrop(image, arguments.x, arguments.y, arguments.width, arguments.height);
		ImageWrite(image, arguments.destination, variables.quality);
		if(arguments.deleteOriginal){
			variables.fileObj.deleteFile(variables.fileObj.getAbsolutePath(arguments.source));
		}
		return arguments.destination;
		</cfscript>
	</cffunction>
	
	<cffunction name="cropThumbnail" access="public" output="false" returntype="string" hint="Create a subimage, defined by a specified rectangular region. Then create a thumbnail out of it">
		<cfargument name="source" type="string" required="true" hint="Original image path, either local or absolute">
		<cfargument name="destination" type="string" required="false" default="#addSuffix(arguments.source, variables.thumbSuffix)#" hint="Cropped image path, either local or absolute">
		<cfargument name="x" type="numeric" required="false" default="0" hint="Starting coordinate in the x axis (pixel). Default to 0">
		<cfargument name="y" type="numeric" required="false" default="0" hint="Starting coordinate in the y axis (pixel). Default to 0">
		<cfargument name="width" type="numeric" required="false" default="200" hint="Width of the specified rectangular region (pixel). Default to 200">
		<cfargument name="height" type="numeric" required="false" default="200" hint="Height of the specified rectangular region (pixel). Default to 200">
		<cfargument name="maxdimension" type="numeric" required="false" default="100" hint="Maximum image size allowed, for both width and height (pixels). Default to 100">
		<cfargument name="deleteOriginal" type="boolean" required="false" default="false" hint="Delete the original file after the operation. Default to false">
		<cfscript>
		var image = readFile(arguments.source);
		ImageCrop(image, arguments.x, arguments.y, arguments.width, arguments.height);
		ImageScaleToFit(image, arguments.maxdimension, arguments.maxdimension, variables.interpolation);
		ImageWrite(image, arguments.destination, variables.quality);
		if(arguments.deleteOriginal){
			variables.fileObj.deleteFile(variables.fileObj.getAbsolutePath(arguments.source));
		}
		return arguments.destination;
		</cfscript>
	</cffunction>
	
	<cffunction name="resize" access="public" output="false" returntype="string" hint="Resizes an image">
		<cfargument name="source" type="string" required="true" hint="Original image path, either local or absolute">
		<cfargument name="destination" type="string" required="false" default="#addSuffix(arguments.source, variables.resizeSuffix)#" hint="Resized image path, either local or absolute">
		<cfargument name="width" type="numeric" required="false" default="100" hint="New width (pixel). Default to 100">
		<cfargument name="height" type="numeric" required="false" default="100" hint="New height (pixel). Default to 100">
		<cfargument name="deleteOriginal" type="boolean" required="false" default="false" hint="Delete the original file after the operation. Default to false">
		<cfscript>
		var image = readFile(arguments.source);
		ImageResize(image, arguments.width, arguments.height, variables.interpolation, variables.blurFactor);
		ImageWrite(image, arguments.destination, variables.quality);
		if(arguments.deleteOriginal){
			variables.fileObj.deleteFile(variables.fileObj.getAbsolutePath(arguments.source));
		}
		return arguments.destination;
		</cfscript>
	</cffunction>
	
	<cffunction name="rotate" access="public" output="false" returntype="string" hint="Rotates an image">
		<cfargument name="source" type="string" required="true" hint="Original image path, either local or absolute">
		<cfargument name="destination" type="string" required="false" default="#addSuffix(arguments.source, variables.rotateSuffix)#" hint="Rotated image path, either local or absolute">
		<cfargument name="angle" type="string" required="true" default="90" hint="The rotation angle in degrees">
		<cfscript>
		var image = readFile(arguments.source);
		ImageRotate(image, arguments.angle);
		ImageWrite(image, arguments.destination, variables.quality);
		return arguments.destination;
		</cfscript>
	</cffunction>
	
	<cffunction name="thumbnail" access="public" output="false" returntype="string" hint="Create a thumbnail image">
		<cfargument name="source" type="string" required="true" hint="Original image path, either local or absolute">
		<cfargument name="destination" type="string" required="false" default="#addSuffix(arguments.source, variables.thumbSuffix)#" hint="Thumbnail image path, either local or absolute">
		<cfargument name="maxdimension" type="numeric" required="false" default="100" hint="Maximum image size allowed, for both width and height (pixels). Default to 100">
		<cfargument name="deleteOriginal" type="boolean" required="false" default="false" hint="Delete the original file after the operation. Default to false">
		<cfscript>
		var image = readFile(arguments.source);
		ImageScaleToFit(image, arguments.maxdimension, arguments.maxdimension, variables.interpolation);
		ImageWrite(image, arguments.destination, variables.quality);
		if(arguments.deleteOriginal){
			variables.fileObj.deleteFile(variables.fileObj.getAbsolutePath(arguments.source));
		}
		return arguments.destination;
		</cfscript>
	</cffunction>
	
	<cffunction name="uploadResample" access="public" output="false" returntype="string" hint="
	Uploads an image on the server using HTTP and resample it if bigger than a given dimension. 
	The method reset the value of form.filefield making it equal to the name of the file saved on the server 
	This way the file's name can be easily inserted inside a database (it's also very friendly for Dreamweaver's user)
	">
		<cfargument name="fileField" type="string" required="true" hint="The name of the form file field">
		<cfargument name="destination" type="string" required="true" hint="Absolute directory path of a directory where the file will be stored">
		<cfargument name="maxsize" type="numeric" required="false" default="1000" hint="Maximum file size allowed (kb). Default to 1000">
		<cfargument name="maxdimension" type="numeric" required="false" default="800" hint="Maximum image size allowed, for both width and height (pixels). Default to 800">
		<cfargument name="mimetypes" type="string" required="false" default="image/gif,image/jpeg,image/jpg,image/pjpeg,image/png" hint="Comma delimited list of mime types allowed. Default to: image/gif,image/jpeg,image/jpg,image/pjpeg,image/png">
		<cfargument name="nameconflict" type="string" required="false" default="makeunique" hint="Action to take if filename is the same as that of a file in the directory. Default to makeunique">
		<!--- Call tmt_file_io.cfc to do the HTTP upload  --->
		<cfset var imagePath = variables.fileObj.uploadFile(arguments.fileField, arguments.destination, arguments.maxsize, arguments.mimetypes, arguments.nameconflict)>
		<cfset var image = "">
		<cfset var exceptionUnsupported = "Image format is not supported by this ColdFusion server">
		<cftry>
			<cfset image = readFile(imagePath)>
			<cfcatch type="any">
				<!--- Unsupported image format, delete and notify --->
				<cfset variables.fileObj.deleteFile(imagePath)>
				<cfthrow message="#exceptionUnsupported#" detail="#cfcatch.detail#" type="tmt_img_utils">
			</cfcatch>
		</cftry>
		<cfif getWidth(imagePath) GT arguments.maxdimension>
			<!--- Image is too big. Resize --->
			<cfset thumbnail(imagePath, imagePath, arguments.maxdimension)>
		</cfif>
		<cfreturn imagePath>
	</cffunction>
	
	<cffunction name="watermark" access="public" output="false" returntype="string" hint="Add a watermark image">
		<cfargument name="source" type="string" required="true" hint="Original image path, either local or absolute">
		<cfargument name="destination" type="string" required="false" default="#addSuffix(arguments.source, variables.watermarkSuffix)#" hint="Watermarked image path, either local or absolute">
		<cfargument name="watermark" type="string" required="true" hint="Watermark image path, either local or absolute. Use a PNG with alpha channel for best results">
		<cfargument name="x" type="numeric" required="false" default="0" hint="Starting coordinate in the x axis (pixel) for the watermak. Default to 0">
		<cfargument name="y" type="numeric" required="false" default="0" hint="Starting coordinate in the y axis (pixel) for the watermak. Default to 0">
		<cfargument name="deleteOriginal" type="boolean" required="false" default="false" hint="Delete the original file after the operation. Default to false">
		<cfscript>
		var image = readFile(arguments.source);
		var watermarkImage = readFile(arguments.watermark);
		ImagePaste(image, watermarkImage, arguments.x, arguments.y);
		ImageWrite(image, arguments.destination, variables.quality);
		if(arguments.deleteOriginal){
			variables.fileObj.deleteFile(variables.fileObj.getAbsolutePath(arguments.source));
		}
		return arguments.destination;
		</cfscript>
	</cffunction>
	
	<!--- Getters --->
	
	<cffunction name="getAspectRatio" access="public" output="false" returntype="numeric" hint="Returns the aspect ratio of an image, with two decimal places and a thousands separator">
		<cfargument name="source" type="string" required="true" hint="Either an image object, a pathname or URL of the source image">
		<cfset var dim = getDimensions(readFile(arguments.source))>
		<cfreturn DecimalFormat(dim.width / dim.height)>
	</cffunction>
	
	<cffunction name="getDimensions" access="public" output="false" returntype="struct" hint="Returns a structure that contains image height and width">
		<cfargument name="source" type="string" required="true" hint="Either an image object, a pathname or URL of the source image">
		<cfset var imgInfo = getInfo(arguments.source)>
		<cfset var ret = StructNew()>
		<cfset ret["height"] = imgInfo.height>
		<cfset ret["width"] = imgInfo.width>
		<cfreturn ret>
	</cffunction>
	
	<cffunction name="getHeight" access="public" output="false" returntype="numeric" hint="Returns the height (pixels) of an image">
		<cfargument name="source" type="string" required="true" hint="Either an image object, a pathname or URL of the source image">
		<cfreturn ImageGetHeight(readFile(arguments.source))>
	</cffunction>
	
	<cffunction name="getWidth" access="public" output="false" returntype="numeric" hint="Returns the width (pixels) of an image">
		<cfargument name="source" type="string" required="true" hint="Either an image object, a pathname or URL of the source image">
		<cfreturn ImageGetWidth(readFile(arguments.source))>
	</cffunction>
	
	<cffunction name="getInfo" access="public" output="false" returntype="struct" hint="Returns a structure that contains information about the image, such as height, width, color model, size, and filename">
		<cfargument name="source" type="string" required="true" hint="Either an image object, a pathname or URL of the source image">
		<cfreturn ImageInfo(readFile(arguments.source))>
	</cffunction>
	
	<cffunction name="getExif" access="public" output="false" returntype="struct" hint="Return Exif data from a given image (if any)">
		<cfargument name="source" type="string" required="true" hint="Original image path, either local or absolute">
		<cfscript>
		var image = readFile(arguments.source);
		return ImageGetEXIFMetaData(image);
		</cfscript>
	</cffunction>
	
	<cffunction name="getIPT" access="public" output="false" returntype="struct" hint="Return IPT data from a given image (if any)">
		<cfargument name="source" type="string" required="true" hint="Original image path, either local or absolute">
		<cfscript>
		var image = readFile(arguments.source);
		return ImageGetIPTCMetadata(image);
		</cfscript>
	</cffunction>
	
	<!--- Utilities --->
	
	<cffunction name="addPrefix" access="public" output="true" returntype="string" hint="Utility method. Adds a prefix to a filename">
		<cfargument name="path" type="string" required="yes" hint="File path, either local or absolute">
		<cfargument name="prefixString" type="string" required="no" default="thumb_" hint="String used as prefix">
		<cfscript>
		var prefixedPath = "";
		var dirPath = GetDirectoryFromPath(arguments.path);
		var filename = GetFileFromPath(arguments.path);
		// If the directory is the current one, skip it
		if((dirPath EQ "/") OR (dirPath EQ "\")){
			dirPath = "";
		}
		return dirPath & arguments.prefixString & filename;
		</cfscript>
	</cffunction>
	
	<cffunction name="addSuffix" access="public" output="true" returntype="string" hint="Utility method. Adds a prefix to a filename">
		<cfargument name="path" type="string" required="yes" hint="File path, either local or absolute">
		<cfargument name="suffixString" type="string" required="no" default="_thumb" hint="String used as prefix">
		<cfscript>
		var prefixedPath = "";
		var dirPath = GetDirectoryFromPath(arguments.path);
		var fileExtension = ListLast(arguments.path, ".");
		var filename = ListFirst(GetFileFromPath(arguments.path), ".");
		// If the directory is the current one, skip it
		if((dirPath EQ "/") OR (dirPath EQ "\")){
			dirPath = "";
		}
		return dirPath & filename & arguments.suffixString & "." & fileExtension;
		</cfscript>
	</cffunction>
	
	<!--- Private methods --->
	
	<cffunction name="readFile" access="private" output="false" hint="Reads the source pathname or URL and return a ColdFusion image">
		<cfargument name="source" type="string" required="true" hint="Either an image object, a pathname or URL of the source image">
		<cfif IsImage(arguments.source)>
			<cfreturn arguments.source>
		<cfelse>
			<cfif IsImageFile(arguments.source)>
				<cfreturn ImageRead(arguments.source)>
			<cfelse>
				<cfthrow message="Either #arguments.source#'s format is not supported by this ColdFusion server, or the pathname/url to the image file is null or invalid" type="tmt_img_utils">
			</cfif>
		</cfif>
	</cffunction>

</cfcomponent>