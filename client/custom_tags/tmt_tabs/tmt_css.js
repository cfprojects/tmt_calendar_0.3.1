/** 
* Copyright 2006-2008 massimocorner.com
* License: http://www.massimocorner.com/license.htm
* @author      Massimo Foti (massimo@massimocorner.com)
* @version     0.3.2, 2008-04-27
* @require     tmt_core.js
*/

if(typeof(tmt) == "undefined"){
	alert("Error: tmt.core JavaScript library missing");
}

tmt.css = {};

/**
* Set display to "block" on a list of nodes. Accepts either ids (strings) or DOM node references
*/
tmt.css.displayBlock = function(){
	var nodes = tmt.get(arguments);
	for(var i=0; i<nodes.length; i++){
		tmt.css.setStyleProperty(nodes[i], "display", "block");
	}
}

/**
* Set display to "none" on a list of nodes. Accepts either ids (strings) or DOM node references
*/
tmt.css.displayNone = function(){
	var nodes = tmt.get(arguments);
	for(var i=0; i<nodes.length; i++){
		tmt.css.setStyleProperty(nodes[i], "display", "none");
	}
}

/**
* Toggle display of a given set of nodes
* If it's "block" it set it to "none" and viceversa. Accepts either ids (strings) or DOM node references
*/
tmt.css.toggleDisplay = function(){
	var nodes = tmt.get(arguments);
	for(var i=0; i<nodes.length; i++){
		var currentStatus = tmt.css.getStyleProperty(nodes[i], "display");
		var newStatus = (currentStatus != "block") ? "block" : "none";
		tmt.css.setStyleProperty(nodes[i], "display", newStatus);
	}
}

/**
* Set visibility to "visible" on a list of nodes. Accepts either ids (strings) or DOM node references
*/
tmt.css.show = function(){
	var nodes = tmt.get(arguments);
	for(var i=0; i<nodes.length; i++){
		tmt.css.setStyleProperty(nodes[i], "visibility", "visible");
	}
}

/**
* Set visibility to "hidden" on a list of nodes. Accepts either ids (strings) or DOM node references
*/
tmt.css.hide = function(){
	var nodes = tmt.get(arguments);
	for(var i=0; i<nodes.length; i++){
		tmt.css.setStyleProperty(nodes[i], "visibility", "hidden");
	}
}

/**
* Toggle visibility of a given set of nodes
* If it's "visible" it set it to "hidden" and viceversa. Accepts either ids (strings) or DOM node references
*/
tmt.css.toggle = function(){
	var nodes = tmt.get(arguments);
	for(var i=0; i<nodes.length; i++){
		var currentStatus = tmt.css.getStyleProperty(nodes[i], "visibility");
		var newStatus = (currentStatus != "visible") ? "visible" : "hidden";
		tmt.css.setStyleProperty(nodes[i], "visibility", newStatus);
	}
}

/**
* Return an array of nodes that contain the given class
* If no starting node is passed, assume the document is the starting point
*/
tmt.css.getNodesByClass = function(className, startNode){
	var nodes = tmt.getAllNodes(startNode);
	var filteredNodes = new Array();
	for(var i=0; i<nodes.length; i++){
		if(tmt.hasClass(nodes[i], className)){
			filteredNodes.push(nodes[i]);
		}
	}
	return filteredNodes;
}

/**
* Get the value of a specified CSS property out of a given node. Accepts either an id (string) or a DOM node reference
*/
tmt.css.getStyleProperty = function(element, property){
	var nodeElem = tmt.get(element);
	try{
		if(nodeElem.style[property]){
			return nodeElem.style[property];
		}
		else if(nodeElem.currentStyle){
			return nodeElem.currentStyle[property];
		}
		else if(document.defaultView && document.defaultView.getComputedStyle){
			var style = document.defaultView.getComputedStyle(nodeElem, null);
			return style.getPropertyValue(property);
		}
	}
	catch(e){}
	return null;
}

/**
* Set the value of a CSS property on a given node. Accepts either an id (string) or a DOM node reference
*/
tmt.css.setStyleProperty = function(element, propName, propValue){
	var nodeElem = tmt.get(element);
	if(nodeElem){
		nodeElem.style[propName] = propValue;
	}
}