// TI-Jahresbericht-Statistik: baut die Tabelle (Zeilen = Institute, Spalten = Jahresberichtskategorien)
// und erzeugt je Zelle ein SearchCountInline-Element (searchcount.js).
// Die Institutsliste wird zur Laufzeit aus der Klassifikation mir_institutes (Teilbaum ti) geladen,
// damit die Tabelle immer der aktuellen Institutsstruktur folgt.
// Aufbau und Spaltenreihenfolge entsprechen der TI-Vorgabe (Beispieltabelle, Reiter "Kontrolle").

var searchParams = new URLSearchParams(window.location.search);
var year = searchParams.has("year") ? searchParams.get("year") : new Date().getFullYear();

// Jahresberichtskategorien (Spalten) in der vom TI vorgegebenen Reihenfolge.
// Oberkategorien (Z, S, M, K) zaehlen ihre Unterkategorien mit ("ids").
var annual_review_categories = [
  { id: "Z",   ids: ["Z", "Z1", "Z2"],                                label: "Zeitschriftenbeiträge" },
  { id: "Z1",                                                         label: "Beiträge in referierten Zeitschriften" },
  { id: "Z2",                                                         label: "Beiträge in nicht referierten Zeitschriften" },
  { id: "S",   ids: ["S", "S1", "S2"],                                label: "Beiträge in Büchern, Sammelwerken, Tagungsbänden" },
  { id: "S1",                                                         label: "Beiträge in Büchern, Sammelwerken, Tagungsbänden im Fremdverlag" },
  { id: "S2",                                                         label: "Beiträge in Büchern, Sammelwerken, Tagungsbänden im Eigenverlag" },
  { id: "M",   ids: ["M", "M1", "M2", "M3", "M4", "M5", "M6", "M7"],  label: "Bücher, Berichte, Herausgeberschaften" },
  { id: "M1",                                                         label: "Dissertationen" },
  { id: "M2",                                                         label: "Habilitationen" },
  { id: "M3",                                                         label: "Arbeitsberichte" },
  { id: "M4",                                                         label: "Bücher" },
  { id: "M5",                                                         label: "Sonstige Monographien" },
  { id: "M6",                                                         label: "Herausgeberschaften" },
  { id: "M7",                                                         label: "Diplomarbeiten, Bachelor, Master, Staatsexamen" },
  { id: "G1",                                                         label: "Gutachten" },
  { id: "X1",                                                         label: "Sonstige Berichte" },
  { id: "K",   ids: ["K", "K1", "K2"],                                label: "Konferenzbeiträge" },
  { id: "K1",                                                         label: "Poster/Vortrag/Aufsatz extern" },
  { id: "K2",                                                         label: "Poster/Vortrag/Aufsatz intern" },
  { id: "ID",                                                         label: "Im Druck" },
  { id: "FD",                                                         label: "Forschungsdaten" },
  { id: "TR",                                                         label: "Project brief" },
  { id: "gFD", protectedRd: true,                                     label: "Geschützte Forschungsdaten" },
  { id: "NZ",                                                         label: "Nicht zugeordnet" },
  { id: "NJ",                                                         label: "Nicht im Jahresbericht" }
];

// Die Summenspalte umfasst nur die eigentlichen Jahresberichtskategorien
// (ohne NZ, NJ und geschuetzte Forschungsdaten).
var sum_category_ids = ["Z", "Z1", "Z2", "S", "S1", "S2", "M", "M1", "M2", "M3", "M4", "M5", "M6", "M7",
                        "G1", "X1", "K", "K1", "K2", "ID", "FD", "TR"];
var sumLabel = "Summe (Z, S, M, G1, X1, K, ID, FD, TR)";

function instQuery(id) {
  return 'category.top:"mir_institutes:' + id + '"';
}

// Kategoriefilter ueber das TI-eigene Solr-Feld, damit nur die vom TI vergebene
// Kategorie zaehlt (nicht die einer anderen Einrichtung, z.B. MRI, am selben Objekt).
function catQuery(ids) {
  return 'mods.annual_review.ti.category:(' + ids.join(' OR ') + ')';
}

function cellQuery(instId, cat) {
  if (cat.protectedRd) {
    // Geschuetzte Forschungsdaten: Genre research_data im Status "geschuetzt"
    return 'mods.annual_review.ti:' + year + ' AND state:protected'
         + ' AND mods.genre:research_data'
         + ' AND ' + instQuery(instId);
  }
  return 'mods.annual_review.ti:' + year + ' AND state:published'
       + ' AND ' + instQuery(instId)
       + ' AND ' + catQuery(cat.ids ? cat.ids : [cat.id]);
}

