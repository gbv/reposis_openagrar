function compareIndexedWithAllObjects(indexedObjects) {
	var restapiURL = webApplicationBaseURL + "/api/v1/objects?format=json";
    $.ajax({
  		method: "GET",
		url: restapiURL,
		dataType: "json"
	}) .done(function( json ) {
		var allObjects = json['mycoreobjects'];
		var html = "<ul>";
		var i = 0;
		var j = 0;
		var ID = "";
		while (i < allObjects.length) {
			while (allObjects[i].ID != indexedObjects[j].id) {
				link= webApplicationBaseURL + "/receive/"+ allObjects[i].ID ;
		    	html += '<li> <a href="' + link + '">' + allObjects[i].ID + '</a> </li>'
				i++;
			}
			i++;
			j++;
		} 
		html += '</ul>';
	    $('#nonindexedTitles').html(html);
	}) .fail(function( jqXHR, ajaxOptions, thrownError ) {
		if(jqXHR.status==404) {
		    var html='<div style="text-align:center;color:red;" >'+jqXHR.responseText+'</div>';
    		$('#nonindexedTitles').html(html);
    	} else {
    		$('#nonindexedTitles').html("Unknown Error during get ObjectIds from restapi");
    	}
  	});
}


function checkNoIndexedObjects() {
	var solrURL = webApplicationBaseURL + "/servlets/solr/select?q=%2BobjectType%3A%22mods%22&fl=id&rows=100000000&wt=json&sort=id asc";
    $.ajax({
  		method: "GET",
		url: solrURL,
		dataType: "json"
	}) .done(function( json ) {
		var indexedObjects = json['response']['docs'];
		compareIndexedWithAllObjects(indexedObjects);
	}) .fail(function( jqXHR, ajaxOptions, thrownError ) {
		if(jqXHR.status==404) {
		    var html='<div style="text-align:center;color:red;" >'+jqXHR.responseText+'</div>';
    		$('#nonindexedTitles').html(html);
    	} else {
    		$('#nonindexedTitles').html("Unknown Error during get ObjectIds from solr");
    	}
  	});
};

$(document).ready( function() {
	checkNoIndexedObjects();
});