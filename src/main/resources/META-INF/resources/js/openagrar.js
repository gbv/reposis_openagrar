
$(document).ready(function() {

  // replace placeholder USERNAME with username
  var userID = $("#currentUser strong").html();
  var newHrefShort = webApplicationBaseURL + 'servlets/solr/select?q=createdby:' + userID + '&fq=objectType:mods';
  var oldHrefShort = webApplicationBaseURL + 'servlets/solr/select?q=createdby:USERNAME';
  $("a[href='" + oldHrefShort + "']").attr('href', newHrefShort);
  
// spam protection for mails
  $('span.madress').each(function(i) {
      var text = $(this).text();
      var address = text.replace(" [at] ", "@");
      $(this).after('<a href="mailto:'+address+'">'+ address +'</a>')
      $(this).remove();
  });

});