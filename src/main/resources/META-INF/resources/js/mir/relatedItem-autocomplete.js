
var BloodhoundConf = {
    shelfmark : {
        transform : function(list) {
		    list = list.response.docs;
            $.each(list, function(index, item) {
                item.name = item['shelfLocator'] + ' - ' + item['mods.title'][0];
                item.value = item['shelfLocator'];
            });
            return list;
        },
        prepare : function(query, settings) {
            var param = "+%2BshelfLocator%3A" + query + "*";
			param += "+%2BobjectType%3A%22mods%22";
			param += "&fl=mods.title%2Cid%2Cidentifier.type.isbn%2CshelfLocator";
			param += "&version=4.5&rows=20&wt=json";

			settings.url = settings.url.replace("%QUERY", param);
			return settings;
		}
    },
    isbn : {
        transform : function(list) {
            list = list.response.docs;
            $.each(list, function(index, item) {
                 item.name = item['identifier.type.isbn'] + ' - ' + item['mods.title'][0];
                 item.value = item['identifier.type.isbn'];
            });
            return list;
        },
        prepare : function(query, settings) {
            var param = "%2Bidentifier.type.isbn%3A"+query+"*";
			param += "+%2BobjectType%3A%22mods%22";
			param += "&fl=mods.title%2Cid%2Cidentifier.type.isbn%2CshelfLocator";
			param += "&version=4.5&rows=20&wt=json";

			settings.url = settings.url.replace("%QUERY", param);
			return settings;
		}
    },
    issn : {
        transform : function(list) {
			list = list.response.docs;
			$.each(list, function(index, item) {
				item.name = item['mods.identifier.issn'] + ' - ' + item['mods.title'][0];
				item.value = item['mods.identifier.issn'];
			});
			return list;
		},
		prepare : function(query, settings) {
		    var param = "+%2Bmods.identifier.issn%3A"+query+"*";
			param += "+%2BobjectType%3A%22mods%22";
			param += "&fl=mods.title%2Cid%2Cidentifier.type.issn";
			param += "&version=4.5&rows=20&wt=json";

			settings.url = settings.url.replace("%QUERY", param);
			return settings;
		}
    },
    title : {
        transform : function(list) {
			list = list.response.docs;
			$.each(list, function(index, item) {
				item.name = item['mods.title'][0];
				item.value = item['mods.title'][0];
			});
			return list;
		},
		prepare : function(query, settings) {
		    var param = "+%2Bmods.title.autocomplete%3A*" + query.replace(/ /g,"\\ ") + "*+";
			param += "%2BobjectType%3A%22mods%22";
			param += "&fl=mods.title%2Cid%2Cmods.identifier.issn%2Cidentifier.type.isbn%2CshelfLocator";
			param += "&version=4.5&rows=20&wt=json";

			settings.url = settings.url.replace("%QUERY", param);
			return settings;
		}
    },
    title_ptitle : {
        transform : function(list) {
			list = list.response.docs;
			$.each(list, function(index, item) {
				var host = '';
				if (item['mods.title.host']) {
					host='(' + item['mods.title.host'][0] + ')'
				} else if (item['mods.title.series']) {
					host='(' + item['mods.title.series'][0] + ')'
				};
				item.name = item['mods.title'][0] + host;
				item.value = item['mods.title'][0];
			});
			return list;
		},
		prepare : function(query, settings) {
		    var param = "+%2Bmods.title.autocomplete%3A*" + query.replace(/ /g,"\\ ") + "*+";
			param += "%2BobjectType%3A%22mods%22";
			param += "&fl=mods.title%2Cid%2Cmods.title.host%2Cmods.title.series";
			param += "&version=4.5&rows=20&wt=json";
			 
			settings.url = settings.url.replace("%QUERY", param);
			return settings;
		}
    },
    empty : {
        transform : function(list) {
			return {};
		}
    }
};

