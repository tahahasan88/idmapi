/*
 * Copyright 2016-2017 ForgeRock AS. All Rights Reserved
 *
 * Use of this code requires a commercial software license with ForgeRock AS.
 * or with one of its affiliates. All use shall be exclusively subject
 * to such license between the licensee and ForgeRock AS.
 */

(function () {
    if(request.method === "action") {
        var oAuthConfig,
            decryptedClientSecret,
            connectorLocation;

        if (request.action === "getAuthZCode") {
            connectorLocation = request.content.connectorLocation.replace("_", "/");

            oAuthConfig = openidm.read("config/" + connectorLocation);

            if (oAuthConfig) {
                if (typeof oAuthConfig.configurationProperties.clientSecret === "object") {
                    decryptedClientSecret = openidm.decrypt(oAuthConfig.configurationProperties.clientSecret);

                    request.content.body += "&client_secret=" + decryptedClientSecret;
                } else {
                    request.content.body += "&client_secret=" + oAuthConfig.configurationProperties.clientSecret;
                }
            }
        }

        request.content["contentType"] = "application/x-www-form-urlencoded";

        return openidm.action("external/rest", "call", request.content);
    } else {
        throw {
            "code" : 400,
            "message" : "Bad request only support _action methods getAuthZCode"
        };
    }
}());
