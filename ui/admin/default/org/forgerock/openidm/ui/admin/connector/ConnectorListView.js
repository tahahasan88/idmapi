"use strict";

/*
 * Copyright 2015-2020 ForgeRock AS. All Rights Reserved
 *
 * Use of this code requires a commercial software license with ForgeRock AS.
 * or with one of its affiliates. All use shall be exclusively subject
 * to such license between the licensee and ForgeRock AS.
 */

define(["jquery", "underscore", "backbone", "bootstrap", "org/forgerock/openidm/ui/admin/util/AdminAbstractView", "org/forgerock/commons/ui/common/main/EventManager", "org/forgerock/commons/ui/common/util/Constants", "org/forgerock/commons/ui/common/main/Router", "org/forgerock/openidm/ui/admin/delegates/ConnectorDelegate", "org/forgerock/openidm/ui/admin/util/ConnectorUtils", "org/forgerock/openidm/ui/common/delegates/ConfigDelegate", "backgrid", "org/forgerock/openidm/ui/common/util/BackgridUtils"], function ($, _, Backbone, bootstrap, AdminAbstractView, eventManager, constants, router, ConnectorDelegate, connectorUtils, ConfigDelegate, Backgrid, BackgridUtils) {
    var ConnectorListView = AdminAbstractView.extend({
        template: "templates/admin/connector/ConnectorListViewTemplate.html",
        events: {
            "click .connector-delete": "deleteConnections",
            "click .toggle-view-btn": "toggleButtonChange",
            "keyup .filter-input": "filterConnectors",
            "paste .filter-input": "filterConnectors"
        },
        model: {},
        render: function render(args, callback) {
            var connectorPromise,
                splitConfig,
                ConnectorModel = Backbone.Model.extend({}),
                Connectors = Backbone.Collection.extend({ model: ConnectorModel }),
                connectorGrid,
                RenderRow = null,
                _this = this;

            RenderRow = Backgrid.Row.extend({
                render: function render() {
                    RenderRow.__super__.render.apply(this, arguments);

                    this.$el.attr('data-name', this.model.attributes.name);
                    this.$el.attr('data-type', this.model.attributes.displayName);
                    this.$el.attr('data-connector-title', this.model.attributes.cleanUrlName);

                    return this;
                }
            });

            this.data.docHelpUrl = constants.DOC_URL;
            this.model.connectorCollection = new Connectors();

            connectorPromise = ConnectorDelegate.currentConnectors();

            $.when(connectorPromise).then(_.bind(function (connectors) {
                _.forEach(connectors, _.bind(function (connector) {
                    var tempIconClass = connectorUtils.getIcon(connector.connectorRef.connectorName);

                    connector.iconClass = tempIconClass.iconClass;
                    connector.iconSrc = tempIconClass.src;

                    splitConfig = connector.config.split("/");

                    connector.cleanUrlName = splitConfig[1] + "_" + splitConfig[2];
                    connector.cleanEditName = splitConfig[2];

                    //remove the __ALL__ objectType
                    connector.objectTypes = _.reject(connector.objectTypes, function (ot) {
                        return ot === "__ALL__";
                    });

                    connector.displayData = this.versionCheck(connector.connectorRef.bundleVersion);

                    //remove data links from connector toggle
                    this.pruneObjectTypes.bind(this, connector);

                    this.model.connectorCollection.add(connector);
                }, this));

                this.data.currentConnectors = connectors;

                this.parentRender(_.bind(function () {
                    connectorGrid = new Backgrid.Grid({
                        className: "table backgrid",
                        emptyText: $.t("templates.connector.noResourceTitle"),
                        row: RenderRow,
                        columns: BackgridUtils.addSmallScreenCell([{
                            name: "source",
                            sortable: false,
                            editable: false,
                            cell: Backgrid.Cell.extend({
                                render: function render() {
                                    var display = '<a class="table-clink" href="#connectors/edit/' + this.model.attributes.cleanUrlName + '/"><div class="image circle">' + '<i class="' + this.model.attributes.iconClass + '"></i></div>' + this.model.attributes.name + '</a>';

                                    this.$el.html(display);

                                    return this;
                                }
                            })
                        }, {
                            name: "displayName",
                            label: "type",
                            cell: "string",
                            sortable: false,
                            editable: false
                        }, {
                            name: "",
                            sortable: false,
                            editable: false,
                            cell: Backgrid.Cell.extend({
                                className: "button-right-align",
                                render: function render() {
                                    var display = $('<div class="btn-group"><button type="button" class="btn btn-link fa-lg dropdown-toggle" data-toggle="dropdown" aria-expanded="false">' + '<i class="fa fa-ellipsis-v"></i>' + '</button></div>');

                                    $(display).append(_this.$el.find("[data-connector-title='" + this.model.attributes.cleanUrlName + "'] .dropdown-menu").clone());

                                    this.$el.html(display);

                                    return this;
                                }
                            })
                        }]),
                        collection: this.model.connectorCollection
                    });

                    this.$el.find("#connectorGrid").append(connectorGrid.render().el);

                    if (this.$el.find(".resource-unavailable").length !== 0) {
                        this.$el.find(".resource-unavailable").popover({
                            content: function content() {
                                return '<span class="text-danger">' + $(this).attr("data-title") + '</span>';
                            },
                            placement: 'top',
                            container: 'body',
                            html: 'true',
                            title: ''
                        });
                    }

                    if (this.$el.find(".resource-disabled").length !== 0) {
                        this.$el.find(".resource-disabled").popover({
                            content: function content() {
                                return '<span class="text-warning">' + $(this).attr("data-title") + '</span>';
                            },
                            placement: 'top',
                            container: 'body',
                            html: 'true',
                            title: ''
                        });
                    }

                    if (callback) {
                        callback();
                    }
                }, this));
            }, this));
        },

        pruneObjectTypes: function pruneObjectTypes(connector) {
            if (!connector.ok) {
                connector.objectTypes = [];
            }
            return connector;
        },

        /**
         * Checks the current version to ensure proper ICF support exists for resource view to properly work.
         *
         * @param {string} version - Takes both a range and normal version string to be checked
         */
        versionCheck: function versionCheck(version) {
            if (version.indexOf("(") !== -1 || version.indexOf(")") !== -1 || version.indexOf("[") !== -1 || version.indexOf("]") !== -1) {
                version = version.replace(/\[|\)|\(|\]/g, '');
                version = version.split(",");
                version = version[0].split(".");
                version = version[0] + "." + version[1];
            } else {
                version = version.split(".");
                version = version[0] + "." + version[1];
            }

            if (version >= 1.4) {
                return true;
            } else {
                return false;
            }
        },

        deleteConnections: function deleteConnections(event) {
            var _this2 = this;

            var selectedItem = $(event.currentTarget).parents(".card-spacer"),
                alternateItem,
                tempConnector = _.clone(this.data.currentConnectors),
                connectorPath,
                connectorName,
                connectorIndex;

            if (selectedItem.length > 0) {
                _.forEach(this.$el.find(".backgrid tbody tr"), function (row) {
                    if ($(row).attr("data-connector-title") === selectedItem.attr("data-connector-title")) {
                        alternateItem = $(row);
                    }
                });
            } else {
                selectedItem = $(event.currentTarget).parents("tr");

                _.forEach(this.$el.find(".card-spacer"), function (card) {
                    if ($(card).attr("data-connector-title") === selectedItem.attr("data-connector-title")) {
                        alternateItem = $(card);
                    }
                });
            }

            _.forEach(tempConnector, _.bind(function (connectorObject, index) {
                if (connectorObject.cleanUrlName === selectedItem.attr("data-connector-title")) {
                    connectorPath = this.data.currentConnectors[index].config;
                    connectorName = this.data.currentConnectors[index].name;
                    connectorIndex = index;
                }
            }, this));

            connectorUtils.deleteConnector(connectorName, connectorPath, function () {
                _this2.data.currentConnectors.splice(connectorIndex, 1);
                selectedItem.remove();
                alternateItem.remove();

                if (_this2.$el.find(".backgrid tbody tr").length === 0) {
                    _this2.$el.find(".fr-resource-list .tab-content").hide();
                    _this2.$el.find(".section-help").hide();
                    _this2.$el.find(".page-toolbar").hide();
                    _this2.$el.find(".no-resource").show();
                }
            });
        },

        toggleButtonChange: function toggleButtonChange(event) {
            var target = $(event.target);

            if (target.hasClass("fa")) {
                target = target.parents(".btn");
            }

            this.$el.find(".toggle-view-btn").toggleClass("active", false);
            target.toggleClass("active", true);
        },

        filterConnectors: function filterConnectors(event) {
            var search = $(event.target).val().toLowerCase();

            if (search.length > 0) {
                _.forEach(this.$el.find(".card-spacer"), _.bind(function (card) {
                    if ($(card).attr("data-type").toLowerCase().indexOf(search) > -1 || $(card).attr("data-name").toLowerCase().indexOf(search) > -1) {
                        $(card).fadeIn();
                    } else {
                        $(card).fadeOut();
                    }
                }, this));

                _.forEach(this.$el.find(".backgrid tbody tr"), _.bind(function (row) {
                    if ($(row).attr("data-type").toLowerCase().indexOf(search) > -1 || $(row).attr("data-name").toLowerCase().indexOf(search) > -1) {
                        $(row).fadeIn();
                    } else {
                        $(row).fadeOut();
                    }
                }, this));
            } else {
                this.$el.find(".card-spacer").fadeIn();
                this.$el.find(".backgrid tbody tr").fadeIn();
            }
        }
    });

    return new ConnectorListView();
});
