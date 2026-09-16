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
import java.nio.file.Path;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import java.util.stream.Collectors;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;
import org.jdom2.Element;
import org.mycore.access.MCRAccessException;
import org.mycore.common.config.MCRConfiguration2;
import org.mycore.datamodel.common.MCRXMLMetadataManager;
import org.mycore.datamodel.metadata.MCRMetadataManager;
import org.mycore.datamodel.metadata.MCRObject;
import org.mycore.datamodel.metadata.MCRObjectID;
import org.mycore.datamodel.metadata.MCRObjectService;
import org.mycore.frontend.cli.MCRCommandUtils;
import org.mycore.frontend.cli.annotation.MCRCommand;
import org.mycore.frontend.cli.annotation.MCRCommandGroup;
import org.mycore.mods.MCRMODSWrapper;

/**
 * OA-420: command line interface of {@link OAConferenceMigration}.
 * <p>
 * The work is spread over one command per package of documents, so that no session stays open for the whole run.
 * Every package appends its decisions to {@link OAConferenceMigrationReport#LOG_FILE}, the last command of the run
 * turns that log into an HTML report for the editors.
 */
@MCRCommandGroup(name = "OpenAgrar conference migration")
public class OAConferenceMigrationCommands {

    /** Number of documents one package command works on. */
    public static final String CHUNK_SIZE_PROPERTY = "OpenAgrar.Conference.Migration.ChunkSize";

    /** Day the structured conference input was given up, as ISO date. */
    public static final String CUTOFF_PROPERTY = "OpenAgrar.Conference.Migration.CutoffDate";

    private static final Logger LOGGER = LogManager.getLogger();

    @MCRCommand(
        syntax = "check conference names of all objects of type {0}",
        help = "Reports what 'migrate conference names of all objects of type {0}' would change in"
            + " mods:name[@type='conference'], without changing anything.",
        order = 10)
    public static List<String> checkConferenceNames(String type) throws IOException {
        return buildCommands(type, true);
    }

    @MCRCommand(
        syntax = "migrate conference names of all objects of type {0}",
        help = "Reduces every mods:name[@type='conference'] of all objects of type {0} to the single namePart the"
            + " editor can edit and writes a report into the MyCoRe home directory. Names inside mods:relatedItem"
            + " stay untouched.",
        order = 20)
    public static List<String> migrateConferenceNames(String type) throws IOException {
        return buildCommands(type, false);
    }

    @MCRCommand(
        syntax = "check conference names of objects from {0} to {1}",
        help = "Reports one package of documents, called by 'check conference names of all objects of type {0}'.",
        order = 30)
    public static void checkConferenceNamesOfObjects(String fromID, String toID) throws IOException,
        MCRAccessException {
        handleObjects(fromID, toID, true);
    }

    @MCRCommand(
        syntax = "migrate conference names of objects from {0} to {1}",
        help = "Handles one package of documents, called by 'migrate conference names of all objects of type"
            + " {0}'.",
        order = 40)
    public static void migrateConferenceNamesOfObjects(String fromID, String toID) throws IOException,
        MCRAccessException {
        handleObjects(fromID, toID, false);
    }

    @MCRCommand(
        syntax = "write conference migration report",
        help = "Turns the log written by the package commands into an HTML report and removes the log.",
        order = 50)
    public static void writeConferenceMigrationReport() throws IOException {
        Path report = OAConferenceMigrationReport.write(getCutoff());
        OAConferenceMigrationReport.clearLog();
        LOGGER.info("Conference migration report: {}", report.toUri());
    }

    /**
     * One command per package of documents plus the report command at the end.
     */
    private static List<String> buildCommands(String type, boolean dryRun) throws IOException {
        OAConferenceMigrationReport.clearLog();

        int chunkSize = MCRConfiguration2.getInt(CHUNK_SIZE_PROPERTY)
            .orElseThrow(() -> MCRConfiguration2.createConfigurationException(CHUNK_SIZE_PROPERTY));

        // packages never span two bases, so that every package command works on one ID range
        Map<String, List<MCRObjectID>> idsByBase = MCRXMLMetadataManager.instance()
            .listIDsOfType(type)
            .stream()
            .map(MCRObjectID::getInstance)
            .sorted()
            .collect(Collectors.groupingBy(MCRObjectID::getBase, TreeMap::new, Collectors.toList()));

        String command = dryRun ? "check" : "migrate";
        List<String> commands = new ArrayList<>();
        int objects = 0;
        for (List<MCRObjectID> ids : idsByBase.values()) {
            objects += ids.size();
            for (int index = 0; index < ids.size(); index += chunkSize) {
                MCRObjectID first = ids.get(index);
                MCRObjectID last = ids.get(Math.min(index + chunkSize, ids.size()) - 1);
                commands.add(command + " conference names of objects from " + first + " to " + last);
            }
        }
        if (commands.isEmpty()) {
            LOGGER.warn("No objects of type {} found.", type);
            return List.of();
        }
        commands.add("write conference migration report");
        LOGGER.info("{} objects in {} packages", objects, commands.size() - 1);
        return commands;
    }

    /**
     * Handles one package of documents in its own session and writes its part of the log.
     */
    private static void handleObjects(String fromID, String toID, boolean dryRun)
        throws IOException, MCRAccessException {
        LocalDate cutoff = getCutoff();
        List<String> lines = new ArrayList<>();
        for (String id : MCRCommandUtils.getIdsFromIdToId(fromID, toID).toList()) {
            lines.addAll(handleObject(MCRObjectID.getInstance(id), cutoff, dryRun));
        }
        OAConferenceMigrationReport.writeLog(fromID + "-" + toID, lines);
        LOGGER.info("{} conference names to change between {} and {}", lines.size(), fromID, toID);
    }

    /**
     * Decides and, unless this is a dry run, rewrites the conference names of one document.
     *
     * @return one log line per conference name that is not already in the shape the editor writes
     */
    private static List<String> handleObject(MCRObjectID objectID, LocalDate cutoff, boolean dryRun)
        throws MCRAccessException {
        MCRObject object = MCRMetadataManager.retrieveMCRObject(objectID);
        Element mods = new MCRMODSWrapper(object).getMODS();
        if (mods == null) {
            return List.of();
        }
        List<String> lines = new ArrayList<>();
        boolean changed = false;
        for (Element name : OAConferenceMigration.conferenceNames(mods)) {
            OAConferenceDecision decision = OAConferenceMigration.decide(name, getCreationDate(object), cutoff);
            if (decision.reason() == OAConferenceReason.UNCHANGED) {
                continue;
            }
            lines.add(OAConferenceMigrationReport.toLogLine(objectID.toString(), decision, !dryRun));
            if (!dryRun) {
                changed |= OAConferenceMigration.apply(name, decision);
            }
        }
        if (changed) {
            MCRMetadataManager.update(object);
        }
        return lines;
    }

    private static LocalDate getCreationDate(MCRObject object) {
        Date created = object.getService().getDate(MCRObjectService.DATE_TYPE_CREATEDATE);
        return created == null ? null : created.toInstant().atZone(ZoneOffset.UTC).toLocalDate();
    }

    private static LocalDate getCutoff() {
        return LocalDate.parse(MCRConfiguration2.getStringOrThrow(CUTOFF_PROPERTY));
    }
}
