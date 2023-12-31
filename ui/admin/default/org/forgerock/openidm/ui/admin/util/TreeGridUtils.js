"use strict";

/*
 * Copyright 2011-2020 ForgeRock AS. All Rights Reserved
 *
 * Use of this code requires a commercial software license with ForgeRock AS.
 * or with one of its affiliates. All use shall be exclusively subject
 * to such license between the licensee and ForgeRock AS.
 */

define(["jquery", "underscore", "handlebars"], function ($, _, Handlebars) {

    var obj = {};

    /**
     * TreeGrid TODO:
     *
     * Write Tree Grid abstract view to handle events:
     *      expand
     *      collapse
     *      show/hide nodes
     *
     * Create a generic treegrid partial that works with this code
     */

    /**
     * Converts a collection to a Treegrid readable object.
     *
     * @example - Given the following arguments:
     *
     *  var pathKey = "filePath",
     *      leafProperties = ["filePath", "param"],
     *      data = [
     *          {"filePath": "node1/test1.js", "param1": "Test"},
     *          {"filePath": "node2/test2.js", "param1": "Test"},
     *          {"filePath": "node2/node3/test3.js", "param1": "Test"},
     *          {"filePath": "node2/node3/test4.js", "param1": "Test"}
     *      ];
     *
     *  This object will be generated:
     *  {
     *      "node1": {
     *          "___LEAF_NODE___": [
     *              [
     *                  "test1.js",
     *                  "Test"
     *              ]
     *          ]
     *      },
     *      "node2": {
     *          "node3": {
     *              "___LEAF_NODE___": [
     *                  [
     *                      "test3.js",
     *                      "Test"
     *                  ],
     *                  [
     *                      "test4.js",
     *                      "Test"
     *                  ]
     *              ]
     *          },
     *          "___LEAF_NODE___": [
     *              [
     *                  "test2.js",
     *                  "Test"
     *              ]
     *          ]
     *      }
     *  }
     *
     * @param {string} pathKey - The property name of the path in a given model
     * @param {collection} data - The backbone collection of data
     * @param {array} leafProperties - An array of properties, in column order, to display in treegrid
     * @returns {object} - and object formatted like that in the example
     */
    obj.filepathToTreegrid = function (pathKey, data, leafProperties) {
        var tempPath = [],
            tempRef = null,
            treeGrid = {},
            tempLeaf;

        _.forEach(data, function (obj) {

            if (_.startsWith(obj.filePath, "/")) {
                obj.filePath = obj.filePath.slice(1);
            }

            if (_.endsWith(obj.filePath, "/")) {
                obj.filePath = obj.filePath.slice(0, -1);
            }

            tempPath = obj.filePath.split("/");

            _.forEach(tempPath, function (location, index) {

                // This is the last section of the path
                if (tempPath.length - 1 === index) {
                    if (!_.has(tempRef, "___LEAF_NODE___")) {
                        if (_.isNull(tempRef)) {
                            tempRef = treeGrid;
                        }
                        tempRef.___LEAF_NODE___ = [];
                    }
                    obj[pathKey] = location;

                    // This ensure that if the properties are in a mixed order that they show up in the grid as anticipated
                    tempLeaf = [];
                    _.forEach(leafProperties, function (prop) {
                        if (_.has(obj, prop)) {
                            tempLeaf.push(obj[prop]);
                        } else {
                            tempLeaf.push("");
                        }
                    });

                    tempRef.___LEAF_NODE___.push(tempLeaf); // GET OTHER ATTRIBUTES
                    tempRef = null;

                    // This is a path folder
                } else if (_.isNull(tempRef)) {
                    if (!_.has(treeGrid, location)) {
                        treeGrid[location] = {};
                    }

                    tempRef = treeGrid[location];
                } else {
                    if (!_.has(tempRef, location)) {
                        tempRef[location] = {};
                    }

                    tempRef = tempRef[location];
                }
            });
        });

        return treeGrid;
    };

    /**
     * Given the context of the current node this helper will count how many leaf
     * nodes their are and return the value to be added as a badge.
     */
    Handlebars.registerHelper('getBadge', function (context) {
        var count = 0;
        function getCount(obj) {
            _.forEach(_.keys(obj), function (key) {
                if (_.isArray(obj[key]) && key === "___LEAF_NODE___") {
                    count += obj[key].length;
                } else if (_.isObject(obj[key])) {
                    getCount(obj[key]);
                }
            });
        }

        getCount(context);
        return count;
    });

    Handlebars.registerHelper("addPadding", function (num) {
        var space = "<span class='tree-spacer'></span>";

        _.times(num, function () {
            space += "<span class='tree-spacer'></span>";
        });

        return space;
    });

    Handlebars.registerHelper("unchanged", function (file) {
        if ($(file).text() === "Unchanged ") {
            return "";
        } else {
            return " changed";
        }
    });

    Handlebars.registerHelper("getDepth", function (num) {
        return num + 1;
    });

    return obj;
});
