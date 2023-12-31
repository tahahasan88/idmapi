"use strict";

/*
 * Copyright 2018-2020 ForgeRock AS. All Rights Reserved
 *
 * Use of this code requires a commercial software license with ForgeRock AS.
 * or with one of its affiliates. All use shall be exclusively subject
 * to such license between the licensee and ForgeRock AS.
 */

define(["org/forgerock/openidm/ui/admin/util/AdminAbstractView", "org/forgerock/openidm/ui/admin/kba/QuestionsView", "org/forgerock/openidm/ui/admin/kba/UpdateView"], function (AdminAbstractView, QuestionsView, UpdateView) {
    var EditKbaView = AdminAbstractView.extend({
        template: "templates/admin/kba/EditKbaTemplate.html",

        render: function render(args, callback) {
            this.parentRender(function () {

                QuestionsView.render({ "data": {} }, true);

                UpdateView.render();

                if (callback) {
                    callback();
                }
            });
        }
    });

    return new EditKbaView();
});
