(:
 :
 :  Copyright (C) 2017 Wolfgang Meier
 :
 :  This program is free software: you can redistribute it and/or modify
 :  it under the terms of the GNU General Public License as published by
 :  the Free Software Foundation, either version 3 of the License, or
 :  (at your option) any later version.
 :
 :  This program is distributed in the hope that it will be useful,
 :  but WITHOUT ANY WARRANTY; without even the implied warranty of
 :  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 :  GNU General Public License for more details.
 :
 :  You should have received a copy of the GNU General Public License
 :  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 :)
xquery version "3.1";

module namespace teis="http://www.tei-c.org/tei-simple/query/tei";

declare namespace tei="http://www.tei-c.org/ns/1.0";

import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";
import module namespace nav="http://www.tei-c.org/tei-simple/navigation/tei" at "navigation-tei.xql";
import module namespace query="http://www.tei-c.org/tei-simple/query" at "query.xql";

declare function teis:query-default($coll as xs:string*, $fields as xs:string+, $query as xs:string, $target-texts as xs:string*,
    $sortBy as xs:string*) {
    if(string($query)) then
        for $field in $fields
        return
            switch ($field)
                case "fullText" return
                    if (exists($target-texts)) then
                        for $text in $target-texts
                        return
                            $config:data-root ! doc(. || "/" || $coll || "/" || $text)//tei:div[@type="normalized_text"][ft:query(., $query, query:options($sortBy))]
                    else
                        collection($config:data-root || "/" || $coll)//tei:div[@type="normalized_text"][ft:query(., $query, query:options($sortBy))]
                case "head" return
                    if (exists($target-texts)) then
                        for $text in $target-texts
                        return
                            $config:data-root ! doc(. || "/" || $text)//tei:head[ft:query(., $query, query:options($sortBy))]
                    else
                        collection($config:data-root)//tei:head[ft:query(., $query, query:options($sortBy))]
                case "lines" return
                    if (exists($target-texts)) then
                        for $text in $target-texts
                        return
                            $config:data-root ! doc(. || "/" || $coll || "/" || $text)//tei:div[@type="normalized_text"]/tei:l[ft:query(., $query, query:options($sortBy))]
                    else
                        collection($config:data-root || "/" || $coll)//tei:div[@type="normalized_text"]/tei:l[ft:query(., '#' || $query, query:options($sortBy))] 
                case "poemThemes" return
                    if (exists($target-texts)) then
                        for $text in $target-texts
                        return
                            $config:data-root ! doc(. || "/main/" || $text)//tei:catRef/@target[ft:query(., $query, query:options($sortBy))]
                    else
                        collection($config:data-root)//tei:catRef/@target[ft:query(., $query, query:options($sortBy))] 
                case "themes" return
                    for $result in doc($config:data-root || '/taksonomiataulu.xml')//tei:catDesc[matches(@xml:id,'title_1')][ft:query(., $query)]/parent::tei:category/@xml:id
                    return
                        collection($config:data-root || '/main/')//tei:catRef/@target[ft:query(.,  '#' || $result, query:options($sortBy))]
                case "esipuheet" return
                    if (exists($target-texts)) then
                        for $text in $target-texts
                        return
                            $config:esipuheet ! doc(. || "/" || $text)//tei:div[ft:query(., $query, query:options($sortBy))] |
                            $config:esipuheet ! doc(. || "/" || $text)//tei:text[ft:query(., $query, query:options($sortBy))]
                    else
                        collection($config:esipuheet)//tei:div[ft:query(., $query, query:options($sortBy))] |
                        collection($config:esipuheet)//tei:text[ft:query(., $query, query:options($sortBy))] 
                case "collector" return
                    if (exists($target-texts)) then
                        for $text in $target-texts
                        return
                            $config:data-root ! doc(. || "/" || $coll || "/" || $text)//tei:person[ft:query(., $query, query:options($sortBy))]
                    else
                        collection($config:data-root || "/" || $coll)//tei:person[ft:query(., $query, query:options($sortBy))]  
                case "collPlace" return
                    if (exists($target-texts)) then
                        for $text in $target-texts
                        return
                            $config:data-root ! (. || "/" || $coll)//tei:settlement[ft:query(., $query, query:options($sortBy))]
                    else
                        collection($config:data-root || "/" || $coll)//tei:settlement[ft:query(., $query, query:options($sortBy))]  
                case "collRegion" return
                    if (exists($target-texts)) then
                        for $text in $target-texts
                        return
                           $config:data-root ! doc(. || "/" || $coll || "/" || $text)//tei:region[ft:query(., $query, query:options($sortBy))]
                    else
                        collection($config:data-root || "/" || $coll)//tei:region[ft:query(., $query, query:options($sortBy))]     
                case "dateSt" return
                    if (exists($target-texts)) then
                        for $text in $target-texts
                        return
                            $config:data-root ! doc(. || "/" || $coll || "/" || $text)//tei:date[@type="standardized"][ft:query(., $query, query:options($sortBy))]
                    else
                        collection($config:data-root || "/" || $coll)//tei:date[@type="standardized"][ft:query(., $query, query:options($sortBy))]                          
                case "informant" return
                    if (exists($target-texts)) then
                        for $text in $target-texts
                        return
                            $config:data-root ! doc(. || "/" || $coll || "/" || $text)//tei:msItem[ft:query(., $query, query:options($sortBy))]
                    else
                        collection($config:data-root || "/" || $coll)//tei:msItem[ft:query(., $query, query:options($sortBy))] 
                case "dateNst" return
                    if (exists($target-texts)) then
                        for $text in $target-texts
                        return
                            $config:data-root ! doc(. || "/" || $coll || "/" || $text)//tei:date[@type='non_standardized']/@when[ft:query(., $query, query:options($sortBy))]
                    else
                        collection($config:data-root || "/" || $coll)//tei:date[@type='non_standardized']/@when[ft:query(., $query, query:options($sortBy))]                        
                default return
                    if (exists($target-texts)) then
                        for $text in $target-texts
                        return
                            $config:data-root ! doc(. || "/" || $text)//tei:div[ft:query(., $query, query:options($sortBy))] |
                            $config:data-root ! doc(. || "/" || $text)//tei:text[ft:query(., $query, query:options($sortBy))]
                    else
                        collection($config:data-root || "/" || $coll)//tei:div[ft:query(., $query, query:options($sortBy))] |
                        collection($config:data-root || "/" || $coll)//tei:text[ft:query(., $query, query:options($sortBy))]
                        
    else ()
};

