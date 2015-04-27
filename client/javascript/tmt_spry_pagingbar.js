/**
* Copyright 2008 massimocorner.com
* License: http://www.massimocorner.com/license.htm
* @author      Massimo Foti (massimo@massimocorner.com)
* @version     1.0, 2008-12-16
* @require     SpryData.js and SpryPagedView.js
*/

if(typeof(tmt) == "undefined"){
	tmt = {};
}

if(typeof(tmt.spry) == "undefined"){
	tmt.spry = {};
}

tmt.spry.pagingbar = {};

/**
* Create an pagingbar object for an instance of Spry.Data.PagedView
* @param       pagedView    Required. Name of the Spry.Data.PagedView that will be associated with this widget
* @param       nodeId       Required. The id of the XHTML element that will contain the paging bar
* @param       options      Optional. An object containing name value pairs
*/
tmt.spry.pagingbar.factory = function(pagedView, nodeId, options){
	var pagingObj = {};
	pagingObj.pagedView = pagedView;
	pagingObj.nodeId = nodeId;
	if(!options){
		options = {};
	}
	// By default we show links, not pages
	if(!options.style){
		pagingObj.style = "links";
	}
	else{
		pagingObj.style = options.style;
	}
	if(!options.prev){
		pagingObj.prevText = "<";
	}
	else{
		pagingObj.prevText = options.prev;
	}
	if(!options.next){
		pagingObj.nextText = ">";
	}
	else{
		pagingObj.nextText = options.next;
	}
	if(!options.separator){
		pagingObj.separator = " | ";
	}
	else{
		pagingObj.separator = options.separator;
	}
	if(!options.maxlinks){
		pagingObj.maxlinks = 20;
	}
	else{
		pagingObj.maxlinks = options.maxlinks;
	}

	pagingObj.generateBar = function(){
		var barNode = Spry.$(pagingObj.nodeId);
		var pages = pagingObj.pagedView.getPageCount();
		var steps = pagedView.pageSize;
		var recordCount = pagedView.getData(true).length;
		var currentPageIndex = pagedView.getCurrentPage();
		// Math for mxlinks
		var startLink = parseInt(currentPageIndex - parseInt(pagingObj.maxlinks/2));
		if(startLink < 1){
			startLink = 1;
		}
		var tempPos = startLink + pagingObj.maxlinks - 1;
		var endlink = pages;
		if(tempPos < pages){
			endlink = tempPos;
		}
		if(endlink == pages){
			startLink = pages - pagingObj.maxlinks;
		}
		if(startLink < 1){
			startLink = 1;
		}
		barNode.innerHTML = "";
		if(pages > 1){
			// Create "previous" link
			var prevText = document.createTextNode(pagingObj.prevText);
			var prevLink = document.createElement("a");
			prevLink.setAttribute("href", "javascript:;");
			prevLink.onclick = function(){
				pagedView.previousPage()
			}
			prevLink.appendChild(prevText);
			if(currentPageIndex != 1){
				barNode.appendChild(prevLink);
			}
			else{
				barNode.appendChild(prevText);
			}
			barNode.appendChild(document.createTextNode(" "));
			// Create main links
			// Keep in mind page numbers are between 1 and n. So the loop start from 1
			for(var i=startLink; i<(endlink+1); i++){
				var linkText = "";
				// It's a pagebar
				if(pagingObj.style == "pages"){
					linkText = i;
				}
				// It's a linkbar
				else{
					var start = "";
					var end = "";
					if(i != 1){
						start = (steps * (i-1)) +1;
					}
					else{
						// First link
						start = 1;
					}
					if(i < (pages)){
						end = start + steps -1;
					}
					else{
						// Last link
						end = recordCount;
					}
					linkText = start + " - " + end;
				}
				var textNode = document.createTextNode(linkText);
				if(i != currentPageIndex){
					var linkNode = document.createElement("a");
					linkNode.appendChild(textNode);
					linkNode.setAttribute("href", "javascript:;");
					// Start weird hack
					linkNode.setAttribute("sprypage", i);
					linkNode.onclick = function(){
						pagedView.goToPage(this.getAttribute("sprypage"));
					}
					// End weird hack
					barNode.appendChild(linkNode);
				}
				// No link on current page
				else{
					var strongNode = document.createElement("strong");
					strongNode.appendChild(textNode);
					barNode.appendChild(strongNode);
				}
				// Add the separator until last page
				if(i < (endlink)){
					var separatorNode = document.createTextNode(pagingObj.separator);
					barNode.appendChild(separatorNode);
				}
			}
			// Create "next" link
			barNode.appendChild(document.createTextNode(" "));
			var nextText = document.createTextNode(pagingObj.nextText);
			var nextLink = document.createElement("a");
			nextLink.setAttribute("href", "javascript:;");
			nextLink.onclick = function(){
				pagedView.nextPage();
			}
			nextLink.appendChild(nextText);
			if(currentPageIndex != (pages)){
				barNode.appendChild(nextLink);
			}
			else{
				barNode.appendChild(nextText);
			}
		}
	}

	// This gets called by the Spry's dataset as soon as it finished loading data
	pagingObj.onPostLoad = function(dataSet, data){
		pagingObj.generateBar();
	}

	// This gets called by the Spry's dataset as soon as data is changed
	pagingObj.onDataChanged = function(dataSet, data){
		pagingObj.generateBar();
	}

	// Register as observer for Spry Pager
	pagedView.addObserver(pagingObj);

	return pagingObj;
}