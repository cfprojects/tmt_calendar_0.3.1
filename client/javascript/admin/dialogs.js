// Custom rule for TMT Validator
tmt.validator.rules.greater = function(fieldNode){
	var ltValue = tmt.get(fieldNode.getAttribute("tmt:greater")).value;
	return (fieldNode.value >= ltValue);
}