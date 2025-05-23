(:
 :
 :  Copyright (C) 2019 Wolfgang Meier
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

module namespace facets="http://teipublisher.com/facets";

import module namespace config="http://www.tei-c.org/tei-simple/config" at "config.xqm";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function facets:sort($config as map(*), $lang as xs:string?, $facets as map(*)?) {
    array {
        if (exists($facets)) then
            for $key in map:keys($facets)
            let $value := map:get($facets, $key)
            let $sortKey := facets:translate($config, $lang, $key)
            order by $sortKey collation "http://www.w3.org/2013/collation/UCA?numeric=yes;lang=fi"
            return
                map { $key: $value }
        else
            ()
    }
};

declare function facets:print-table($config as map(*), $nodes as node()+, $values as xs:string*, $params as xs:string*) {
    let $all := exists($config?max) and facets:get-parameter("all-" || $config?dimension)
    let $lang := tokenize(facets:get-parameter("language"), '-')[1]
    let $count := if ($all) then 50 else $config?max
    let $facets :=
        if (exists($values)) then
            ft:facets($nodes, $config?dimension, $count, $values)
        else
            ft:facets($nodes, $config?dimension, $count)
    return
        if (map:size($facets) > 0) then
            <table>
            {
                array:for-each(facets:sort($config, $lang, $facets), function($entry) {
                    map:for-each($entry, function($label, $freq) {
                        let $content := facets:translate($config, $lang, $label)
                        return
                        <tr>
                            <td>
                                <paper-checkbox class="facet" name="facet-{$config?dimension}" value="{$label}">
                                    { if ($label = $params) then attribute checked { "checked" } else () }
                                    <pb-i18n key="{$content}">{$content}</pb-i18n>
                                </paper-checkbox>
                            </td>
                            <td>{if ($config?dimension != 'number') then $freq else ()}</td>
                        </tr>,
                        if (empty($params)) then
                            ()
                        else
                            let $nested := facets:print-table($config, $nodes, ($values, head($params)), tail($params))
                            return
                                if ($nested and head($params) eq $label) then
                                    <tr class="nested">
                                        <td colspan="2">
                                        {$nested}
                                        </td>
                                    </tr>
                                else
                                    ()
                    })
                })
            }
            </table>
        else
            ()
};

declare function facets:display($config as map(*), $nodes as node()+) {
    let $params := facets:get-parameter("facet-" || $config?dimension)
    let $lang := tokenize(facets:get-parameter("language"), '-')[1]
    let $table := facets:print-table($config, $nodes, (), $params)

    let $maxcount := 50
    (: maximum number shown :)
    let $max := head(($config?max, 50))

    (: facet count for current values selected :)
    let $fcount :=
        map:size(
            if (count($params)) then
                    ft:facets($nodes, $config?dimension, $maxcount, $params)
                else
                    ft:facets($nodes, $config?dimension, $maxcount)
        )

    where $table
    return (
        <div class="facet-dimension" data-dimension="facet-{$config?dimension}">
            <h3><pb-i18n key="{$config?heading}">{$config?heading}</pb-i18n>
            </h3>
            <span>
                {
                    if ($config?dimension != 'genre') then
                        <paper-icon-button class="submitFacets" id="{$config?dimension}" title="Päivitä fasettivalinnat" icon="icons:update" onclick="facets.submit()"/>
                    else
                        ()
                }
            </span>
            {
                (: if config specifies a property "source", output combo-box :)
                if (map:contains($config, "source")) then
                    (: use source as URL to API endpoint from which to retrieve possible values :)
                    if ($config?dimension eq 'number') then
                    <pb-combo-box source="{$config?source}" close-after-select="" placeholder="{$config?heading}">
                        <select multiple="" name="facet-number">
                        {
                            for $param in facets:get-parameter("facet-" || $config?dimension)
                            let $label := facets:translate($config, $lang, $param)
                            return
                                <option value="{$param}" data-i18n="{$label}" selected="">{$label}</option>
                        }
                        </select>
                    </pb-combo-box>
                    else
                    <pb-combo-box source="{$config?source}" close-after-select="" placeholder="{$config?heading}">
                        <select multiple="">
                        {
                            for $param in facets:get-parameter("facet-" || $config?dimension)
                            let $label := facets:translate($config, $lang, $param)
                            return
                                <option value="{$param}" data-i18n="{$label}" selected="">{$label}</option>
                        }
                        </select>
                    </pb-combo-box>                        
                else
                    (),
                if ($config?dimension eq 'number') then
                    ()
                else
                <div class="frame">{$table}</div>

            }
        </div>
    )
};

declare function facets:get-parameter($name as xs:string) {
    let $param := request:get-parameter($name, ())
    return
        if (exists($param)) then
            $param
        else
            (:   :let $fromSession := session:get-attribute($config:session-prefix || '.params') :)
            (:  : return :) 
                (:   :if (exists($fromSession)) then :)
                    (:   :$fromSession?($name) :)
                (:   :else :)
                    ()
};

declare function facets:translate($config as map(*)?, $language as xs:string?, $label as xs:string) {
    if (exists($config) and map:contains($config, "output")) then
        let $fn := $config?output
        return
            if (function-arity($fn) = 2) then
                $fn($label, $language)
            else
                $fn($label)
    else
        $label
};