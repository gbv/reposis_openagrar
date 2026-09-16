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

/**
 * Why {@link OAConferenceMigration} kept, merged or dropped the values an editor cannot see.
 */
public enum OAConferenceReason {

    /** Date and place were taken over into the namePart. */
    MERGED("date and place taken over"),

    /** The record was created after the structured input was given up, so the values come from a copy. */
    COPY_BY_DATE("created after the change, values come from a copy"),

    /** The displayForm does not match the namePart, so the name was replaced after the values were written. */
    COPY_BY_DISPLAY_FORM("displayForm does not match the conference name, values come from a copy"),

    /** The year in the namePart is missing from the hidden values, so they describe another conference. */
    COPY_BY_YEAR("year contradicts the conference name, values come from a copy"),

    /** There was nothing but a displayForm, which becomes the namePart. */
    DISPLAY_FORM_ONLY("displayForm taken over as conference name"),

    /** Only a displayForm was dropped, it holds no information of its own. */
    DISPLAY_FORM_DROPPED("displayForm removed"),

    /** There is no namePart and no displayForm, so date and place alone are dropped with the whole name. */
    EMPTY("no conference name, entry removed with date and place"),

    /** The name already looked the way the editor writes it, nothing to do. */
    UNCHANGED("unchanged");

    private final String label;

    OAConferenceReason(String label) {
        this.label = label;
    }

    /**
     * Wording used in the report.
     */
    public String getLabel() {
        return label;
    }
}
