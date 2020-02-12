// Class SearchCountInline

function SearchCountInline (element,query) {
  this.$element = $(element);
  this.query=query;
  this.state = "";
  this.count = "";
}

SearchCountInline.prototype= {
  constructor:SearchCountInline
  
  ,init() {
    this.state="waiting";
    this.render();
	this.getCount();
  }

  ,getCount () {
	var Searchlink = webApplicationBaseURL+'servlets/solr/select?q=' + encodeURI(this.query) +'&wt=json';
    $.ajax({
      method: "GET",
      url: Searchlink,
      dataType: "json"
    }) .done(function( json ) {
      this.count = $json("result[name='response']").attr("numFound");
      this.state="success";
      this.render();
    }).fail ( function( json ) {
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
        this.$element.text(this.count);
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
      mirElement = new SearchCountInline(
                          element,
                          query
                   );
      mirElement.init();
    }
  });
});