var searchParams = new URLSearchParams(window.location.search);
var year = "";
if (searchParams.has("year") === true) {
  year = searchParams.get("year");
} else {
  year = new Date().getFullYear();
}

$(document).ready(function () {
  $('h1').text(" Statistik - BfR Jahresstatistik " + year);
});

var q_year  = 'mods.yearIssued:' + year;
var q_state = '(state:published OR state:protected)';

// Dokumenttypen (Zeilen)
var q_book                   = 'mods.type:monograph';
var q_bookSection            = 'mods.type:chapter';
var q_confProc               = 'mods.type:abstract';
var q_confProcRef            = 'mods.type:abstract AND mods.note.admin:"Referiert"';
var q_confSpeaker            = 'mods.type:speech AND -mods.note.admin:"Conference Speaker other"';
var q_confSpeakerInvited     = 'mods.type:speech AND mods.note.admin:"Eingeladen"';
var q_confSpeakerOther       = 'mods.type:speech AND mods.note.admin:"Conference Speaker other"';
var q_journalArticle         = 'mods.type:article AND mods.refereed:yes';
var q_journalArticleNRef     = 'mods.type:article AND -mods.refereed:yes';
var q_poster                 = 'mods.type:poster';
var q_reportEFSA             = 'mods.type:report AND mods.note.admin:"EFSA"';
var q_thesis                 = '(mods.type:habilitation OR mods.type:dissertation OR mods.type:diploma_thesis OR mods.type:master_thesis OR mods.type:bachelor_thesis)';
var q_thesisBachelor         = 'mods.type:bachelor_thesis';
var q_thesisMaster           = '(mods.type:diploma_thesis OR mods.type:master_thesis)';
var q_thesisDiss             = '(mods.type:habilitation OR mods.type:dissertation)';

// Abteilungen (Spalten)
var q_instZ      = 'category.top:"mir_institutes:bfr_2022_Z"';
var q_inst1      = 'category.top:"mir_institutes:bfr_2022_1"';
var q_inst2      = 'category.top:"mir_institutes:bfr_2022_2"';
var q_inst3      = 'category.top:"mir_institutes:bfr_2022_3"';
var q_inst4      = 'category.top:"mir_institutes:bfr_2022_4"';
var q_inst5      = 'category.top:"mir_institutes:bfr_2022_5"';
var q_inst6      = 'category.top:"mir_institutes:bfr_2022_6"';
var q_inst7      = 'category.top:"mir_institutes:bfr_2022_7"';
var q_inst8      = 'category.top:"mir_institutes:bfr_2022_8"';
var q_inst9      = 'category.top:"mir_institutes:bfr_2022_9"';
var q_instL      = 'category.top:"mir_institutes:bfr_2022_L"';
var q_instAll    = 'category.top:"mir_institutes:bfr_all"';
