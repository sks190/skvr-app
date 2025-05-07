xquery version "3.1";

(: 
 : Module for app-specific template functions
 :
 : Add your own templating functions here, e.g. if you want to extend the template used for showing
 : the browsing view.
 :)
module namespace app="teipublisher.com/app";

import module namespace templates="http://exist-db.org/xquery/html-templating";
import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace mail="http://exist-db.org/xquery/mail";

declare
%templates:wrap
function app:sendFeedback($node as node(), $model as map(*)) {

let $name := request:get-parameter("name","")
let $email := request:get-parameter("email","")
let $feedback := request:get-parameter("feedback","")

let $mail-handle := mail:get-mail-session
  (
    <properties>
      <property name="mail.smtp.host" value="192.168.12.251"/>
      <property name="mail.smtp.port" value="25"/>
      <property name="mail.smtp.auth" value="false"/>
      <property name="mail.smtp.allow8bitmime" value="true"/>
    </properties>
)
  
let $message :=
  <mail>
    <from>{data($email)}</from>
    <to>arkisto@finlit.fi</to>
    <cc>maria.niku@finlit.fi</cc>
    <bcc>maria.niku@finlit.fi</bcc>
    <subject>Palautetta SKVR-tietokannasta</subject>
    <message>
      <text>{data($feedback)}</text>
      <xhtml>
           <html>
               <head>
                 <title>Palautetta SKVR-tietokannasta</title>
               </head>
               <body>
                  <p>{data($feedback)}</p>
               </body>
           </html>
      </xhtml>
    </message>
  </mail>

return
    <div id="thanks">
        <h1>Kiitos palautteesta!</h1>
        <p>{mail:send-email($mail-handle, $message)}</p>
        <p>Palautteesi:</p>
        <p>{data($name)}</p>
        <p>{data($email)}</p>
        <p>{data($feedback)}</p>
    </div>
};

(: Create a hierarchical menu from poem type taxonomy, create search links for bottom level categories (searches for category ids). :)
declare
    %templates:wrap
function app:listPoems($node as node(), $model as map(*)) {
    let $categories := doc("/db/apps/skvr/data/taksonomiataulu.xml")//tei:teiHeader//tei:taxonomy/tei:category
    return
        <ul id="poemTypes">
            {
                for $category in $categories
                return
                    <li>
                        <h3 class="mct" tabindex="0">{data($category/tei:catDesc[1])}</h3>
                        <ul class="mc">
                            {
                                for $subcategory in $category/tei:category
                                return
                                    if (empty($subcategory/tei:category)) then
                                    <li>
                                        <h4><a id="{$subcategory/@xml:id}" href="{concat('/exist/apps/skvr/haku.html?query=poemType%3A', '%23', $subcategory/@xml:id)}" target="_blank">{data($subcategory/tei:catDesc[1])}</a></h4>
                                        <span style="display:block;">{$subcategory/tei:catDesc[4]}</span>
                                    </li>
                                    else
                                    <li>
                                        <h4 class="sct" tabindex="0">{data($subcategory/tei:catDesc[1])}</h4>
                                        <ul class="sc">
                                            {
                                                for $subcategory2 in $subcategory/tei:category
                                                let $subcategories2 := $subcategory2/tei:category
                                                return
                                                    if (empty($subcategories2)) then
                                                        <li>
                                                            <h4><a id="{$subcategory2/@xml:id}" href="{concat('/exist/apps/skvr/haku.html?query=poemType%3A', '%23', $subcategory2/@xml:id)}" target="_blank">{data($subcategory2/tei:catDesc[1])}</a></h4>
                                                            <span style="display:block;">{data($subcategory2/tei:catDesc[2])}</span>
                                                            <span style="display:block;">{data($subcategory2/tei:catDesc[3])}</span>
                                                            <span style="display:block;">{data($subcategory2/tei:catDesc[4])}</span>
                                                        </li>    
                                                    else
                                                        <li>
                                                            <h4 class="ssct" tabindex="0">{data($subcategory2/tei:catDesc[1])}</h4>
                                                            <ul class="ssc">
                                                                {
                                                                    for $subcategory3 in $subcategories2
                                                                    return
                                                                        <li>
                                                                            <h4><a id="{$subcategory3/@xml:id}" href="{concat('/exist/apps/skvr/haku.html?query=poemType%3A', '%23', $subcategory3/@xml:id)}" target="_blank">{data($subcategory3/tei:catDesc[1])}</a></h4>
                                                                            <span style="display:block;">{data($subcategory2/tei:catDesc[2])}</span>
                                                                            <span style="display:block;">{data($subcategory3/tei:catDesc[3])}</span>
                                                                            <span style="display:block;">{data($subcategory3/tei:catDesc[4])}</span>
                                                                        </li>
                                                                }
                                                            </ul>
                                                        </li>    

                                            }
                                        </ul>
                                    </li>
                            }
                        </ul>
                    </li>
                
            }
        </ul>
};