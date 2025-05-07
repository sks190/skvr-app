xquery version "3.1";

module namespace idx="http://teipublisher.com/index";

declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace dbk="http://docbook.org/ns/docbook";

declare variable $idx:app-root :=
    let $rawPath := system:get-module-load-path()
    return
        (: strip the xmldb: part :)
        if (starts-with($rawPath, "xmldb:exist://")) then
            if (starts-with($rawPath, "xmldb:exist://embedded-eXist-server")) then
                substring($rawPath, 36)
            else
                substring($rawPath, 15)
        else
            $rawPath
    ;

(:~
 : Helper function called from collection.xconf to create index fields and facets.
 : This module needs to be loaded before collection.xconf starts indexing documents
 : and therefore should reside in the root of the app.
 :)
declare function idx:get-metadata($root as element(), $field as xs:string) {
    let $header := $root/tei:teiHeader
    return
        switch ($field)
            case "title" return
                string-join((
                    $header//tei:msDesc/tei:head, $header//tei:titleStmt/tei:title[@type = 'main'],
                    $header//tei:titleStmt/tei:title,
                    $root/dbk:info/dbk:title
                ), " - ")
            case "collector" return $header//tei:persName[@type="standardized"]
            case "dateSt" return $header//tei:date[@type="standardized"]
            case "dateNst" return $header//tei:date[@type="non_standardized"]/@when
            case "collRegion" return $header//tei:region
            case "collPlace" return $header//tei:settlement[@type="standardized_municipality"]
            case "village" return $header//tei:settlement[@type="non_standardized"]            
            case "informant" return $header//tei:msContents/tei:msItem 
            case "idno" return $header//tei:msIdentifier/tei:idno[@type="nro"]
            case "sgn" return $header//tei:msIdentifier/tei:idno[@type="sgn"]            
            case "part" return $header//tei:msIdentifier/tei:collection
            case "number" return $header//tei:msIdentifier/tei:idno[@type="id"]
            case "desc" return $header//tei:msContents/tei:msItem
            case "poemType" return $header//tei:catRef/@target
            case "poemTypeDesc" return $header//tei:catDesc[matches(@xml:id, 'title_1')]
            case "genre" return idx:get-genre($header)
            default return
                ()
};

declare function idx:get-genre($header as element()?) {
    array:for-each(array {$header//tei:textClass/tei:catRef[@scheme]/@target}, function($target) {
        id(substring($target, 2), doc($idx:app-root || "/data/taksonomiataulu.xml"))/ancestor-or-self::tei:category/tei:catDesc[1]
    })
};



