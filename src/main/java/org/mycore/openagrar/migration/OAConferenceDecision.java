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
 * Result of {@link OAConferenceMigration#decide} for a single mods:name[@type='conference'].
 *
 * @param reason      why the hidden values were kept, merged or dropped
 * @param newText     text of the single mods:namePart that is left, empty if the name is to be removed
 * @param oldName     free text nameParts, joined the way they are joined for {@link #newText()}
 * @param displayForm the mods:displayForm that is dropped
 * @param date        the mods:namePart[@type] values that are dropped or merged
 * @param affiliation the mods:affiliation values that are dropped or merged
 */
public record OAConferenceDecision(OAConferenceReason reason, String newText, String oldName, String displayForm,
    String date, String affiliation) {

    /**
     * Whether the hidden values were taken over into {@link #newText()}.
     */
    public boolean merged() {
        return reason == OAConferenceReason.MERGED;
    }

    /**
     * Whether the conference name has to be removed because nothing is left of it.
     */
    public boolean removesName() {
        return newText.isEmpty();
    }

    /**
     * Whether there were hidden values at all, that is whether an editor could see less than the record holds.
     */
    public boolean hadHiddenValues() {
        return !displayForm.isEmpty() || !date.isEmpty() || !affiliation.isEmpty();
    }
}
