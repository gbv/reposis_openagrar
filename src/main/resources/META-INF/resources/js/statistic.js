// Class Statisticselement

function Statisticselement (parent,stBrowser, category, facet, level) {
  this.element="";
  this.parent=parent;
  this.stBrowser = stBrowser;
  //this.ulNode=ulNode;
  this.trNode=null;
  this.category = category;
  this.level = level;
  this.facets = "";
  this.facet = facet;
} 

Statisticselement.prototype= {
  constructor:Statisticselement
   
  ,init() {
    Category=$(this.getCategory());
    var selectedFacets=$(this.getFacets());
    var stElement = this;
    var hideEmptyElements = this.stBrowser.hideEmptyElements;
    
    var catTitle = Category.children('label[xml\\:lang="de"]').attr('text');
    var catId = Category.attr('ID');
    
    var stBrowser=this.stBrowser;
    
    var facetTitle = stBrowser.i18nFacet(stElement.stBrowser.facets[selectedFacets.length-1],$(this.facet).attr('name'));
            
    var Query= "";
    if (stBrowser.classification) {
      Query += 'category.top:"' + stBrowser.classification + ':' + catId + '"';
    }
    selectedFacets.each(function(i){
      if (Query != "") Query += ' AND ';
      Query += stElement.stBrowser.facets[i] + ':' + $(this).attr('name');
    });
    if (stBrowser.horizontalFacet && stBrowser.horizontalFacet.valuePrefix) {
      if (Query != "") Query += ' AND ';
      Query += stBrowser.horizontalFacet.name + ':' + stBrowser.horizontalFacet.valuePrefix + '*';
    }
    
    var FQuery = "";
    $(stBrowser.fq).each( function () {
      FQuery += "&fq=" + this;
    });
    
    var Searchlink = webApplicationBaseURL+'servlets/solr/select?q=' + encodeURI(Query) + encodeURI(FQuery) +'&wt=xml';
    	
	//var ListElement=$("<li/>");
	var tr=$("<tr/>");
	var padding = 10 + 10 * this.level; 
	padding = "padding-left:" +  padding + "px";
	var td=$("<td/>",{style:padding});
	
	var SquareIcon = "";
	if (stBrowser.expandAllElements) {
	  SquareIcon = '<i class="fa fa-square-o"></i>';
	}else if (Category.children("category").length > 0 || selectedFacets.length < stBrowser.facets.length) {
	  SquareIcon = '<i class="fa fa-plus-square-o"></i>';
	}else{
	  SquareIcon = '<i class="fa fa-square-o"></i>';
	}
	
	var Square = $("<a/>",{class:"sbSquare"}).append(SquareIcon);
	var cbNum = $("<span/>",{class:"cbNum"}).text('[...]');
	var tdNum = $("<td/>",{class:"cbNum"}).text('[...]');
	var LinkTitel = (this.facet==null) ? catTitle : facetTitle;
	var Search = $("<a/>", {href: Searchlink}).text(LinkTitel);
	
	td.append(Square);
	td.data("stElem",this);
	
	td.append(Search);
	if (!stBrowser.horizontalFacet) td.append(cbNum);
	this.element=td;
	tr.append(td);
	if (stBrowser.horizontalFacet) tr.append(tdNum); 
	
	if (stBrowser.horizontalFacet) {
	  $.ajax({
        method: "GET",
        url: Searchlink + "&XSL.Style=xml&rows=0&facet.field=" + stBrowser.horizontalFacet.name + "&facet.sort=index",
        dataType: "xml"
      }) .done(function( xml ) {
        var Facets=$(xml).find('lst[name="facet_counts"]').find('lst[name="facet_fields"]').find('lst[name="' + stBrowser.horizontalFacet.name + '"]');
        if (stBrowser.horizontalFacet.valuePrefix){
          Facets = Facets.children('int[name^="' + stBrowser.horizontalFacet.valuePrefix + '"]');
        } else {
          Facets = Facets.children('int');
        }
        var count = 0;
        $(Facets).each(function(i){
          while (stBrowser.horizontalFacetElements.eq(count).attr("name") != $(this).attr("name") && count < 20) {
            tr.append($("<td/>").text("0"));
            count++;
          }
          var Query2 = Query;
          if (Query2 != "") Query2 += ' AND ';
          Query2 += stElement.stBrowser.horizontalFacet.name + ':"' + $(this).attr('name') + '"';
          var hFacetSearchlink = webApplicationBaseURL+'servlets/solr/select?q=' + encodeURI(Query2) + encodeURI(FQuery) +'&wt=xml';
          var link = $("<a/>",{href: hFacetSearchlink}).text($(this).text());
          var td2 = $("<td/>");
          td2.append(link);
          tr.append(td2);
          count++;
        });
        while (count < stBrowser.horizontalFacetElements.length) {
          tr.append($("<td/>").text("0"));
          count++;
        }
      });
    } 
	
    
    //$(this.ulNode).append(ListElement);
    //ListElement.data("stElem",this);
	this.trNode=tr;
    
    if (this.parent==null) {
      stBrowser.tBodyNode.append(tr);
    } else {
      this.parent.trNode.after(tr);
    }
    
    var facetFields="";
    $(stElement.stBrowser.facets).each(function(){
      if (facetFields != "") facetFields += ',';
      facetFields += "&facet.field=" + this;
    });

    // Get the Facets and Count of the subset
	$.ajax({
      method: "GET",
      url: Searchlink + "&XSL.Style=xml&rows=0" + facetFields + "&facet.sort=index&facet.limit=1000",
      dataType: "xml"
    }) .done(function( xml ) {
      var count = $(xml).find("result[name='response']").attr("numFound");
      cbNum.text("[" + count + "]" );
      tdNum.text(count);
      if (hideEmptyElements == true && count == 0) tr.addClass("hide");
      countSF = selectedFacets.length;
      stElement.facets=$(xml).find('lst[name="facet_counts"]').find('lst[name="facet_fields"]').find('lst[name="' + stElement.stBrowser.facets[countSF] + '"]');
      if (stElement.stBrowser.expandAllElements === true ) {
        stElement.openSubselect();
      }
    });
    
    Square.click(function() {
      var icon = $(this).find("i");
      if (icon.hasClass("fa-plus-square-o")) {
        $(this).parent().data("stElem").openSubselect();
      } else if (icon.hasClass("fa-minus-square-o")) {
        $(this).parent().data("stElem").closeSubselect();
      }
    });
    
  }
  
  ,openSubselect: function () {
    var stElement = this;
    if (stElement.stBrowser.expandAllElements !== true) {
      this.element.find("i").removeClass("fa-plus-square-o");
      this.element.find("i").addClass("fa-minus-square-o");
    }
        
    if (stElement.stBrowser.classification) {
      //TO DO 
      if (stElement.level < stElement.stBrowser.maxClassificationDeep - 1 || stElement.stBrowser.maxClassificationDeep < 0) {
        category=$(this.getCategory());
        category.children('category').each(function(){
          var stElem=new Statisticselement(stElement,stElement.stBrowser,this,null,stElement.level + 1);
          stElem.init();
        });
      }
    }
    
    selectedFacets=$(this.getFacets());
    if (selectedFacets.length < stElement.stBrowser.facets.length) { 
      this.facets.children().each(function(){
        var stElem=new Statisticselement(stElement,stElement.stBrowser,null,this,stElement.level + 1);
        stElem.init();
      });
    }
    
  }
  
  ,closeSubselect: function () {
    this.element.find("i").removeClass("fa-minus-square-o");
    this.element.find("i").addClass("fa-plus-square-o");
    var stElement=this;
    this.element.parent().siblings('tr').each( function () {
      if ($(this).children('td').first().data("stElem").parent == stElement) {
        this.remove();    	
      }
    });
    
    //this.element.children("div").remove();
  }
  
  ,getCategory: function () {
    var stElement=this;
    while (stElement.category == null && stElement.parent != null) {
      stElement=stElement.parent;
    }
    return stElement.category;
  }
  
  ,getFacets: function () {
    var Facets = [];
    var stElement=this;
    if (stElement.facet != null) Facets.push(stElement.facet);
    while (stElement.parent != null) {
      stElement=stElement.parent;
      if (stElement.facet != null) Facets.push(stElement.facet);
    }
    return Facets.reverse();
  }
  
  ,isLeaf() {
    Category=$(this.getCategory());
    var selectedFacets=$(this.getFacets());
    if (Category != null) {
      return (Category.children("category").length == 0 
             && selectedFacets.length == this.stBrowser.facets.length);
    } else {
      return (selectedFacets.length == this.stBrowser.facets.length);
    }
    
  }
  
}

