"use strict";

/*
 * Copyright 2015-2022 ForgeRock AS. All Rights Reserved
 *
 * Use of this code requires a commercial software license with ForgeRock AS.
 * or with one of its affiliates. All use shall be exclusively subject
 * to such license between the licensee and ForgeRock AS.
 */

define(["jquery", "underscore", "org/forgerock/commons/ui/common/main/Configuration", "org/forgerock/commons/ui/common/util/Constants", "org/forgerock/commons/ui/common/main/AbstractDelegate"], function ($, _, conf, Constants, AbstractDelegate) {

    var obj = new AbstractDelegate(Constants.host + Constants.context + "");

    obj.searchResults = function (resource, props, searchString, comparisonOperator, additionalQuery) {
        var maxPageSize = 10,
            queryFilter = additionalQuery,
            queryThreshold = null,
            url = "/" + resource + "?_pageSize=" + maxPageSize;

        if (resource.startsWith("managed/") && _.has(conf.globalData, "platformSettings.managedObjectsSettings." + resource.split("/")[1] + ".minimumUIFilterLength")) {
            queryThreshold = conf.globalData.platformSettings.managedObjectsSettings[resource.split("/")[1]].minimumUIFilterLength;
        }

        if (searchString.length) {
            queryFilter = obj.generateQueryFilter(props, searchString, additionalQuery, comparisonOperator); // [a,b] => "a or (b)"; [a,b,c] => "a or (b or (c))"
        }

        if (queryFilter === undefined) {
            queryFilter = "true";
        }
        // add queryFilter to url
        url = url + "&_queryFilter=" + queryFilter;

        if (queryThreshold && queryFilter === "true") {
            // do not add sort keys
        } else {
            url = url + "&_sortKeys=" + props[0];
        }

        if (!queryThreshold || queryThreshold && queryFilter === "true" || queryThreshold && searchString.length >= queryThreshold) {
            return this.serviceCall({
                "type": "GET",
                "url": url
            }).then(function (qry) {
                return _.take(qry.result, maxPageSize); //we never want more than 10 results from search in case _pageSize does not work
            }, function (error) {
                console.error(error);
            });
        } else {
            return $.Deferred().resolve({ result: [] });
        }
    };

    obj.generateQueryFilter = function (props, searchString, additionalQuery, comparisonOperator) {
        var operator = comparisonOperator ? comparisonOperator : "sw",
            queryFilter,
            conditions = _(props).reject(function (p) {
            return !p;
        }).map(function (p) {
            var op = operator;

            if (p === "_id" && op !== "neq") {
                op = "eq";
            }

            if (op !== "pr") {
                return p + ' ' + op + ' "' + encodeURIComponent(searchString) + '"';
            } else {
                return p + ' pr';
            }
        }).value();

        queryFilter = "(" + conditions.join(" or (") + new Array(conditions.length).join(")") + ")";

        if (additionalQuery) {
            queryFilter = "(" + queryFilter + " and (" + additionalQuery + "))";
        }

        return queryFilter;
    };

    return obj;
});
