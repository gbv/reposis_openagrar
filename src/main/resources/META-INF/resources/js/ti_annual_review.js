// TI-Jahresbericht-Statistik: baut die Tabelle (Zeilen = Institute, Spalten = Jahresberichtskategorien)
// und erzeugt je Zelle ein SearchCountInline-Element, das von searchcount.js gefuellt wird.

var searchParams = new URLSearchParams(window.location.search);
var year = searchParams.has("year") ? searchParams.get("year") : new Date().getFullYear();

// Basis-Query: Jahresberichtsjahr des TI + veroeffentlicht
var q_year = 'mods.annual_review.ti:' + year + ' AND state:published';

// Institute des TI (Reihenfolge der Zeilen)
var ti_institutes = [
  { id: "ti_kb",   label: "Stabsstellen Klima und Boden" },
  { id: "ti_ma",   label: "Institut für Marktanalyse" },
  { id: "ti_at",   label: "Institut für Agrartechnologie" },
  { id: "ti_ak",   label: "Institut für Agrarklimaschutz" },
  { id: "ti_lr",   label: "Institut für Ländliche Räume" },
  { id: "ti_bw",   label: "Institut für Betriebswirtschaft" },
  { id: "ti_bd",   label: "Institut für Biodiversität" },
  { id: "ti_ol",   label: "Institut für Ökologischen Landbau" },
  { id: "ti_hf",   label: "Institut für Holzforschung" },
  { id: "ti_wffo", label: "Institut für Internationale Waldwirtschaft und Forstökonomie" },
  { id: "ti_wo",   label: "Institut für Waldökosysteme" },
  { id: "ti_fg",   label: "Institut für Forstgenetik" },
  { id: "ti_sf",   label: "Institut für Seefischerei" },
  { id: "ti_fi",   label: "Institut für Fischereiökologie" },
  { id: "ti_of",   label: "Institut für Ostseefischerei" },
  { id: "ti_it",   label: "Informationstechnik" },
  { id: "ti_fz",   label: "Fachinformationszentrum" }
];

// Jahresberichtskategorien (Spalten, alphabetisch nach ID)
var annual_review_categories = [
  { id: "FD", label: "Forschungsdaten" },
  { id: "G1", label: "Gutachten" },
  { id: "ID", label: "Im Druck" },
  { id: "K1", label: "Konferenzbeitrag extern" },
  { id: "K2", label: "Konferenzbeitrag intern" },
  { id: "M1", label: "Dissertationen" },
  { id: "M2", label: "Habilitationen" },
  { id: "M3", label: "Arbeitsberichte" },
  { id: "M4", label: "Bücher" },
  { id: "M5", label: "Sonstige Monographien" },
  { id: "M6", label: "Herausgeberschaften" },
  { id: "M7", label: "Diplom-/Bachelor-/Master-/Staatsexamensarbeiten" },
  { id: "NJ", label: "Nicht im Jahresbericht" },
  { id: "NZ", label: "Nicht zugeordnet" },
  { id: "S1", label: "Beiträge in Büchern/Sammelwerken, Fremdverlag" },
  { id: "S2", label: "Beiträge in Büchern/Sammelwerken, Eigenverlag" },
  { id: "TR", label: "Project brief" },
  { id: "X1", label: "Sonstige Berichte" },
  { id: "Z1", label: "Referierte Zeitschriftenbeiträge" },
  { id: "Z2", label: "Nicht referierte Zeitschriftenbeiträge" }
];

function instQuery(id) {
  return 'category.top:"mir_institutes:' + id + '"';
}
function catQuery(id) {
  return 'category.top:"annual_review:' + id + '"';
}

// Sonderspalte rechts von FD: geschuetzte Forschungsdaten.
// Kein Pendant in den Jahresberichtskategorien:
// Genre research_data, Status geschuetzt (protected), Kategorie "nicht im Jahresbericht" (NJ).
var protectedRdLabel = "Geschützte Forschungsdaten";
var protectedRdCode = "gFD";
function protectedRdQuery(instId) {
  return 'mods.annual_review.ti:' + year + ' AND state:protected'
       + ' AND mods.genre:research_data'
       + ' AND category.top:"annual_review:NJ"'
       + ' AND ' + instQuery(instId);
}

// Baut eine Kopfzelle (vertikales Label oben, Code unten)
function buildHeadCell(label, code) {
  var th = $('<td/>').addClass('align-bottom text-center small');
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
  var iq = instQuery(instId);
  var tr = $('<tr/>');
  tr.append($('<td/>').addClass('text-left').text(label));
  // Summenspalte (ueber alle Kategorien)
  tr.append(countCell(q_year + ' AND ' + iq));
  // je Jahresberichtskategorie eine Spalte
  $.each(annual_review_categories, function(i, cat) {
    tr.append(countCell(q_year + ' AND ' + iq + ' AND ' + catQuery(cat.id)));
    // Sonderspalte direkt rechts von FD
    if (cat.id === "FD") {
      tr.append(countCell(protectedRdQuery(instId)));
    }
  });
  return tr;
}

$(document).ready( function() {
  $('h1').text("Statistik - TI Jahresbericht " + year);
  $('#year_out').text(year);

  var table = $('#ti_stat_table');

  // Kopfzeile
  var head = $('<tr/>');
  head.append($('<td/>').addClass('align-bottom text-center small').append($('<b/>').text('Institut')));
  head.append($('<td/>').addClass('align-bottom text-center small').append($('<b/>').text('Summe')));
  $.each(annual_review_categories, function(i, cat) {
    head.append(buildHeadCell(cat.label, cat.id));
    // Sonderspalte direkt rechts von FD
    if (cat.id === "FD") {
      head.append(buildHeadCell(protectedRdLabel, protectedRdCode));
    }
  });
  table.append(head);

  // Datenzeilen: ueber die Institute iterieren
  $.each(ti_institutes, function(i, inst) {
    table.append(buildRow(inst.label, inst.id));
  });
  table.append(buildRow("TI gesamt", "ti"));
});
