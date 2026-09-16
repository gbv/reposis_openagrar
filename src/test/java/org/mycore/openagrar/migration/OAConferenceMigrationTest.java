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

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.time.LocalDate;
import java.util.Collections;
import java.util.List;

import org.jdom2.Element;
import org.junit.Test;
import org.mycore.common.MCRConstants;

/**
 * Cases taken from the OpenAgrar documents named in each test.
 */
public class OAConferenceMigrationTest {

    private static final LocalDate CUTOFF = LocalDate.of(2017, 1, 1);

    private static final LocalDate BEFORE = LocalDate.of(2014, 5, 20);

    private static final LocalDate AFTER = LocalDate.of(2018, 3, 4);

    /** openagrar_mods_00021055, structured legacy record, date and place belong to the conference. */
    @Test
    public void mergesLegacyRecord() {
        Element name = conference("4th Viruses of Microbes Meeting", null, "18-22 July 2016", "Liverpool, UK");
        OAConferenceDecision decision = OAConferenceMigration.decide(name, BEFORE, CUTOFF);

        assertEquals(OAConferenceReason.MERGED, decision.reason());
        assertEquals("4th Viruses of Microbes Meeting, 18-22 July 2016, Liverpool, UK", decision.newText());
    }

    /** openagrar_mods_00028639, copy: the year of the visible name is missing from the hidden values. */
    @Test
    public void dropsHiddenValuesOnYearConflict() {
        Element name = conference("European Biotechnology Congress 2017",
            "European Biotechnology Congress 2014 2014-05-15-18", "2014-05-15-18", "Lecce, Italy");
        OAConferenceDecision decision = OAConferenceMigration.decide(name, BEFORE, CUTOFF);

        assertTrue(decision.reason() == OAConferenceReason.COPY_BY_YEAR
            || decision.reason() == OAConferenceReason.COPY_BY_DISPLAY_FORM);
        assertEquals("European Biotechnology Congress 2017", decision.newText());
    }

    /** openagrar_mods_00022115, copy: the displayForm still names the conference of the source document. */
    @Test
    public void dropsHiddenValuesOnDisplayFormConflict() {
        Element name = conference("49th Annual Meeting of the Society for Invertebrate Pathology",
            "47th Annual Meeting of the Society for Invertebrate Pathology", "2014-08-03", "Mainz, Germany");
        OAConferenceDecision decision = OAConferenceMigration.decide(name, BEFORE, CUTOFF);

        assertEquals(OAConferenceReason.COPY_BY_DISPLAY_FORM, decision.reason());
        assertEquals("49th Annual Meeting of the Society for Invertebrate Pathology", decision.newText());
    }

    /** Structured values in a document created after the cutoff can only come from a copy. */
    @Test
    public void dropsHiddenValuesOfDocumentsCreatedAfterCutoff() {
        Element name = conference("Some Conference", null, "2014-08-03", "Mainz, Germany");
        OAConferenceDecision decision = OAConferenceMigration.decide(name, AFTER, CUTOFF);

        assertEquals(OAConferenceReason.COPY_BY_DATE, decision.reason());
        assertEquals("Some Conference", decision.newText());
    }

    /** openagrar_mods_00026528, the displayForm is the only conference name there is. */
    @Test
    public void usesDisplayFormWhenThereIsNoNamePart() {
        Element name = conference(null, "29th International Conference of agricultural economists", null, null);
        OAConferenceDecision decision = OAConferenceMigration.decide(name, BEFORE, CUTOFF);

        assertEquals(OAConferenceReason.DISPLAY_FORM_ONLY, decision.reason());
        assertEquals("29th International Conference of agricultural economists", decision.newText());
    }

    /** openagrar_mods_00021547, the date is already spelled out in the namePart. */
    @Test
    public void doesNotRepeatValuesThatAreAlreadyPartOfTheName() {
        Element name = conference("2016 KoSFoST International Symposium, August 17 to 19, 2016, Daegu, Korea",
            null, "August 17 to 19, 2016", "Daegu, Korea");
        OAConferenceDecision decision = OAConferenceMigration.decide(name, BEFORE, CUTOFF);

        assertEquals("2016 KoSFoST International Symposium, August 17 to 19, 2016, Daegu, Korea", decision.newText());
    }

    /** openagrar_mods_00006018, title and subtitle are two nameParts, only the first one is editable. */
    @Test
    public void joinsSeveralFreeTextNameParts() {
        Element name = conference("3rd ECETOC Workshop", null, null, null);
        name.addContent(1, namePart(null, "Omics and Risk Assessment Science"));
        OAConferenceDecision decision = OAConferenceMigration.decide(name, BEFORE, CUTOFF);

        assertEquals("3rd ECETOC Workshop, Omics and Risk Assessment Science", decision.newText());
    }

    /** bimport_mods_00001374, an entry that holds nothing but a place. */
    @Test
    public void removesEntriesWithoutAnyConferenceName() {
        Element name = conference(null, null, null, "Edinburgh, Scotland");
        OAConferenceDecision decision = OAConferenceMigration.decide(name, BEFORE, CUTOFF);

        assertEquals(OAConferenceReason.EMPTY, decision.reason());
        assertTrue(decision.removesName());
    }

