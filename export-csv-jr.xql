xquery version "3.1";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace config="http://www.tei-c.org/tei-simple/config" at "/db/apps/skvr/modules/config.xqm";
declare option exist:serialize "method=text media-type=text/csv";

(: Database document listing: export data of unfiltered or filtered results as CSV :)
let $csv := "jr.csv"
let $results := session:get-attribute($config:session-prefix || ".works")
let $entries :=
    for $result in $results
        order by util:document-name($result)
        return 
            concat(
                data($result//tei:idno[@type="nro"]), ',', 
                data($result//tei:idno[@type="id"]), ',', 
                concat('"', data($result//tei:idno[@type="sgn"]), '",'),
                concat('"', data($result//tei:persName[@type="standardized"]/tei:name), '",'),
                concat('"',data($result//tei:msContents), '",'), 
                concat('"', string-join(data($result//tei:region[@type="standardized"]), ','), '",'),
                concat('"', string-join(data($result//tei:settlement[@type="standardized_municipality"]), ','), '",'),
                data($result//tei:date[@type="standardized"])
            )
return 
    response:stream-binary(util:string-to-binary(concat('Tunnus, Numero, Signum, Kerääjä, Tiedonantaja, "Keräysalue (normalisoitu)", "Keräyspaikka (normalisoitu)", Keräysaika', '&#10;', string-join($entries, '&#10;')),'UTF-8'),'text/csv',$csv)
            

