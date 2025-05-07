xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace config="http://www.tei-c.org/tei-simple/config" at "/db/apps/skvr/modules/config.xqm";
declare option exist:serialize "method=text media-type=text/csv";

(: Search results: export data of search results as CSV :)
let $csv := "skvr.csv"
(: Search result data contains only parent DIV of searched terms, so need to fetch documents from data root based on doc name :)
let $results := session:get-attribute($config:session-prefix || ".hits")
let $query := session:get-attribute($config:session-prefix || ".query")
let $entries :=
    for $result in $results
        let $expanded := util:expand($result, "add-exist-id=all")
        let $name := util:document-name($result)
        let $coll := if (contains($name, 'skvr')) then 'main' else 'jr'
        let $id := doc('/db/apps/skvr/data/' || $coll || '/' || $name)//tei:idno[@type="nro"]
        let $part := doc('/db/apps/skvr/data/' || $coll || '/' || $name)//tei:collection
        let $number := doc('/db/apps/skvr/data/' || $coll || '/' || $name)//tei:idno[@type="id"]
        let $signum := concat('"', doc('/db/apps/skvr/data/' || $coll || '/' || $name)//tei:idno[@type="sgn"], '"')
        let $collector := concat('"', doc('/db/apps/skvr/data/' || $coll || '/' || $name)//tei:persName[@type="standardized"]/tei:name, '"')
        let $informant := concat('"',doc('/db/apps/skvr/data/' || $coll || '/' || $name)//tei:msContents//tei:msItem, '"') 
        let $collArea := string-join(doc('/db/apps/skvr/data/' || $coll || '/' || $name)//tei:region[@type="standardized"], ',')
        let $collPlace := string-join(doc('/db/apps/skvr/data/' || $coll || '/' || $name)//tei:settlement[@type="standardized_municipality"], ',')
        let $matches := subsequence($expanded//exist:match, 1, 300)
        let $collDate := doc('/db/apps/skvr/data/' || $coll || '/' || $name)//tei:date[@type="standardized"]
        for $match in $matches
            let $repl := replace($expanded, '"', '""')
            let $matchId := $match/../@exist:id
            let $contextNode := replace(util:node-by-id($result, $matchId), '"', '""')
            return concat($id, ',', $part, ',', $number, ',', $signum, ',', $collector, ',', $informant, ',', $collArea, ',', $collPlace, ',', $collDate, ',', $match, ',"', $contextNode, '"')
return 
    response:stream-binary(util:string-to-binary(concat('HAKU: ', ',', upper-case($query), '&#10;&#10;', 'Tunnus, Osa, Numero, Signum, Kerääjä, Tiedonantaja, "Keräysalue (normalisoitu)", "Keräyspaikka (normalisoitu)", Keräysaika, Hakutulos, Säe', '&#10;', string-join($entries, '&#10;')),'UTF-8'),'text/csv',$csv)
            