    /** bimport_mods_00001424, the displayForm repeats the date and is no conference name. */
    @Test
    public void removesEntriesWhoseDisplayFormIsOnlyTheDate() {
        Element name = conference(null, "2003/02/27/01.03.2003", "2003/02/27/01.03.2003", "ICC Berlin, Germany");
        OAConferenceDecision decision = OAConferenceMigration.decide(name, BEFORE, CUTOFF);

        assertEquals(OAConferenceReason.EMPTY, decision.reason());
        assertEquals("", decision.newText());
    }

    /** openagrar_mods_00052443, date and place without a name are no conference either. */
    @Test
    public void removesEntriesThatOnlyHoldDateAndPlace() {
        Element name = conference(null, null, "2012-09-22", "Adana, Türkei");
        OAConferenceDecision decision = OAConferenceMigration.decide(name, BEFORE, CUTOFF);

        assertEquals(OAConferenceReason.EMPTY, decision.reason());
        assertEquals("", decision.newText());
    }

    @Test
    public void leavesEditorShapedNamesAlone() {
        Element name = conference("Max Rubner Conference 2016, Karlsruhe", null, null, null);
        OAConferenceDecision decision = OAConferenceMigration.decide(name, BEFORE, CUTOFF);

        assertEquals(OAConferenceReason.UNCHANGED, decision.reason());
        assertTrue(OAConferenceMigration.apply(name, decision) == false);
    }

    @Test
    public void applyLeavesOneNamePartAndKeepsForeignChildren() {
        Element name = conference("4th Viruses of Microbes Meeting", "4th Viruses of Microbes Meeting",
            "18-22 July 2016", "Liverpool, UK");
        Element identifier = new Element("nameIdentifier", MCRConstants.MODS_NAMESPACE).setAttribute("type", "gnd")
            .setText("1089062095");
        name.addContent(identifier);

        assertTrue(OAConferenceMigration.apply(name, OAConferenceMigration.decide(name, BEFORE, CUTOFF)));
        assertEquals(1, name.getChildren("namePart", MCRConstants.MODS_NAMESPACE).size());
        assertEquals("4th Viruses of Microbes Meeting, 18-22 July 2016, Liverpool, UK",
            name.getChildText("namePart", MCRConstants.MODS_NAMESPACE));
        assertEquals(0, name.getChildren("displayForm", MCRConstants.MODS_NAMESPACE).size());
        assertEquals(0, name.getChildren("affiliation", MCRConstants.MODS_NAMESPACE).size());
        assertEquals(1, name.getChildren("nameIdentifier", MCRConstants.MODS_NAMESPACE).size());
    }

    @Test
    public void ignoresConferenceNamesInsideRelatedItem() {
        Element mods = new Element("mods", MCRConstants.MODS_NAMESPACE);
        mods.addContent(conference("Own conference", "Own conference", null, null));
        Element relatedItem = new Element("relatedItem", MCRConstants.MODS_NAMESPACE);
        relatedItem.addContent(conference("Host conference", "Host conference", "2014-08-03", "Mainz"));
        mods.addContent(relatedItem);

        List<Element> names = OAConferenceMigration.conferenceNames(mods);

        assertEquals(1, names.size());
        assertEquals("Own conference", names.get(0).getChildText("namePart", MCRConstants.MODS_NAMESPACE));
    }

    @Test
    public void reportListsEveryDecisionWithItsValues() {
        Element name = conference("4th Viruses of Microbes Meeting", null, "18-22 July 2016", "Liverpool, UK");
        OAConferenceDecision decision = OAConferenceMigration.decide(name, BEFORE, CUTOFF);
        List<String[]> rows = Collections
            .singletonList(OAConferenceMigrationReport.toLogLine("openagrar_mods_00021055", decision, true)
                .split("\t", -1));

        String html = OAConferenceMigrationReport.buildReport(rows, CUTOFF, "https://www.openagrar.de/");

        assertTrue(html.startsWith("<!DOCTYPE html>"));
        assertTrue(html.contains("https://www.openagrar.de/receive/openagrar_mods_00021055"));
        assertTrue(html.contains("18-22 July 2016"));
        assertTrue(html.contains("4th Viruses of Microbes Meeting, 18-22 July 2016, Liverpool, UK"));
    }

    /** Tabs and line breaks would tear the log apart. */
    @Test
    public void logLineHoldsOneLineOfEightColumns() {
        Element name = conference("A\tconference\nname", null, "2016", null);
        String line = OAConferenceMigrationReport.toLogLine("openagrar_mods_00021055",
            OAConferenceMigration.decide(name, BEFORE, CUTOFF), false);

        assertEquals(8, line.split("\t", -1).length);
        assertTrue(!line.contains("\n"));
    }

    private static Element conference(String namePart, String displayForm, String date, String affiliation) {
        Element name = new Element("name", MCRConstants.MODS_NAMESPACE).setAttribute("type", "conference");
        if (displayForm != null) {
            name.addContent(new Element("displayForm", MCRConstants.MODS_NAMESPACE).setText(displayForm));
        }
        if (namePart != null) {
            name.addContent(namePart(null, namePart));
        }
        if (date != null) {
            name.addContent(namePart("date", date));
        }
        if (affiliation != null) {
            name.addContent(new Element("affiliation", MCRConstants.MODS_NAMESPACE).setText(affiliation));
        }
        return name;
    }

    private static Element namePart(String type, String text) {
        Element namePart = new Element("namePart", MCRConstants.MODS_NAMESPACE).setText(text);
        if (type != null) {
            namePart.setAttribute("type", type);
        }
        return namePart;
    }
}
