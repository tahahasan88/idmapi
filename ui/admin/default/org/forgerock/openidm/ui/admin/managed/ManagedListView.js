"use strict";

/*
 * Copyright 2014-2020 ForgeRock AS. All Rights Reserved
 *
 * Use of this code requires a commercial software license with ForgeRock AS.
 * or with one of its affiliates. All use shall be exclusively subject
 * to such license between the licensee and ForgeRock AS.
 */

define(["jquery", "underscore", "backbone", "org/forgerock/openidm/ui/admin/util/AdminAbstractView", "org/forgerock/commons/ui/common/main/EventManager", "org/forgerock/commons/ui/common/util/Constants", "org/forgerock/openidm/ui/admin/delegates/RepoDelegate", "org/forgerock/commons/ui/common/main/Router", "org/forgerock/openidm/ui/admin/delegates/ConnectorDelegate", "org/forgerock/openidm/ui/admin/util/ConnectorUtils", "org/forgerock/openidm/ui/common/delegates/ConfigDelegate", "backgrid", "org/forgerock/openidm/ui/common/util/BackgridUtils", "org/forgerock/commons/ui/common/util/UIUtils", "org/forgerock/openidm/ui/admin/managed/schema/util/SchemaUtils"], function ($, _, Backbone, AdminAbstractView, eventManager, constants, RepoDelegate, router, ConnectorDelegate, connectorUtils, ConfigDelegate, Backgrid, BackgridUtils, UIUtils, SchemaUtils) {
    var ManagedListView = AdminAbstractView.extend({
        template: "templates/admin/managed/ManagedListViewTemplate.html",
        events: {
            "click .managed-delete": "deleteManaged",
            "click .toggle-view-btn": "toggleButtonChange",
            "keyup .filter-input": "filterManagedObjects",
            "paste .filter-input": "filterManagedObjects"
        },
        model: {},
        render: function render(args, callback) {
            var tempIconClass;

            this.data.docHelpUrl = constants.DOC_URL;

            $.when(ConfigDelegate.readEntity("managed"), RepoDelegate.findRepoConfig()).then(_.bind(function (managedObjects, repoConfig) {
                this.data.currentManagedObjects = _.sortBy(managedObjects.objects, 'name');
                this.data.repoConfig = repoConfig;

                _.forEach(this.data.currentManagedObjects, _.bind(function (managedObject) {
                    tempIconClass = connectorUtils.getIcon("managedobject");

                    managedObject.iconClass = tempIconClass.iconClass;
                    managedObject.iconSrc = tempIconClass.src;
                }, this));

                this.resourceRender(callback);
            }, this));
        },

        resourceRender: function resourceRender(callback) {
            var ManagedModel = Backbone.Model.extend({}),
                ManagedObjects = Backbone.Collection.extend({ model: ManagedModel }),
                managedObjectGrid,
                RenderRow,
                _this = this;

            this.model.managedObjectCollection = new ManagedObjects();

            _.forEach(this.data.currentManagedObjects, _.bind(function (managedObject) {
                managedObject.type = $.t("templates.managed.managedObjectType");
                this.model.managedObjectCollection.add(managedObject);
            }, this));

            RenderRow = Backgrid.Row.extend({
                render: function render() {
                    RenderRow.__super__.render.apply(this, arguments);

                    this.$el.attr('data-managed-title', this.model.attributes.name);

                    return this;
                }
            });

            this.parentRender(_.bind(function () {
                managedObjectGrid = new Backgrid.Grid({
                    className: "table backgrid",
                    emptyText: $.t("templates.managed.noResourceTitle"),
                    row: RenderRow,
                    columns: BackgridUtils.addSmallScreenCell([{
                        name: "source",
                        sortable: false,
                        editable: false,
                        cell: Backgrid.Cell.extend({
                            render: function render() {
                                var icon = this.model.attributes.iconClass,
                                    display;

                                if (this.model.attributes.schema && this.model.attributes.schema.icon) {
                                    icon = "fa " + this.model.attributes.schema.icon;
                                } else {
                                    icon = "fa fa-database";
                                }

                                display = '<a class="table-clink" href="#managed/edit/' + this.model.attributes.name + '/"><div class="image circle">' + '<i class="' + icon + '"></i></div>' + this.model.attributes.name + '</a>';

                                this.$el.html(display);

                                return this;
                            }
                        })
                    }, {
                        name: "type",
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

                                $(display).append(_this.$el.find("[data-managed-title='" + this.model.attributes.name + "'] .dropdown-menu").clone());

                                this.$el.html(display);

                                return this;
                            }
                        })
                    }]),
                    collection: this.model.managedObjectCollection
                });

                this.$el.find("#managedGrid").append(managedObjectGrid.render().el);

                if (callback) {
                    callback();
                }
            }, this));
        },

        toggleButtonChange: function toggleButtonChange(event) {
            var target = $(event.target);

            if (target.hasClass("fa")) {
                target = target.parents(".btn");
            }

            this.$el.find(".toggle-view-btn").toggleClass("active", false);
            target.toggleClass("active", true);
        },

        deleteManaged: function deleteManaged(event) {
            var selectedItem = $(event.currentTarget).parents(".card-spacer"),
                promises = [],
                alternateItem,
                tempManaged = _.clone(this.data.currentManagedObjects);

            if (selectedItem.length > 0) {
                _.forEach(this.$el.find(".backgrid tbody tr"), function (row) {
                    if ($(row).attr("data-managed-title") === selectedItem.attr("data-managed-title")) {
                        alternateItem = $(row);
                    }
                });
            } else {
                selectedItem = $(event.currentTarget).parents("tr");

                _.forEach(this.$el.find(".card-spacer"), function (card) {
                    if ($(card).attr("data-managed-title") === selectedItem.attr("data-managed-title")) {
                        alternateItem = $(card);
                    }
                });
            }

            UIUtils.confirmDialog($.t("templates.managed.managedDelete"), "danger", _.bind(function () {
                var _this2 = this;

                tempManaged = _.reject(tempManaged, _.bind(function (managedObject) {
                    return managedObject.name === selectedItem.attr("data-managed-title");
                }, this));

                tempManaged = SchemaUtils.removeRelationshipOrphans(tempManaged, selectedItem.attr("data-managed-title"));

                promises.push(ConfigDelegate.updateEntity("managed", { "objects": tempManaged }));

                $.when.apply($, promises).then(function () {
                    selectedItem.remove();
                    alternateItem.remove();

                    _this2.data.currentManagedObjects = tempManaged;

                    if (_this2.$el.find(".backgrid tbody tr").length === 0) {
                        _this2.$el.find(".fr-resource-list .tab-content").hide();
                        _this2.$el.find(".section-help").hide();
                        _this2.$el.find(".page-toolbar").hide();
                        _this2.$el.find(".no-resource").show();
                    }

                    eventManager.sendEvent(constants.EVENT_UPDATE_NAVIGATION);
                    eventManager.sendEvent(constants.EVENT_DISPLAY_MESSAGE_REQUEST, "deleteManagedSuccess");
                }, function () {
                    eventManager.sendEvent(constants.EVENT_DISPLAY_MESSAGE_REQUEST, "deleteManagedFail");
                });
            }, this));
        },

        filterManagedObjects: function filterManagedObjects(event) {
            var search = $(event.target).val().toLowerCase();

            if (search.length > 0) {
                _.forEach(this.$el.find(".card-spacer"), _.bind(function (card) {
                    if ($(card).attr("data-managed-title").toLowerCase().indexOf(search) > -1) {
                        $(card).fadeIn();
                    } else {
                        $(card).fadeOut();
                    }
                }, this));

                _.forEach(this.$el.find(".backgrid tbody tr"), _.bind(function (row) {
                    if ($(row).attr("data-managed-title").toLowerCase().indexOf(search) > -1) {
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

    return new ManagedListView();
});
