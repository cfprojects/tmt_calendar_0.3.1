/** 
* Copyright 2006-2009 massimocorner.com
* License: http://www.massimocorner.com/license.htm
* @author      Massimo Foti (massimo@massimocorner.com)
* @version     0.8.1, 2009-03-09
* @require     tmt_core.js
* @require     tmt_net.js
* @require     tmt_form.js
*/

if(typeof(tmt) == "undefined"){
	alert("Error: tmt.core JavaScript library missing");
}

tmt.ajaxform = {};

// Constants
tmt.ajaxform.AJAX_USER_AGENT = "tmt.ajaxform";

// Check all dependancies
tmt.ajaxform.checkDependancies = function(){
	// Check all dependancies
	if(typeof(tmt.net) == "undefined"){
		alert("Error: tmt.net JavaScript library missing");
		return;
	}
	else{
		if(typeof(tmt.form) == "undefined"){
			alert("Error: tmt.form JavaScript library missing");
			return;
		}
	}
}

tmt.ajaxform.init = function(){
	tmt.ajaxform.checkDependancies();
	var formNodes = document.getElementsByTagName("form");
	var canSend = true;
	for(var i=0; i<formNodes.length; i++){
		if(formNodes[i].getAttribute("tmt:ajaxform") == "true"){
			// Attach an ajaxform object to each form that requires it
			formNodes[i].tmtAjaxform = tmt.ajaxform.factory(formNodes[i]);
			if(typeof formNodes[i].onsubmit != "function"){
				formNodes[i].onsubmit = function(){
					// Hack for TMT Validator, I wasn't able to find a better, cross-browser alternative :-(
					if(this.tmt_validator){
						canSend = tmt.validator.validateForm(this);
					}
					if(canSend){
						return this.tmtAjaxform.send();
					}
					return false;
				}
			}
			else{
				// Store a reference to the old function
				formNodes[i].tmtOldSubmit = formNodes[i].onsubmit;
				formNodes[i].onsubmit = function(){
					// Check if the existing function return true
					canSend = this.tmtOldSubmit();
					if(this.tmt_validator && canSend){
						canSend = tmt.validator.validateForm(this);
					}
					if(canSend){
						return this.tmtAjaxform.send();
					}
					return false;
				}
			}
		}
	}
}

tmt.ajaxform.factory = function(formNode){
	var obj = {};
	obj.form = formNode;
	obj.action = obj.form.getAttribute("action") || document.location.href;
	obj.method = "GET";
	if(obj.form.getAttribute("method") && obj.form.getAttribute("method").toUpperCase() == "POST" ){
		obj.method = "POST";
	}

	obj.message = "";
	if(obj.form.getAttribute("tmt:ajaxmessage")){
		obj.message = obj.form.getAttribute("tmt:ajaxmessage");
	}
	obj.defaultCallback = function(){
		// Response text overwrite the message only if tmt:ajaxmessage is missing
		if(obj.message == ""){
			obj.message = this.response.responseText;
		}
		var formNode = "";
		if(this.response.contextData.domNode.id){
			formNode = tmt.get(this.response.contextData.domNode.id);
		}
		else{
			formNode = this.response.contextData.domNode;
		}
		// Display message in a box
		tmt.form.displayMessage(formNode, obj.message);
	}
	// If we have a custom callback, use it instead
	obj.submitCallback = obj.defaultCallback;
	if(obj.form.getAttribute("tmt:ajaxoncomplete") || obj.form.getAttribute("tmt:ajaxformcallback")){
		var callBackName = obj.form.getAttribute("tmt:ajaxoncomplete") || obj.form.getAttribute("tmt:ajaxformcallback");
		obj.submitCallback = eval(callBackName);
	}

	//Default errback
	obj.errMessage = "";
	if(obj.form.getAttribute("tmt:ajaxerrmessage")){
		obj.errMessage = obj.form.getAttribute("tmt:ajaxerrmessage");
	}
	// Default errback
	obj.defaultErrback = function(){
		// Response text overwrite the message only if tmt:ajaxerrmessage is missing
		if(obj.errMessage == ""){
			obj.errMessage = this.response.responseText;
		}
		// Display errror message in a box
		tmt.form.displayErrorMessage(this.response.contextData.domNode, obj.errMessage);
	}
	// If we have a custom errback, use it instead
	obj.errback = obj.defaultErrback;
	if(obj.form.getAttribute("tmt:ajaxonerror") || obj.form.getAttribute("tmt:ajaxformerrback")){
		var errbackName = obj.form.getAttribute("tmt:ajaxonerror") || obj.form.getAttribute("tmt:ajaxformerrback");
		obj.errback = eval(errbackName);
	}

	// Function to be invoked before we send the form
	obj.sendBack = null;
	if(obj.form.getAttribute("tmt:ajaxonsubmit")){
		obj.sendBack = obj.form.getAttribute("tmt:ajaxonsubmit");
	}

	// Perform the HTTP call using XHR
	obj.send = function(callbackData){
		if(obj.sendBack){
			eval(obj.sendBack + "(formNode)");
		}
		// Serialize the form value/pairs
		var formValues = tmt.form.serializeForm(obj.form, true);
		var valueObj = {};
		if(obj.method == "GET"){
			valueObj.url = obj.action + "?" + formValues;
		}
		// It's POST
		else{
			valueObj.url = obj.action;
			valueObj.params = formValues;
		}
		// Assemble parameters into a value object
		valueObj.method = obj.method;
		valueObj.loadCallback = obj.submitCallback;
		valueObj.errback = obj.errback;
		// The XHR library (tmt.net), will pass it back to callbacks and errbacks
		if(callbackData){
			valueObj.contextData = callbackData;
		}
		else{
			valueObj.contextData = {};
		}
		// Add a reference to the <form> node
		valueObj.contextData.domNode = obj.form;
		// Add custom user-agent
		valueObj.headers = {"X-Requested-With": tmt.ajaxform.AJAX_USER_AGENT};
		// Perform the XHR call
		tmt.net.httpRequest(valueObj);
		// Prevent form submission
		return false;
	}

	return obj;
}

/**
* Submit a form programmatically using XHR
*/
tmt.ajaxform.submit = function(form, url, callbackData){
	var formNode = tmt.get(form);
	if(!formNode.tmtAjaxform){
		formNode.tmtAjaxform = tmt.ajaxform.factory(formNode);
	}
	if(url){
		formNode.tmtAjaxform.action = url;
	}
	formNode.tmtAjaxform.send(callbackData);
}

tmt.addEvent(window, "load", tmt.ajaxform.init);