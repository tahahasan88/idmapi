"use strict";

/*
 * Copyright 2015-2022 ForgeRock AS. All Rights Reserved
 *
 * Use of this code requires a commercial software license with ForgeRock AS.
 * or with one of its affiliates. All use shall be exclusively subject
 * to such license between the licensee and ForgeRock AS.
 */

define(["jquery", "underscore", "org/forgerock/openidm/ui/admin/util/AdminAbstractView", "org/forgerock/openidm/ui/common/delegates/ConfigDelegate", "org/forgerock/commons/ui/common/main/EventManager", "org/forgerock/commons/ui/common/util/Constants", "org/forgerock/openidm/ui/admin/delegates/RepoDelegate", "org/forgerock/commons/ui/common/main/Router"], function ($, _, AdminAbstractView, ConfigDelegate, EventManager, Constants, RepoDelegate, Router) {

    var AbstractManagedView = AdminAbstractView.extend({
        data: {},

        saveManagedObject: function saveManagedObject(managedObject, saveObject, isNewManagedObject, callback) {
            var promises = arguments.length > 4 && arguments[4] !== undefined ? arguments[4] : [];

            promises.push(ConfigDelegate.updateEntity("managed", { "objects": saveObject.objects }));
            promises.push(this.getRepoPromise(managedObject));

            $.when.apply($, promises).then(_.bind(function () {
                EventManager.sendEvent(Constants.EVENT_DISPLAY_MESSAGE_REQUEST, "managedObjectSaveSuccess");
                EventManager.sendEvent(Constants.EVENT_UPDATE_NAVIGATION);

                if (isNewManagedObject) {
                    EventManager.sendEvent(Constants.EVENT_CHANGE_VIEW, { route: Router.configuration.routes.editManagedView, args: [managedObject.name] });
                } else {
                    this.render(this.args, callback);
                }
            }, this), function (error) {
                // If this is a policy validation error caused by a bad script display an error message with the name of the bad script.
                if (error.responseJSON && error.responseJSON.code === 403 && _.has(error.responseJSON, "detail.failedPolicyRequirements[0].policyRequirements[0].params.invalidScripts")) {
                    var invalidScript = error.responseJSON.detail.failedPolicyRequirements[0].policyRequirements[0].params.invalidScripts[0];
                    EventManager.sendEvent(Constants.EVENT_DISPLAY_MESSAGE_REQUEST, { key: "managedConfigInvalidScript", invalidScript: invalidScript });
                }
            });
        },

        getRepoPromise: function getRepoPromise(managedObject) {
            var _this = this;

            if (!_.has(this.data.repoConfig, "_id")) {
                return RepoDelegate.findRepoConfig().then(function (repoConfig) {
                    _this.data.repoConfig = repoConfig;
                    return _this.getRepoPromise(managedObject);
                });
            }
            switch (RepoDelegate.getRepoTypeFromConfig(this.data.repoConfig)) {
                case "jdbc":
                    var resourceMapping = RepoDelegate.findGenericResourceMappingForRoute(this.data.repoConfig, "managed/" + managedObject.name);
                    if (resourceMapping && resourceMapping.searchableDefault !== true) {
                        var searchablePropertiesList = _(managedObject.schema.properties).toPairs().map(function (prop) {
                            if (prop[1].searchable) {
                                return prop[0];
                            }
                        }).filter().value();
                        // modifies this.data.repoConfig via object reference in resourceMapping
                        RepoDelegate.syncSearchablePropertiesForGenericResource(resourceMapping, searchablePropertiesList);

                        return RepoDelegate.updateEntity(this.data.repoConfig._id, this.data.repoConfig);
                    }
                    break;
            }
        },

        checkManagedName: function checkManagedName(name, managedList) {
            var found = false;

            _.forEach(managedList, function (managedObject) {
                if (managedObject.name === name) {
                    found = true;
                }
            });

            return found;
        }
    });

    return AbstractManagedView;
});