$(document).ready(function() {

	$("input[data-provide='typeahead'].relItemsearch").each(function(index, input) {
		var engine;
		var config;
		var genre = $(input).data("genre");
		
		if (BloodhoundConf[$(this).data("searchengine")]) {
			config = BloodhoundConf[$(this).data("searchengine")];
		} else {
			config = BloodhoundConf["empty"];
		}
		//Engine.engine.initialize();
		engine=new Bloodhound({
            datumTokenizer : Bloodhound.tokenizers.obj.whitespace('mods.title[0]'),
            queryTokenizer : Bloodhound.tokenizers.whitespace,
            remote : {
                url : webApplicationBaseURL + 'servlets/solr/select?q=%2Bcategory.top%3A%22mir_genres\%3A' + genre + '%22%QUERY',
                wildcard : '%QUERY',
                transform : config.transform ,
                prepare   : config.prepare 
            }
        });
        $(input).typeahead({
			items : 4,
			source : function(query, callback) {
				// rewrite source function to work with newer typeahead version
				// @see (withAsync(query, sync, async))
				var func = engine.ttAdapter();
				return $.isFunction(func) ? func(query, callback, callback) : func;
			},
			updater : function(current) {
				current.name = current.value;
				return (current);
			},
			afterSelect : function(current) {
				fieldset = $(document.activeElement).closest("fieldset.mir-relatedItem");
				relatedItemBody = fieldset.children('div.mir-relatedItem-body');
				relatedItemBody.find("input[id^='relItem']").val(current.id);
				disableFieldset(fieldset);
				getMods(fieldset, current.id);
				createbadge($(document.activeElement).closest("div"), current.id);

			}
		});
        
        engine.search($(input).val(),function (datums) {} ,function (datums) {
            if (datums.length == 1) {
                fieldset = $(input).closest("fieldset.mir-relatedItem");
				relatedItemBody = fieldset.children('div.mir-relatedItem-body');
				relatedItemBody.find("input[id^='relItem']").val(datums[0].id);
				disableFieldset(fieldset);
				getMods(fieldset, datums[0].id);
				createbadge($(input).closest("div"), datums[0].id);
            } 
        } );
        
	});

	$("input[id^='relItem']").each(function(index, input) {
		if (input.value.indexOf("mods_00000000") < 0) {
			fieldset = $(input).closest("fieldset.mir-relatedItem");
			disableFieldset(fieldset);
			getModsAfterTrans(fieldset, input.value);
			createbadge($(fieldset.find("div.input-group")[0]), input.value);
		}
	});
	
});



function disableFieldset(fieldset) {
	relatedItemBody = fieldset.children('div.mir-relatedItem-body');
	relatedItemBody.find("div.form-group:not(.mir-modspart)").find("input[type!='hidden'], select").each(function(index, input) {
		if (input != document.activeElement) {
			$(input).prop('disabled', true);
			$(input).data('value', $(input).val());
		}
	});
	$(".searchbadge").addClass("disabled");

	fieldset.find("fieldset.mir-relatedItem").prop('disabled', true);
}

function getModsAfterTrans(fieldset, relItemid) {
	$.ajax({
		method : "GET",
		url : webApplicationBaseURL + "receive/" + relItemid + "?XSL.Transformer=mods2xeditor",
		dataType : "xml"
	}).done(function(xml) {
		fillFieldset(fieldset, xml)
	}).fail(function() {
		console.log("Mycore Propertie 'MCR.ContentTransformer.mods2xeditor.Stylesheet' not set");
		getMods(fieldset, relItemid)
	});
}

function getMods(fieldset, relItemid) {
	$.ajax({
		method : "GET",
		url : webApplicationBaseURL + "receive/" + relItemid + "?XSL.Style=xml",
		dataType : "xml"
	}).done(function(xml) {
		fillFieldset(fieldset, xml)
	});
}

function fillFieldset(fieldset, xml) {
	fieldset.find('input, select').each(function(index, input) {
		path = $(input).data('valuexpath');
		//path = "/mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods/" + path;
		function nsResolver(prefix) {
			var ns = {
				'mods' : 'http://www.loc.gov/mods/v3',
				'xlink' : 'http://www.w3.org/1999/xlink'
			};
			return ns[prefix] || null;
		}
		xPathRes = xml.evaluate(path, xml, nsResolver, XPathResult.ANY_TYPE, null);
		node = xPathRes.iterateNext();
		if (node) {
			if ($(node).text() != "" && $(node).text() != undefined) {
				input.value = $(node).text();
			}
			else {
				input.value = node.value;
			}
		}
	});
}

function createbadge(inputgroup, relItemid) {
	badge = '<a href="../receive/' + relItemid + '" target="_blank" class="badge badge-primary"> ';
	badge += 'intern ';
	badge += '<span class="far fa-times-circle relItem-reset"> </span>';
	badge += '</a>';

	inputgroup.find(".searchbadge").html(badge);

	inputgroup.find(".relItem-reset").click(function(event) {
		event.preventDefault();
		relatedItemBody = $(this).closest("fieldset.mir-relatedItem").children('div.mir-relatedItem-body');
		relatedItemBody.find("div.form-group:not(.mir-modspart)").find("input[type!='hidden']").each(function(index, input) {
			$(input).prop('disabled', false);
			$(input).val($(input).data('value'));
		});
		$('.searchbadge').removeClass("disabled");
		relatedItemBody.find("input[id^='relItem']").val("mir_mods_00000000");
		$(document.activeElement).closest("fieldset.mir-relatedItem").find("fieldset.mir-relatedItem").prop('disabled', false);
		inputgroup = $(this).closest("div");
		inputgroup.find(".searchbadge").html("");
	});
}
