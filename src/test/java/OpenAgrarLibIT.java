/*
 * This file is part of ***  M y C o R e  ***
 * See http://www.mycore.de/ for details.
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

import org.junit.After;
import org.junit.Test;
import org.mycore.common.selenium.MCRSeleniumTestBase;
import org.openqa.selenium.By;
import org.openqa.selenium.support.ui.ExpectedConditions;

public class OpenAgrarLibIT extends MCRSeleniumTestBase {

    @Test
    public void testStart() throws InterruptedException {
        Thread.sleep(10000);
        driver.get("http://localhost:9107/openagrar/content/index.xml");
        driver.waitFor(ExpectedConditions.titleContains("Willkommen auf den Seiten des Publikationsservers OpenAgrar"));
        driver.waitAndFindElement(By.xpath("//*[contains(text(), 'Publikationsservers OpenAgrar')]"));
    }



    @After
    public void tearDown() {
        takeScreenshot();
    }


}
