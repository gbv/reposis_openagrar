// Generische Genre/referiert-Statistik je Institut ueber die letzten 5 Jahre.
// Liest institute aus der URL, berechnet den Jahresbereich und baut den
// Statisticsbrowser-Container, der anschliessend von statistic.js initialisiert wird.
// Muss daher VOR statistic.js eingebunden werden.

var genreRefLabels = {
  bfr: "BfR",
  fli: "FLI",
  jki: "JKI",
  mri: "MRI",
  ti:  "TI"
};

$(document).ready(function() {
  var params = new URLSearchParams(window.location.search);
  var institute = params.get("institute");
  var label = genreRefLabels[institute] || institute;

  var yearTo = new Date().getFullYear();
  var yearFrom = yearTo - 4; // letzte 5 Jahre (inkl. aktuellem Jahr)

  $(".genre-ref").each(function() {
    var box = $(this);
    var lang = box.data("lang") === "en" ? "en" : "de";

    if (lang === "en") {
      box.find(".genre-ref-title").text("Statistic - " + label + " genre");
      box.find(".genre-ref-desc").text("The publications of " + label + " per year, genre and refereed (" + yearFrom + " to " + yearTo + ").");
    } else {
      box.find(".genre-ref-title").text("Statistik - " + label + " Genre");
      box.find(".genre-ref-desc").text("Die Publikationen des " + label + " nach Genre und referiert für die Jahre " + yearFrom + " bis " + yearTo + ".");
    }

    // data-fq als JSON-Array-String mit escapten Anfuehrungszeichen (wie im urspruenglichen XML)
    var fq = '["objectType:mods","category.top:\\"mir_institutes:' + institute + '\\"","mods.yearIssued:[' + yearFrom + ' TO ' + yearTo + ']"]';

    var browser = $('<div/>')
      .attr('data-mirelementtype', 'Statisticsbrowser')
      .attr('data-facets', '["mods.genre","mods.refereed"]')
      .attr('data-horizontalFacet', 'mods.yearIssued')
      .attr('data-fq', fq)
      .attr('data-expandAllElements', 'true')
      .attr('data-hideEmptyElements', 'true')
      .attr('data-lang', lang);

    box.find(".genre-ref-browser").append(browser);
  });
});
