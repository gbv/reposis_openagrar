
$(document).ready(function() {

  // replace placeholder USERNAME with username
  var userID = $("#currentUser strong").html();
  var newHrefShort = 'https://www.openagrar.de/servlets/solr/select?q=createdby:' + userID + '&fq=objectType:mods';
  $("a[href='https://www.openagrar.de/servlets/solr/select?q=createdby:USERNAME']").attr('href', newHrefShort);
  var newHref = 'https://openagrar.bmel-forschung.de/servlets/solr/select?q=createdby:' + userID + '&fq=objectType:mods';
  $("a[href='https://openagrar.bmel-forschung.de/servlets/solr/select?q=createdby:USERNAME']").attr('href', newHref);


// spam protection for mails
  $('span.madress').each(function(i) {
      var text = $(this).text();
      var address = text.replace(" [at] ", "@");
      $(this).after('<a href="mailto:'+address+'">'+ address +'</a>')
      $(this).remove();
  });

});