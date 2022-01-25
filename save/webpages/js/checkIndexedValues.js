
var indexedObjects = null;
var max_count_check = 10;

window.setInterval(function(){
	if (indexedObjects != null) {
		var count_done = 0;
		var count_check = 0;
		$.each(indexedObjects, function( index, indexedObject ) {
			if (indexedObject.state) {
				if (indexedObject.state == "done") {
					count_done++;
				}
			} else {
				if (count_check <= max_count_check) {
					indexedObject.state = "waiting";
					checkObject (indexedObject);
					count_check++;
				}
			}
		});
		$('#step_checkObjects').html(count_done + '/'+ indexedObjects.length);
		if (count_done == indexedObjects.length) {
			$('#step_checkObjects').html('fertig');
		}
	}
}, 500);

function checkObject (indexedObject) {
	var solrdocumentURL = webApplicationBaseURL + "receive/" + indexedObject.id + "?XSL.Style=solrdocument";
	var object = indexedObject;
	
	$.ajax({
  		method: "GET",
		url: solrdocumentURL,
		dataType: "xml"
	}) .done(function( solrdocument ) {
		object.state = "done";
		genre = object["mods.genre"][0];
		yIssuedStat = object["mods.yearIssued.statistic"];
		genre2 =  $(solrdocument).find('field[name="mods.genre"]:first').text(); 
		yIssuedStat2 = $(solrdocument).find('field[name="mods.yearIssued.statistic"]').text();
		errorText="";
		if (yIssuedStat && yIssuedStat != yIssuedStat2) {
			errorText +=" yearIssued.statistic ungleich (" + yIssuedStat + "," + yIssuedStat2 + ")";
		}
		if (genre != genre2) {
			errorText +=" genre ungleich (" + genre + "," + genre2 + ")";
		}
		if (errorText != "") {
			link= webApplicationBaseURL + "/receive/"+ object.id ;
			$('#falseCheckedTitles_ul').append('<li><a href="' + link + '">' + object.id + ' - ' + errorText + ' </a> </li>');
			$('#repairList').append('repair metadata search of ID ' + object.id + '<br/>');
		}
	}) .fail(function( jqXHR, ajaxOptions, thrownError ) {
		if(jqXHR.status==404) {
		    var html='<div style="text-align:center;color:red;" >Cant get solrdocument for ' + object.id + ' <br/>'+jqXHR.responseText+'</div>';
    		$('#errorDiv').append(html);
    	} else {
    		$('#errorDiv').append("Unknown Error during get ObjectIds for " + object.id + " from restapi");
    	}
  	});
}


function checkValuesOfIndexedObjects() {
	$('#step_getIndex').html('<i class="fa fa-spinner" aria-hidden="true"></i>');
	var solrURL = webApplicationBaseURL + "/servlets/solr/select?q=%2BobjectType%3A%22mods%22&fl=id,mods.yearIssued.statistic,mods.genre&rows=200000&wt=json&sort=id asc";
    $.ajax({
  		method: "GET",
		url: solrURL,
		dataType: "json"
	}) .done(function( json ) {
		$('#step_getIndex').html('fertig');
		indexedObjects = json['response']['docs'];
		// Intervall to work on indexedObjects is set above
	}) .fail(function( jqXHR, ajaxOptions, thrownError ) {
		$('step_getIndex').html('Error');
		if(jqXHR.status==404) {
		    var html='<div style="text-align:center;color:red;" > Error during get ObjectIds from Solr'+jqXHR.responseText+'</div>';
    		$('#errorDiv').append(html);
    	} else {
    		$('#errorDiv').append("Unknown Error during get ObjectIds from solr");
    	}
  	});
};

$(document).ready( function() {
	checkValuesOfIndexedObjects();
});