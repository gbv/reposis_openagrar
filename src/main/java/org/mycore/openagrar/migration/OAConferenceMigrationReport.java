/*
 * This file is part of ***  M y C o R e  ***
 * See https://www.mycore.de/ for details.
 *
 * MyCoRe is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * MyCoRe is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with MyCoRe.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.mycore.openagrar.migration;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.EnumMap;
import java.util.EnumSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.stream.Stream;

import org.mycore.common.config.MCRConfiguration2;
import org.mycore.common.content.MCRStringContent;
import org.mycore.frontend.MCRFrontendUtil;

/**
 * Collects the decisions of {@link OAConferenceMigrationCommands} and turns them into an HTML report.
 * <p>
 * A run is spread over hundreds of commands, so every package command writes its own log file into
 * {@link #getLogDirectory()}. The report command reads them all, writes the report into the MyCoRe home directory
 * and removes the log.
 */
public final class OAConferenceMigrationReport {

    /** Temporary directory holding the log files of a run. */
    public static final String LOG_DIRECTORY = "oa-conference-migration";

    /** Name of the report, the placeholder is filled with the day of the run. */
    public static final String REPORT_FILE = "conference_log_%s.html";

    /**
     * Reasons that are only counted. Nothing an editor can see changes when a derived displayForm is removed, and
     * listing all of them would bury the cases that need a second look.
     */
    private static final Set<OAConferenceReason> SUMMARY_ONLY = EnumSet.of(OAConferenceReason.DISPLAY_FORM_DROPPED);

    private static final String TITLE = "Conference data, clean up";

    private static final String SUMMARY_ONLY_NOTE = "Not listed one by one: the displayForm was built by the editor"
        + " itself and was nowhere visible, the conference shown does not change.";

    private static final DateTimeFormatter TIMESTAMP = DateTimeFormatter.ofPattern("dd.MM.yyyy HH:mm", Locale.ROOT);

    private static final int LOG_COLUMNS = 8;

    private OAConferenceMigrationReport() {
    }

    /**
     * Directory the package commands write their log files to. It is temporary on purpose, only the report is kept.
     */
    public static Path getLogDirectory() {
        return Path.of(System.getProperty("java.io.tmpdir"), LOG_DIRECTORY);
    }

    /**
     * One log line: object, reason, whether it was written, the values as they were and the namePart that is left.
     */
    public static String toLogLine(String objectID, OAConferenceDecision decision, boolean applied) {
        return String.join("\t", objectID, decision.reason().name(), String.valueOf(applied),
            clean(decision.oldName()), clean(decision.displayForm()), clean(decision.date()),
            clean(decision.affiliation()), clean(decision.newText()));
    }

    /**
     * Writes the decisions of one package, named after the range of documents it covers.
     */
    public static void writeLog(String name, List<String> lines) throws IOException {
        if (lines.isEmpty()) {
            return;
        }
        Path directory = getLogDirectory();
        Files.createDirectories(directory);
        new MCRStringContent(String.join("\n", lines) + "\n").sendTo(directory.resolve(name + ".tsv"));
    }

    /**
     * The log of a run, ordered by document.
     */
    public static List<String[]> readLog() throws IOException {
        Path directory = getLogDirectory();
        if (!Files.isDirectory(directory)) {
            return List.of();
        }
        List<String[]> rows = new ArrayList<>();
        try (Stream<Path> logs = Files.list(directory)) {
            for (Path log : logs.sorted().toList()) {
                for (String line : Files.readAllLines(log, StandardCharsets.UTF_8)) {
                    String[] row = line.split("\t", -1);
                    if (row.length == LOG_COLUMNS) {
                        rows.add(row);
                    }
                }
            }
        }
        rows.sort(Comparator.comparing(row -> row[0]));
        return rows;
    }

    /**
     * Removes the log of a finished run.
     */
    public static void clearLog() throws IOException {
        Path directory = getLogDirectory();
        if (!Files.isDirectory(directory)) {
            return;
        }
        try (Stream<Path> logs = Files.list(directory)) {
            for (Path log : logs.toList()) {
                Files.delete(log);
            }
        }
        Files.delete(directory);
    }

    /**
     * Writes the collected log as an HTML report into the MyCoRe home directory.
     *
     * @param cutoff the day the structured input was given up, shown in the report
     * @return the report that was written
     */
    public static Path write(LocalDate cutoff) throws IOException {
        Path report = Path.of(MCRConfiguration2.getStringOrThrow("MCR.basedir"))
            .resolve(String.format(Locale.ROOT, REPORT_FILE, LocalDate.now(ZoneId.systemDefault())));
        new MCRStringContent(buildReport(readLog(), cutoff, MCRFrontendUtil.getBaseURL())).sendTo(report);
        return report;
    }