// EndClass Statisticselement

//Class Statisticsbrowser

function Statisticsbrowser (element,classification,rootCategory,facets,horizontalFacet,expandAllElements,hideEmptyElements,lang,fq,maxClassificationDeep) {
  
  this.$element = $(element);
  this.classificationXML = null;
  this.fq = (jQuery.type( fq ) === "array") ? fq : ["objectType:mods"];
  this.classification=classification;
  this.rootCategory=rootCategory;
  this.lang = (jQuery.type( lang ) === "string" && lang.length > 0) ? lang : "en";
  this.tBodyNode=null;
  
  if (Array.isArray(facets)) {
    this.facets=facets;
  } else if (facets == null || facets == "") {
    this.facets=[];
  } else {
    this.facets=[];
    console.log("[Statisticsbrowser] Error: Parameter Facets has to be an array.");
  }
  
  if (jQuery.isPlainObject(horizontalFacet) && horizontalFacet.name) {
    this.horizontalFacet = horizontalFacet;
    if (! horizontalFacet.valuePrefix) this.horizontalFacet.valuePrefix = null;
  } else if (jQuery.type( horizontalFacet ) === "string" && horizontalFacet.length > 0) {
    this.horizontalFacet = new Object ();
    this.horizontalFacet.name = horizontalFacet;
    this.horizontalFacet.valuePrefix = null;
  } else {
    this.horizontalFacet = null;
  }
  this.facetElements="";
  this.horizontalFacetElements="";
  this.hideEmptyElements = hideEmptyElements;
  this.expandAllElements = expandAllElements;
  this.maxClassificationDeep = (maxClassificationDeep == null ) ? -1 : maxClassificationDeep;
  this.facet2classifcation= {
  	"mods.genre": {
  	  className :"mir_genres",
  	  classXML  : null
  	},
  	"annual_review": {
  	  className :"annual_review",
  	  classXML  : null
  	}
  };
  
  this.facet2i18n = {
    "mods.refereed": {
      de: {
        yes : "referiert",
        no  : "nicht referiert",
        "n/a" : "nicht referierbar"
      },
      en: {
        yes : "refereed",
        no  : "not refereed",
        "n/a" : "not referabel"
      }
    }
  }
};



