// Generische Jahresberichtskategorien-Statistik je Institut und Jahr.
// Liest institute + year aus der URL, setzt Ueberschrift/Text und baut den
// Statisticsbrowser-Container, der anschliessend von statistic.js initialisiert wird.
// Muss daher VOR statistic.js eingebunden werden.

var instRepCatLabels = {
  bfr: "BfR",
  fli: "FLI",
  jki: "JKI",
  mri: "MRI",
  ti:  "TI"
};

$(document).ready(function() {
  var params = new URLSearchParams(window.location.search);
  var institute = params.get("institute");
  var year = params.has("year") ? params.get("year") : new Date().getFullYear();
  var label = instRepCatLabels[institute] || institute;

  $(".inst-repCat").each(function() {
    var box = $(this);
    var lang = box.data("lang") === "en" ? "en" : "de";

    if (lang === "en") {
      box.find(".inst-repCat-title").text("Statistic - " + label + " annual review categories");
      box.find(".inst-repCat-desc").text("The publications of " + label + " per annual review category for the year " + year + ".");
    } else {
      box.find(".inst-repCat-title").text("Statistik - " + label + " Jahresberichtskategorien");
      box.find(".inst-repCat-desc").text("Die Publikationen des " + label + " nach Jahresberichtskategorie für das Jahr " + year + ".");
    }

    // data-fq als JSON-Array-String mit escapten Anfuehrungszeichen (wie im urspruenglichen XML)
    var fq = '["objectType:mods","category.top:\\"mir_institutes:' + institute + '\\"","mods.yearIssued:' + year + '"]';

    var browser = $('<div/>')
      .attr('data-mirelementtype', 'Statisticsbrowser')
      .attr('data-classification', 'mir_institutes')
      .attr('data-rootcategory', institute)
      .attr('data-facets', '[]')
      .attr('data-horizontalFacet', '{"name":"category.top","valuePrefix":"annual_review"}')
      .attr('data-fq', fq)
      .attr('data-expandAllElements', 'true')
      .attr('data-hideEmptyElements', 'true')
      .attr('data-lang', lang);

    box.find(".inst-repCat-browser").append(browser);
  });
});
