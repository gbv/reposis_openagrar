// Statistik-Uebersicht: baut die Jahres-Linklisten fuer die einzelnen Statistiken auf.

$(document).ready( function() {
  var year = new Date().getFullYear();
  var year1 = year - 5;
  if (year1 < 2018) year1 = 2018;

  for (i = year1; i <= year; i++) {
    var li = $('<li />');
    li.append('<a href="jki_statstics_2020.xml?year=' + i + '">' + i + '</a>');
    $("#jki_statistic_2020").append(li);
    li = $('<li />');
    li.append('<a href="jki_statstics_2020.xml?year=' + i + '&JCRClasses1Yb=true">' + i + ' mit JCR vom Vorjahr</a>');
    $("#jki_statistic_2020").append(li);
    li = $('<li />');
    li.append('<a href="jki_statstics_2020.xml?year=' + i + '&JCRClasses2Yb=true">' + i + ' mit JCR von 2 Jahren zuvor</a>');
    $("#jki_statistic_2020").append(li);
  }

  for (i = year1; i <= year; i++) {
    var li = $('<li />');
    li.append('<a href="ti_annual_review.xml?year=' + i + '">' + i + '</a>');
    $("#ti_annual_review").append(li);
  }

  $("#bfr_statistic").empty();
  for (i = year1; i <= year; i++) {
    var li = $('<li />');
    li.append('<a href="bfr_statistics.xml?year=' + i + '">' + i + '</a>');
    $("#bfr_statistic").append(li);
  }
});