declare function teis:query-metadata($path as xs:string?, $field as xs:string, $query as xs:string, $sort as xs:string) {
    for $rootCol in $config:data-root
    for $doc in collection($config:data-root || '/' || $path)//tei:text[ft:query(., $field || ":(" || $query || ")", query:options($sort))]
    return
        $doc/ancestor::tei:TEI
};

declare function teis:autocomplete($doc as xs:string?, $fields as xs:string+, $q as xs:string) {
    let $lower-case-q := lower-case($q)
    for $field in $fields
    return
        switch ($field)
            case "themes" return
                collection($config:data-root)/ft:index-keys-for-field("poemTypeDesc", $lower-case-q,
                    function($key, $count) {
                        $key
                    }, 30)             
            case "collector" return
                collection($config:data-root)/ft:index-keys-for-field("collector", $lower-case-q,
                    function($key, $count) {
                        $key
                    }, 30)     
            case "collPlace" return
                collection($config:data-root)/ft:index-keys-for-field("collPlace", $lower-case-q,
                    function($key, $count) {
                        $key
                    }, 30) 
            case "collRegion" return
                collection($config:data-root)/ft:index-keys-for-field("collRegion", $lower-case-q,
                    function($key, $count) {
                        $key
                    }, 30)            
            case "informant" return
                    collection($config:data-root)/ft:index-keys-for-field("informant", $lower-case-q,
                    function($key, $count) {
                        $key
                    }, 30)                          
            case "file" return
                collection($config:data-root)/ft:index-keys-for-field("file", $lower-case-q,
                    function($key, $count) {
                        $key
                    }, 30)
            case "lines" return
                if ($doc) then (
                    doc($config:data-root || "/" || $doc)/util:index-keys-by-qname(xs:QName("tei:l"), $lower-case-q,
                        function($key, $count) {
                            $key
                        }, 30, "lucene-index")
                ) else (
                    collection($config:data-root)/util:index-keys-by-qname(xs:QName("tei:l"), $lower-case-q,
                        function($key, $count) {
                            $key
                        }, 30, "lucene-index")
                )
            case "themes" return
                    collection($config:data-root)/ft:index-keys-for-field("poemTypeDesc", $lower-case-q,
                    function($key, $count) {
                        $key
                    }, 30)                          
            case "fullText" return
                if ($doc) then (
                    doc($config:data-root || "/" || $doc)/util:index-keys-by-qname(xs:QName("tei:div"), $lower-case-q,
                        function($key, $count) {
                            $key
                        }, 30, "lucene-index")
                ) else (
                    collection($config:data-root)/util:index-keys-by-qname(xs:QName("tei:div"), $lower-case-q,
                        function($key, $count) {
                            $key
                        }, 30, "lucene-index")
                )
            case "head" return
                if ($doc) then
                    doc($config:data-root || "/" || $doc)/util:index-keys-by-qname(xs:QName("tei:head"), $lower-case-q,
                        function($key, $count) {
                            $key
                        }, 30, "lucene-index")
                else
                    collection($config:data-root)/util:index-keys-by-qname(xs:QName("tei:head"), $lower-case-q,
                        function($key, $count) {
                            $key
                        }, 30, "lucene-index")
            default return
                collection($config:data-root)/ft:index-keys-for-field("title", $lower-case-q,
                    function($key, $count) {
                        $key
                    }, 30)
};