    /**
     * Builds the report out of the log, without writing anything.
     *
     * @param rows    the log of a run
     * @param cutoff  the day the structured input was given up
     * @param baseURL the application the documents are linked in
     */
    public static String buildReport(List<String[]> rows, LocalDate cutoff, String baseURL) {
        Map<OAConferenceReason, List<String[]>> byReason = new EnumMap<>(OAConferenceReason.class);
        boolean applied = false;
        for (String[] row : rows) {
            byReason.computeIfAbsent(OAConferenceReason.valueOf(row[1]), reason -> new ArrayList<>()).add(row);
            applied |= Boolean.parseBoolean(row[2]);
        }

        StringBuilder html = new StringBuilder(1024);
        html.append("<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n<meta charset=\"utf-8\">\n<title>")
            .append(TITLE)
            .append("</title>\n<style>\n")
            .append("body{font-family:sans-serif;margin:2rem;color:#222}\n")
            .append("h1{font-size:1.4rem}h2{font-size:1.1rem;margin-top:2.5rem}\n")
            .append("table{border-collapse:collapse;width:100%;margin-top:.5rem}\n")
            .append("th,td{border:1px solid #ccc;padding:.35rem .5rem;text-align:left;vertical-align:top;"
                + "font-size:.85rem}\n")
            .append("th{background:#f2f2f2}\n")
            .append("dl{margin:0}dt{float:left;clear:left;width:7rem;color:#666}dd{margin:0 0 0 7.5rem}\n")
            .append("</style>\n</head>\n<body>\n");

        html.append("<h1>").append(TITLE).append("</h1>\n<p>")
            .append(applied ? "The changes have been saved." : "Dry run, nothing was changed.").append("<br>")
            .append("Cutoff date of the change: ").append(cutoff).append("<br>")
            .append("Created: ").append(LocalDateTime.now(ZoneId.systemDefault()).format(TIMESTAMP))
            .append("</p>\n");

        html.append("<h2>Overview</h2>\n<table>\n<tr><th>Reason</th><th>Count</th></tr>\n");
        for (Map.Entry<OAConferenceReason, List<String[]>> entry : byReason.entrySet()) {
            html.append("<tr><td>").append(escape(entry.getKey().getLabel())).append("</td><td>")
                .append(entry.getValue().size()).append("</td></tr>\n");
        }
        html.append("<tr><td><strong>Total</strong></td><td><strong>").append(rows.size())
            .append("</strong></td></tr>\n</table>\n");

        for (Map.Entry<OAConferenceReason, List<String[]>> entry : byReason.entrySet()) {
            html.append("<h2>").append(escape(entry.getKey().getLabel())).append(" (")
                .append(entry.getValue().size()).append(")</h2>\n");
            if (SUMMARY_ONLY.contains(entry.getKey())) {
                html.append("<p>").append(SUMMARY_ONLY_NOTE).append("</p>\n");
                continue;
            }
            html.append("<table>\n<tr><th>Document</th><th>before</th><th>now</th></tr>\n");
            for (String[] row : entry.getValue()) {
                html.append("<tr><td>").append(link(baseURL, row[0])).append("</td><td>").append(oldValues(row))
                    .append("</td><td>").append(escape(row[7])).append("</td></tr>\n");
            }
            html.append("</table>\n");
        }
        return html.append("</body>\n</html>\n").toString();
    }

    private static String oldValues(String[] row) {
        StringBuilder values = new StringBuilder("<dl>");
        appendValue(values, "Conference", row[3]);
        appendValue(values, "displayForm", row[4]);
        appendValue(values, "Date", row[5]);
        appendValue(values, "Place", row[6]);
        return values.append("</dl>").toString();
    }

    private static void appendValue(StringBuilder values, String label, String value) {
        if (!value.isEmpty()) {
            values.append("<dt>").append(label).append("</dt><dd>").append(escape(value)).append("</dd>");
        }
    }

    private static String link(String baseURL, String objectID) {
        return "<a href=\"" + escape(baseURL + "receive/" + objectID) + "\">" + escape(objectID) + "</a>";
    }

    /**
     * Keeps the tab separated log readable, values never span more than one column or line.
     */
    private static String clean(String value) {
        return value.replaceAll("[\t\r\n]+", " ").trim();
    }

    private static String escape(String value) {
        return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
}
