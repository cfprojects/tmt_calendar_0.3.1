/** 
* Copyright 2006-2008 massimocorner.com
* @author      Massimo Foti (massimo@massimocorner.com)
* @version     3.0, 2008-05-20
* @require     tmt_core.js
* @require     tmt_css.js
*/

if(typeof(tmt) == "undefined"){
	alert("Error: tmt.core JavaScript library missing");
}

if(typeof(tmt.css) == "undefined"){
	alert("Error: tmt.css JavaScript library missing");
}

if(typeof(tmt.widget) == "undefined"){
	tmt.widget = {};
}

tmt.widget.tab = {};

tmt.widget.tab.SELECTED_CLASS = "tmtTabSelected";
tmt.widget.tab.ERROR_CLASS = "tmtTabError";

tmt.widget.tab.groupFactory = function(rootNode){
	var obj = {};
	obj.rootNode = rootNode;
	obj.currentPosition = 0;
	obj.tabs = [];
	obj.insideForm = false;
	obj.formNode = null;
	if(obj.rootNode.getAttribute("tmt:tabform")){
		if(typeof(tmt.validator) == "undefined"){
			alert("Error: TMT Validator JavaScript library missing");
		}
		obj.insideForm = true;
		obj.formNode = tmt.form.getParentForm(obj.rootNode);
	}
	var childDivs = obj.rootNode.getElementsByTagName("div");
	// First <div>, containing all <a> labels
	obj.labelsContainer = childDivs[0];
	var labelNodes = childDivs[0].getElementsByTagName("a");
	// Second <div>, containing all the panels
	obj.tabsContainer = childDivs[1];
	var innerDivs = obj.tabsContainer.getElementsByTagName("div");
	var panelDivs = tmt.filterNodesByAttributeValue("tmt:tabpanel", "true", innerDivs);
	// Be sure labels match panels
	if(labelNodes.length != panelDivs.length){
		alert("Error in tmt.widget.tab: the number of labels doesn't match the number of panels");
		return;
	}
	// Create panel objects
	for(var i=0; i<panelDivs.length; i++){
		var childPanel = tmt.widget.tab.panelFactory(obj, panelDivs[i], labelNodes[i], i);
		obj.tabs.push(childPanel);
	}

	// Check if we have a tab inside the given position. Alert otherwise
	obj.checkPositionRange = function(position){
		if((position < 0) || (position > obj.tabs.length)){
			alert("Error: tab position " + position + " is out of range");
			return false;
		}
		return true;
	}

	// Returns already visited tab objects
	obj.getVisitedPanels = function(){
		var retPanels = [];
		for(var i=0; i<obj.tabs.length; i++){	
			if(obj.tabs[i].isVisited()){
				retPanels.push(obj.tabs[i]);
			}
		}
		return retPanels;
	}

	// Returns true if we have to validate form fields whenever we switch tabs
	obj.hasForm = function(){
		return (obj.insideForm && obj.formNode);
	}

	obj.getValidationCallback = function(){
		if(obj.rootNode.getAttribute("tmt:tabformcallback")){
			return obj.rootNode.getAttribute("tmt:tabformcallback");
		}
		return tmt.validator.DEFAULT_CALLBACK_MULTISECTION;
	}

	// Open the tab in the given position (zero based)
	obj.go = function(position){
		if(obj.checkPositionRange(position)){
			for(var j=0; j<obj.tabs.length; j++){
				obj.tabs[j].hide();
			}
			// Flag previous panel as visited
			obj.tabs[obj.currentPosition].setVisited()
			obj.tabs[position].show();
			obj.validate();
			obj.currentPosition = position;
		}
	}

	// Open next tab
	obj.next = function(){
		var nextPosition = parseInt(obj.currentPosition) + 1;
		// If we reached the final tab, go to first tab
		if(nextPosition == (obj.tabs.length)){
			nextPosition = 0;
		}
		obj.go(nextPosition);
	}

	// Open previous tab
	obj.previous = function(){
		var prevPosition = parseInt(obj.currentPosition) - 1;
		// If we reached the first tab, go to last tab
		if(prevPosition < 0){
			prevPosition = obj.tabs.length -1;
		}
		obj.go(prevPosition);
	}

	// Validate form fields inside already visited tabs
	obj.validate = function(all){
		var panels = obj.getVisitedPanels();
		if(all){
			panels = obj.tabs;
		}
		if(obj.hasForm()){
			var results = obj.validatePanels(panels);
			var callback = obj.getValidationCallback();
			// Forward results to the callback
			eval(callback + "(obj.formNode, results.hasErrors, results.sectionResults)");
			return results.hasErrors == false;
		}
		return true;
	}

	// Validate form fields inside all tabs
	obj.validateAll = function(){
		return obj.validate(true);
	}

	// Validate panels, returns a results object
	obj.validatePanels = function(panels){
		var sectionResults = [];
		var hasErrors = false;
		for(var i=0; i<panels.length; i++){
			var panelResults = {};
			panelResults.label = panels[i].name;
			panelResults.validators = [];
			var validators = panels[i].getValidators();
			var activeValidators = tmt.validator.executeValidators(validators);
			// If errors, attach active validators
			if(activeValidators.length > 0){
				panelResults.validators = activeValidators;
				panels[i].flagInvalid();
				hasErrors = true;
			}
			else{
				panels[i].flagValid();
			}
			sectionResults.push(panelResults);
		}
		return {sectionResults: sectionResults, hasErrors: hasErrors};
	}

	return obj;
}