declare function teis:get-parent-section($node as node()) {
    ($node/self::tei:text, $node/ancestor-or-self::tei:div[1], $node)[1]
};

declare function teis:get-breadcrumbs($config as map(*), $hit as node(), $parent-id as xs:string) {
    let $field := session:get-attribute($config:session-prefix || ".field")    
    let $work := root($hit)/*
    let $work-title := nav:get-document-title($config, $work)/string()
    let $part := if ($work//tei:msIdentifier/tei:collection) then concat('SKVR ', $work//tei:msIdentifier/tei:collection) else 'JR'
    let $number := $work//tei:msIdentifier/tei:idno[@type="id"]
    let $place := $work//tei:settlement[@type="standardized_municipality"]
    let $collector := $work//tei:persName[@type="standardized"]/tei:name
    let $signum := $work//tei:msIdentifier/tei:idno[@type="sgn"]
    let $date := $work//tei:date[@type="standardized"]
    let $themes := if ($field = 'themes') then
        doc($config:data-root || '/taksonomiataulu.xml')//tei:category[@xml:id = substring-after($hit, '#')]/ancestor-or-self::tei:category/tei:catDesc[1] else ()
    return
        if ($work//tei:div[@type="normalized_text"] or $work//tei:div[@type="references"]) then
        <div class="breadcrumbs">
            <span class="part">{$part}</span>
            <a class="breadcrumb" href="{$parent-id}">{$number}</a>
            <span class="place">{$place}</span> <span class="collector">{$collector}</span> <span class="signum">{$signum}</span> <span class="date">{$date}</span>
        <br/>
        <p style="font-size:14px;">{string-join($themes, ' > ')}</p>
        </div>
        
        else 
       <div class="breadcrumbs">
            <a class="breadcrumb2" href="{$parent-id}">{$work-title}</a>
        </div>
};

(:~
 : Expand the given element and highlight query matches by re-running the query
 : on it.
 :)
declare function teis:expand($data as node()) {
    let $query := session:get-attribute($config:session-prefix || ".query")
    let $field := session:get-attribute($config:session-prefix || ".field")
    let $div :=
        if ($data instance of element(tei:pb)) then
            let $nextPage := $data/following::tei:pb[1]
            return
                if ($nextPage) then
                    if ($field = "text") then
                        (
                            ($data/ancestor::tei:div intersect $nextPage/ancestor::tei:div)[last()],
                            $data/ancestor::tei:text
                        )[1]
                    else
                        $data/ancestor::tei:text
                else
                    (: if there's only one pb in the document, it's whole
                      text part should be returned :)
                    if (count($data/ancestor::tei:text//tei:pb) = 1) then
                        ($data/ancestor::tei:text)
                    else
                      ($data/ancestor::tei:div, $data/ancestor::tei:text)[1]
        else
            $data
    let $result := teis:query-default-view($div, $query, $field)
    let $expanded :=
        if (exists($result)) then
            util:expand($result, "add-exist-id=all")
        else
            $div
    return
        if ($data instance of element(tei:pb)) then
            $expanded//tei:pb[@exist:id = util:node-id($data)]
        else
            $expanded
};


declare %private function teis:query-default-view($context as element()*, $query as xs:string, $fields as xs:string+) {
    for $field in $fields
    return
        switch ($field)
            case "fullText" return
                $context[./descendant-or-self::tei:div[@type="normalized_text"][ft:query(., $query, $query:QUERY_OPTIONS)]]
            case "head" return
                $context[./descendant-or-self::tei:head[ft:query(., $query, $query:QUERY_OPTIONS)]]
            default return
                $context[./descendant-or-self::tei:div[@type="normalized_text"][ft:query(., $query, $query:QUERY_OPTIONS)]]
};

declare function teis:get-current($config as map(*), $div as node()?) {
    if (empty($div)) then
        ()
    else
        if ($div instance of element(tei:teiHeader)) then
            $div
        else
            (nav:filler($config, $div), $div)[1]
};
