xquery version "3.1";

import module namespace config="http://www.tei-c.org/tei-simple/config" at "/db/apps/skvr/modules/config.xqm";
declare option exist:serialize "expand-xincludes=no";
declare option exist:serialize "method=xml media-type=application/xml";

(: Search results: export data of search results as zipped XML files :)
(: Search result data contains only parent DIV of searched terms, so need to fetch documents from data root based on doc name :)
let $results := session:get-attribute($config:session-prefix || ".hits")
let $coll :=  session:get-attribute($config:session-prefix || ".coll")
let $collection := 
    for $result in $results
        let $doc := 
            if (contains(util:document-name($result), 'skvr')) then doc('/db/apps/skvr/data/main/' || util:document-name($result))
            else doc('/db/apps/skvr/data/jr/' || util:document-name($result))
        return $doc
let $entries := $collection ! 
    <entry name="{util:document-name(.)}" type="xml" method="store">{
        serialize(., map { "method": "xml" })
    }</entry>

let $zip := compression:zip($entries, false())
return
    response:stream-binary(
        $zip,
        'application/zip',
        'skvr.zip'
    )
            

