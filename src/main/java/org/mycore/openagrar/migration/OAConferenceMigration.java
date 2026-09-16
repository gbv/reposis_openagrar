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

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import org.jdom2.Element;
import org.mycore.common.MCRConstants;

/**
 * OA-420: reduces mods:name[@type='conference'] to the single free text field the editor shows and writes.
 * <p>
 * mods:displayForm, mods:namePart[@type] and mods:affiliation are removed. Date and place are taken over into
 * the namePart only when they still belong to the conference named there. Documents that were created as a copy
 * of another document kept these values of the conference they were copied from while the editor could correct
 * the namePart alone, see {@link OAConferenceReason}.
 * <p>
 * The displayForm never carries information of its own: from MIR-408 until MIR-1522 the editor built it out of
 * the nameParts on every load of a name that had none, so it is a snapshot of the namePart. It is only used when
 * a conference name has no free text namePart at all.
 */
public final class OAConferenceMigration {

    /** Four digit year that is not part of a longer number. */
    private static final Pattern YEAR = Pattern.compile("(?<!\\d)(1[89]|20)\\d{2}(?!\\d)");

    private static final String SEPARATOR = ", ";

    private OAConferenceMigration() {
    }

    /**
     * All conference names directly below the given mods:mods. Names inside mods:relatedItem are left out, they
     * describe referenced objects and are not edited in this document.
     *
     * @param mods the mods:mods element of the document
     * @return the conference names of the document itself
     */
    public static List<Element> conferenceNames(Element mods) {
        return mods.getChildren("name", MCRConstants.MODS_NAMESPACE)
            .stream()
            .filter(name -> "conference".equals(name.getAttributeValue("type")))
            .collect(Collectors.toList());
    }

    /**
     * Decides what is left of a conference name without touching it.
     *
     * @param name    a mods:name[@type='conference']
     * @param created the creation date of the document, may be null if it is unknown
     * @param cutoff  the date the structured input was given up, hidden values in documents created afterwards
     *                can only come from a copy
     * @return what the name should look like and why
     */
    public static OAConferenceDecision decide(Element name, LocalDate created, LocalDate cutoff) {
        String freeText = join(namePartsWithoutType(name));
        String displayForm = normalize(name.getChildText("displayForm", MCRConstants.MODS_NAMESPACE));
        String date = join(namePartsWithType(name));
        String affiliation = join(name.getChildren("affiliation", MCRConstants.MODS_NAMESPACE));

        // date and place are no conference name of their own, without a namePart nothing is left to keep
        String base = freeText.isEmpty() ? displayForm : freeText;
        if (base.isEmpty() || (freeText.isEmpty() && holdsNoName(displayForm, date, affiliation))) {
            return new OAConferenceDecision(OAConferenceReason.EMPTY, "", freeText, displayForm, date, affiliation);
        }

        OAConferenceReason conflict = findConflict(freeText, displayForm, date, affiliation, created, cutoff);
        if (conflict != null) {
            return new OAConferenceDecision(conflict, base, freeText, displayForm, date, affiliation);
        }

        String text = append(append(base, date), affiliation);
        OAConferenceReason reason;
        if (!date.isEmpty() || !affiliation.isEmpty()) {
            reason = OAConferenceReason.MERGED;
        } else if (freeText.isEmpty()) {
            reason = OAConferenceReason.DISPLAY_FORM_ONLY;
        } else if (!displayForm.isEmpty()) {
            reason = OAConferenceReason.DISPLAY_FORM_DROPPED;
        } else {
            reason = OAConferenceReason.UNCHANGED;
        }
        return new OAConferenceDecision(reason, text, freeText, displayForm, date, affiliation);
    }