Statisticsbrowser.prototype= {
  constructor: Statisticsbrowser
  
  ,init: function () {
    var elem = this;
    
    var deferreds = [];
    
    if (this.classification) {
      deferreds.push (elem.getClassification());
    } else if (this.facets.length > 0) {
      deferreds.push (elem.getFacets());
    } else {
      console.log("[Statisticsbrowser] Error: Need a classification or facets to initialize.");
      return;
    }
    
    if (elem.horizontalFacet) {
      deferreds.push (elem.getHorizontalFacets());
      if (elem.horizontalFacet.valuePrefix) {
        if (elem.facet2classifcation[elem.horizontalFacet.valuePrefix]) {
          var classElem = elem.facet2classifcation[elem.horizontalFacet.valuePrefix];
          deferreds.push ( elem.getI18nClassification(elem.horizontalFacet.valuePrefix,classElem["className"]) );
        }
      }
    }
    
    // Get the XML for the needed Classifications to translate the FacetValues.
    $(this.facets).each( function() {
      if (elem.facet2classifcation[this]) {
        var classElem = elem.facet2classifcation[this];
        deferreds.push ( elem.getI18nClassification(this,classElem["className"]) );
      }
    });
    
    $.when.apply($, deferreds).done(function(){
      elem.renderRoot();
    });
  }
  
  ,getI18nClassification: function (facetName,className) {
    elem=this;
    return (
      $.ajax({
        method: "GET",
        url: webApplicationBaseURL+"api/v1/classifications/" + className,
        dataType: "xml"
      }) .done(function( xml ) {
        elem.facet2classifcation[facetName]["classXML"]=xml;
      }).fail(function(e) {
        console.log("Fehler beim Holen der Daten der Klassifikation (i18n)");
      })
    )
  }
  
  ,getClassification: function () {
    elem=this;
    return $.ajax({
        method: "GET",
        url: webApplicationBaseURL+"api/v1/classifications/" + elem.classification,
        dataType: "xml"
      }) .done(function( xml ) {
        elem.classificationXML=xml;
      }).fail(function(e) {
        console.log("Fehler beim Holen der Daten der Klassifikation");
    });
  }
  
  ,getFacets: function() {
    elem=this;
    var FQuery = "";
    $(elem.fq).each( function () {
      FQuery += "&fq=" + this;
    });
    var Searchlink = webApplicationBaseURL+'servlets/solr/select?q=*:*' + encodeURI(FQuery) +'&wt=xml';
    return $.ajax({
        method: "GET",
        url: Searchlink + "&XSL.Style=xml&rows=0&facet.field=" + elem.facets[0] + "&facet.sort=index&facet.limit=3000",
        dataType: "xml"
      }) .done(function( xml ) {
        elem.facetElements=$(xml).find('lst[name="facet_counts"]').find('lst[name="facet_fields"]').find('lst[name="' + elem.facets[0] + '"]');
        if (elem.facetElements.children().length == 0) {
          elem.facetElements = null;
          console.log("Error: Keine Faceten im Feld " + elem.facets[0] + "gefunden.");
        }
      }).fail(function(e) {
        console.log("Error:Fehler beim Holen der Daten der ersten Facete.");
    });
  }
  
  ,getHorizontalFacets: function () {
    elem=this;
    var FQuery = "";
    $(elem.fq).each( function () {
      FQuery += "&fq=" + this;
    });
    var Searchlink = webApplicationBaseURL+'servlets/solr/select?q=*:*' + encodeURI(FQuery) +'&wt=xml';
    return $.ajax({
        method: "GET",
        url: Searchlink + "&XSL.Style=xml&rows=0&facet.field=" + elem.horizontalFacet.name + "&facet.sort=index",
        dataType: "xml"
      }) .done(function( xml ) {
        elem.horizontalFacetElements=$(xml).find('lst[name="facet_counts"]').find('lst[name="facet_fields"]').find('lst[name="' + elem.horizontalFacet.name + '"]');
        if (elem.horizontalFacet.valuePrefix){
          elem.horizontalFacetElements = elem.horizontalFacetElements.children('int[name^="' + elem.horizontalFacet.valuePrefix + '"]');
        } else {
          elem.horizontalFacetElements = elem.horizontalFacetElements.children('int');
        }
    });
  }
  
  ,renderRoot: function () {
    var stBrowser=this;
    var elem = this;
    var mainDiv= $("<div/>", { class:"statisticBrowser"});
    this.$element.append(mainDiv);
    //var mainUl = $("<ul/>", { class:"cbList"});
    var table = $("<table/>", { class:"table table-hover"});
    mainDiv.append(table);
    
    if (elem.horizontalFacetElements && elem.horizontalFacetElements.length > 0) {
      var tHead = $("<thead/>");
      var tr = $("<tr/>");
      tHead.append(tr);
      var td = $("<td/>");
      tr.append(td);
      var td = $("<td/>").text("gesamt");
      tr.append(td);
      elem.horizontalFacetElements.each(function(){
        var Facetname = elem.i18nFacet(elem.horizontalFacet.name,$(this).attr("name"));
        td = $("<td/>").text(Facetname);
        tr.append(td);
       });
      table.append(tHead);
    }
      
    elem.tBodyNode=$("<tBody/>");
    table.append(elem.tBodyNode);
      
    if (this.classificationXML) {
      var categories = null;
      if (this.rootCategory) {
        categories = $(this.classificationXML).find('category[ID="' + this.rootCategory + '"]').children('category');
      } else {
        categories = $(this.classificationXML).find('categories > category');
      }
      categories.each(function(){
        var stElem=new Statisticselement(null,stBrowser,this,null,0);
        stElem.init();
	  });
	} else {
	  elem.facetElements.children().each(function(){
        var stElem=new Statisticselement(null,stBrowser,null,this,0);
        stElem.init();
      });
	}
  }
  
  ,i18nFacet: function (facet,facetValue) {
    if (! facet || ! facetValue) return null;
    var stBrowser=this;
    var Lang = this.lang;
    var pos = facetValue.indexOf(":");
    if (pos > 0 && stBrowser.facet2classifcation[facetValue.substring(0, pos)] ) {
      var facet2=facetValue.substring(0, pos);
      var facetValue2=facetValue.substring(pos+1);
      var Classification = stBrowser.facet2classifcation[facet2]["classXML"];
      return $(Classification).find('[ID="' + facetValue2 + '"]').children('label[xml\\:lang="' + Lang + '"]').attr('text')
    } else if (stBrowser.facet2classifcation[facet]) {
      var Classification = stBrowser.facet2classifcation[facet]["classXML"];
      return $(Classification).find('[ID="' + facetValue + '"]').children('label[xml\\:lang="' + Lang + '"]').attr('text')
    } else if (stBrowser.facet2i18n[facet]) {
      return stBrowser.facet2i18n[facet][Lang][facetValue];
    } else {
      return facetValue;
    }
  } 
  
};

// End Class Statisticsbrowser

  
$(document).ready( function() {
  $('[data-mirelementtype]').each(function(index, element) {
    var mirElementtype=$(element).data('mirelementtype');
    if (mirElementtype == "Statisticsbrowser" ) {
      classification = $(element).data('classification');
      rootCategory = $(element).data('rootcategory');
      facets = $(element).data('facets');
      horizontalFacet = $(element).data('horizontalfacet');
      hideEmptyElements = ( $(element).data('hideemptyelements') == true) ? true : false;
      expandAllElements = ( $(element).data('expandallelements') == true) ? true : false;
      lang = ( $(element).data('lang') != "") ? $(element).data('lang') : null; 
      fq = $(element).data('fq');
      maxClassificationDeep = $(element).data('maxclassificationdeep');
      mirElement = new Statisticsbrowser(
                          element,
                          classification,
                          rootCategory,
                          facets,
                          horizontalFacet,
                          expandAllElements,
                          hideEmptyElements,
                          lang,
                          fq,
                          maxClassificationDeep);
      mirElement.init();
    }
  });

});
