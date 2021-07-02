// Class SearchCountInline

function SearchCountInline (element,query,printAsLink) {
  this.$element = $(element);
  this.query=query;
  this.state = "";
  this.count = "";
  this.printAsLink = printAsLink;
  this.searchlink = webApplicationBaseURL+'servlets/solr/select?q=' + encodeURI(this.query);
}

SearchCountInline.prototype= {
  constructor:SearchCountInline
  
  ,init() {
    this.state="waiting";
    this.render();
    this.getCount();
  }

  ,getCount () {
    var Searchlink = this.searchlink + '&wt=json&rows=0' ;
    $.ajax({
      method: "GET",
      url: Searchlink,
      dataType: "json",
      context: this
    }) .done(function( json ) {
      this.count = json.response.numFound;
      this.state="success";
      this.render();
    }).fail ( function () {
      this.state="error";
      this.render();	
    });
  }
  
  ,render() {
	switch(this.state) {
      case "error":
        this.$element.html("<i class='fa fa-exclamation-triangle' data-toggle='tooltip' title='"+this.errortext+"'></i>");
        break;
      case "waiting":
        this.$element.html("<i class='fa fa-spinner fa-pulse'></i>");
        break;
      case "success":
    	if ( this.printAsLink ) {
          this.$element.html('<a href="' + this.searchlink + '">' + this.count + '</a>');
    	} else {
          this.$element.text(this.count);
    	}
        break;
      default:
        this.$element.text("");
    }
  }
}

// End Class SearchCountInline

$(document).ready( function() {
  $('[data-mirelementtype]').each(function(index, element) {
    var mirElementtype=$(element).data('mirelementtype');
    if (mirElementtype == "SearchCountInline" ) {
      query = $(element).data('query');
      if ($(element).data('querycall')) {
        f = new Function ($(element).data('querycall'));
    	query = f();
      }
      printAsLink = ( $(element).data('printaslink') == true) ? true : false;
      mirElement = new SearchCountInline(
                          element,
                          query,
                          printAsLink
                   );
      mirElement.init();
    }
  });
});