tmt.widget.tab.panelFactory = function(containerObj, divNode, aNode, index){
	var obj = {};
	obj.container = containerObj;
	obj.panelNode = divNode;
	obj.labelNode = aNode;
	obj.name = obj.labelNode.innerHTML;
	obj.position = index;
	obj.visited = false;

	obj.getValidators = function(){
		var fields = tmt.form.getChildFields(obj.panelNode);
		var validators = [];
		for(var i=0; i<fields.length; i++){
			validators.push(tmt.validator.fieldValidatorFactory(fields[i]));
		}
		return validators;
	}

	obj.flagInvalid = function(){
		tmt.addClass(obj.labelNode, tmt.widget.tab.ERROR_CLASS);
	}

	obj.flagValid = function(){
		tmt.removeClass(obj.labelNode, tmt.widget.tab.ERROR_CLASS);
	}

	obj.hide = function(){
		tmt.css.displayNone(obj.panelNode);
		tmt.removeClass(obj.labelNode, tmt.widget.tab.SELECTED_CLASS);
	}

	obj.isVisited = function(){
		return obj.visited;
	}

	obj.setVisited = function(){
		obj.visited = true;
	}

	obj.show = function(){
		tmt.css.displayBlock(obj.panelNode);
		tmt.addClass(obj.labelNode, tmt.widget.tab.SELECTED_CLASS);
	}

	obj.clickHandler = function(){
		obj.container.go(obj.position);
	}

	tmt.addEvent(obj.labelNode, "click", obj.clickHandler);
	return obj;
}

tmt.widget.tab.init = function(){
	var divNodes = document.getElementsByTagName("div");
	var panelNodes = tmt.filterNodesByAttributeValue("tmt:tabgroup", "true", divNodes);
	for(var i=0; i<panelNodes.length; i++){
		panelNodes[i].tmtTabGroup = tmt.widget.tab.groupFactory(panelNodes[i]);
	}
}

// Global object storing utility methods
tmt.widget.tab.util = {};

// Private method. Given a <div> node or its id, return its tabs object
tmt.widget.tab.util.getObjFromNode = function(containerNode){
	var targetNode = tmt.get(containerNode);
	if(!targetNode){
		alert("Error: unable to find the requested tab group");
		return null;
	}
	var targetObj = targetNode.tmtTabGroup;
	if(!targetObj){
		alert("Error: the requested element is not a tab group. Verify it contains the tmt:tabgroup attribute");
		return null;
	}
	return targetObj;
}

/**
* Given a <div> node or its id, open the required tab (tab position is zero based)
*/
tmt.widget.tab.util.goTo = function(containerNode, position){
	var tabGroupObj = tmt.widget.tab.util.getObjFromNode(containerNode);
	tabGroupObj.go(position);
}

/**
* Given a <div> node or its id, open the next available tab
*/
tmt.widget.tab.util.next = function(containerNode){
	var tabGroupObj = tmt.widget.tab.util.getObjFromNode(containerNode);
	tabGroupObj.next();
}

/**
* Given a <div> node or its id, open the previous available tab
*/
tmt.widget.tab.util.previous = function(containerNode){
	var tabGroupObj = tmt.widget.tab.util.getObjFromNode(containerNode);
	tabGroupObj.previous();
}

/**
* Given a <div> node or its id, validate form fields inside all tabs
*/
tmt.widget.tab.util.validate = function(containerNode){
	var tabGroupObj = tmt.widget.tab.util.getObjFromNode(containerNode);
	return tabGroupObj.validateAll();
}

tmt.addEvent(window, "load", tmt.widget.tab.init);