function sumQuery(instId) {
  return 'mods.annual_review.ti:' + year + ' AND state:published'
       + ' AND ' + instQuery(instId)
       + ' AND ' + catQuery(sum_category_ids);
}

// Baut eine Kopfzelle (vertikales Label oben, Code unten)
function buildHeadCell(label, code) {
  var th = $('<th/>').attr('scope', 'col').addClass('align-bottom text-center small');
  th.append($('<div/>').addClass('statistic_vertical_label').text(label));
  th.append($('<br/>'));
  th.append($('<b/>').text(code));
  return th;
}

// Erzeugt eine Zaehl-Zelle (td mit SearchCountInline-span)
function countCell(query) {
  var span = $('<span/>')
    .attr('data-mirelementtype', 'SearchCountInline')
    .attr('data-query', query)
    .attr('data-printaslink', 'true');
  return $('<td/>').addClass('text-center').append(span);
}

// Baut eine Tabellenzeile fuer ein Institut
function buildRow(label, instId) {
  var tr = $('<tr/>');
  tr.append($('<td/>').addClass('text-left').text(label));
  tr.append(countCell(sumQuery(instId)));
  $.each(annual_review_categories, function(i, cat) {
    tr.append(countCell(cellQuery(instId, cat)));
  });
  return tr;
}

// Deutsches Label einer Klassifikations-Kategorie (Fallback: erstes Label bzw. ID)
function labelDe(category) {
  var labels = category.labels || [];
  var text = labels.length > 0 ? labels[0].text : category.ID;
  $.each(labels, function(i, label) {
    if (label.lang === "de") {
      text = label.text;
    }
  });
  return text;
}

// Sammelt die aktuell gueltigen TI-Institute (Blaetter des ti-Teilbaums) in Klassifikationsreihenfolge.
// Der Teilbaum vti_vg (Vorgaengereinrichtungen) wird ausgelassen.
function collectInstitutes(category, result) {
  if (category.ID === "vti_vg") {
    return;
  }
  var children = category.categories || [];
  if (children.length === 0) {
    result.push({ id: category.ID, label: labelDe(category) });
  } else {
    $.each(children, function(i, child) {
      collectInstitutes(child, result);
    });
  }
}

function findCategory(categories, id) {
  var found = null;
  $.each(categories || [], function(i, category) {
    if (found === null) {
      found = category.ID === id ? category : findCategory(category.categories, id);
    }
  });
  return found;
}

function buildTable(institutes) {
  var table = $('#ti_stat_table');

  var head = $('<tr/>');
  head.append($('<th/>').attr('scope', 'col').addClass('align-bottom small').append($('<b/>').text('Institut')));
  head.append(buildHeadCell(sumLabel, 'Summe'));
  $.each(annual_review_categories, function(i, cat) {
    head.append(buildHeadCell(cat.label, cat.id));
  });
  table.append($('<thead/>').append(head));

  var body = $('<tbody/>');
  $.each(institutes, function(i, inst) {
    body.append(buildRow(inst.label, inst.id));
  });
  body.append(buildRow("TI gesamt", "ti"));
  table.append(body);

  // Zellen selbst initialisieren: der ready-Scan von searchcount.js ist zu diesem
  // Zeitpunkt (nach dem Laden der Klassifikation) bereits gelaufen.
  table.find('[data-mirelementtype="SearchCountInline"]').each(function(i, element) {
    new SearchCountInline(element, $(element).data('query'), true).init();
  });
}

$(document).ready( function() {
  $('h1').text("Statistik - TI Jahresbericht " + year);
  $('#year_out').text(year);

  $.ajax({
    url: webApplicationBaseURL + 'api/v2/classifications/mir_institutes',
    dataType: 'json'
  }).done(function(mir_institutes) {
    var ti = findCategory(mir_institutes.categories, 'ti');
    var institutes = [];
    if (ti !== null) {
      collectInstitutes(ti, institutes);
    }
    buildTable(institutes);
  }).fail(function() {
    $('#ti_stat_table').replaceWith($('<div/>').addClass('alert alert-danger')
      .text('Die Institutsliste (Klassifikation mir_institutes) konnte nicht geladen werden.'));
  });
});