    /**
     * Rewrites the conference name as decided. The name keeps its attributes and every child the editor does not
     * handle either, for instance mods:role and mods:nameIdentifier.
     *
     * @param name     a mods:name[@type='conference']
     * @param decision the decision taken for this name
     * @return true if the document was changed
     */
    public static boolean apply(Element name, OAConferenceDecision decision) {
        if (decision.reason() == OAConferenceReason.UNCHANGED) {
            return false;
        }
        if (decision.removesName()) {
            return name.getParentElement().removeContent(name);
        }
        name.removeChildren("namePart", MCRConstants.MODS_NAMESPACE);
        name.removeChildren("displayForm", MCRConstants.MODS_NAMESPACE);
        name.removeChildren("affiliation", MCRConstants.MODS_NAMESPACE);
        name.addContent(0, new Element("namePart", MCRConstants.MODS_NAMESPACE).setText(decision.newText()));
        return true;
    }

    /**
     * Whether the displayForm repeats nothing but the date or the place. Such a displayForm is no conference name
     * and cannot stand in for a missing namePart, see bimport_mods_00001424.
     */
    private static boolean holdsNoName(String displayForm, String date, String affiliation) {
        String squeezed = squeeze(displayForm);
        return !squeezed.isEmpty()
            && (squeeze(date).contains(squeezed) || squeeze(affiliation).contains(squeezed));
    }

    /**
     * The signal that exposes hidden values as belonging to another conference, null if there is none.
     */
    private static OAConferenceReason findConflict(String freeText, String displayForm, String date,
        String affiliation, LocalDate created, LocalDate cutoff) {
        if (date.isEmpty() && affiliation.isEmpty()) {
            // nothing is merged anyway, so the origin of the displayForm does not matter
            return null;
        }
        if (created != null && !created.isBefore(cutoff)) {
            return OAConferenceReason.COPY_BY_DATE;
        }
        if (!displayForm.isEmpty() && !freeText.isEmpty()) {
            String squeezedName = squeeze(freeText);
            String squeezedDisplayForm = squeeze(displayForm);
            if (!squeezedDisplayForm.contains(squeezedName) && !squeezedName.contains(squeezedDisplayForm)) {
                return OAConferenceReason.COPY_BY_DISPLAY_FORM;
            }
        }
        List<String> nameYears = years(freeText);
        List<String> hiddenYears = years(date + " " + displayForm);
        if (!nameYears.isEmpty() && !hiddenYears.isEmpty() && nameYears.stream().noneMatch(hiddenYears::contains)) {
            return OAConferenceReason.COPY_BY_YEAR;
        }
        return null;
    }

    private static List<Element> namePartsWithoutType(Element name) {
        return name.getChildren("namePart", MCRConstants.MODS_NAMESPACE)
            .stream()
            .filter(namePart -> namePart.getAttributeValue("type") == null)
            .collect(Collectors.toList());
    }

    private static List<Element> namePartsWithType(Element name) {
        return name.getChildren("namePart", MCRConstants.MODS_NAMESPACE)
            .stream()
            .filter(namePart -> namePart.getAttributeValue("type") != null)
            .collect(Collectors.toList());
    }

    private static String join(List<Element> elements) {
        return elements.stream()
            .map(element -> normalize(element.getText()))
            .filter(text -> !text.isEmpty())
            .collect(Collectors.joining(SEPARATOR));
    }

    /**
     * Appends a value unless the text already holds it, ignoring case, spaces and punctuation.
     */
    private static String append(String text, String value) {
        if (value.isEmpty() || squeeze(text).contains(squeeze(value))) {
            return text;
        }
        return text.isEmpty() ? value : text + SEPARATOR + value;
    }

    private static List<String> years(String text) {
        List<String> years = new ArrayList<>();
        Matcher matcher = YEAR.matcher(text);
        while (matcher.find()) {
            years.add(matcher.group());
        }
        return years;
    }

    /**
     * Lower case without spaces and punctuation, so that "June 07 - 10, 2016" and "June 07-10, 2016" match.
     */
    private static String squeeze(String text) {
        StringBuilder squeezed = new StringBuilder(text.length());
        text.toLowerCase(Locale.ROOT).chars().filter(Character::isLetterOrDigit)
            .forEach(c -> squeezed.append((char) c));
        return squeezed.toString();
    }

    private static String normalize(String text) {
        return text == null ? "" : text.trim().replaceAll("\\s+", " ");
    }
}
