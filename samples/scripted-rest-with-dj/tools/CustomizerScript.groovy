/*
 * Copyright 2014-2022 ForgeRock AS. All Rights Reserved
 *
 * Use of this code requires a commercial software license with ForgeRock AS.
 * or with one of its affiliates. All use shall be exclusively subject
 * to such license between the licensee and ForgeRock AS.
 */

import groovyx.net.http.HTTPBuilder.RequestConfigDelegate
import groovyx.net.http.RESTClient
import groovyx.net.http.StringHashMap
import org.apache.http.HttpHost
import org.apache.http.auth.AuthScope
import org.apache.http.auth.UsernamePasswordCredentials
import org.apache.http.client.ClientProtocolException
import org.apache.http.client.CredentialsProvider
import org.apache.http.client.HttpClient
import org.apache.http.client.config.RequestConfig
import org.apache.http.client.protocol.HttpClientContext
import org.apache.http.conn.routing.HttpRoute
import org.apache.http.impl.auth.BasicScheme
import org.apache.http.impl.client.BasicAuthCache
import org.apache.http.impl.client.BasicCookieStore
import org.apache.http.impl.client.BasicCredentialsProvider
import org.apache.http.impl.client.HttpClientBuilder
import org.apache.http.impl.conn.PoolingHttpClientConnectionManager
import org.forgerock.openicf.connectors.scriptedrest.ScriptedRESTConfiguration
import org.forgerock.openicf.connectors.scriptedrest.ScriptedRESTConfiguration.AuthMethod
import org.identityconnectors.common.security.GuardedString
import org.identityconnectors.common.security.SecurityUtil

/**
 * A customizer script defines the custom closures to interact with the default implementation and customize it.
 */
customize {
    init { HttpClientBuilder builder ->

        //SETUP: org.apache.http
        def c = delegate as ScriptedRESTConfiguration

        def httpHost = new HttpHost(c.serviceAddress?.host, c.serviceAddress?.port, c.serviceAddress?.scheme);

        PoolingHttpClientConnectionManager cm = new PoolingHttpClientConnectionManager();
        // Increase max total connection to 200
        cm.setMaxTotal(200);
        // Increase default max connection per route to 20
        cm.setDefaultMaxPerRoute(20);
        // Increase max connections for httpHost to 50
        cm.setMaxPerRoute(new HttpRoute(httpHost), 50);

        builder.setConnectionManager(cm)

        // Configure timeout on the entire client
        RequestConfig requestConfig = RequestConfig.custom().build();
        builder.setDefaultRequestConfig(requestConfig)

        // Configure Proxy
        if (c.proxyAddress != null) {
            builder.setProxy(new HttpHost(c.proxyAddress?.host, c.proxyAddress?.port, c.proxyAddress?.scheme));
            // Configure proxy username and password if specified
            if (c.proxyUsername != null && c.proxyPassword != null) {
                UsernamePasswordCredentials credentials =
                        new UsernamePasswordCredentials(c.proxyUsername, SecurityUtil.decrypt(c.proxyPassword))
                CredentialsProvider credentialProvider = new BasicCredentialsProvider()
                credentialProvider.setCredentials(new AuthScope(c.proxyAddress.host, c.proxyAddress.port), credentials)
                builder.setDefaultCredentialsProvider(credentialProvider)
            }
        }

        // Configure Authentication
        switch (ScriptedRESTConfiguration.AuthMethod.valueOf(c.defaultAuthMethod)) {
            case ScriptedRESTConfiguration.AuthMethod.BASIC_PREEMPTIVE:
            case ScriptedRESTConfiguration.AuthMethod.BASIC:
                // It's part of the http client spec to request the resource anonymously
                // first and respond to the 401 with the Authorization header.
                final CredentialsProvider credentialsProvider = new BasicCredentialsProvider();

                c.password.access(
                        {
                            credentialsProvider.setCredentials(new AuthScope(httpHost.getHostName(), httpHost.getPort()),
                                    new UsernamePasswordCredentials(c.username, new String(it)));
                        } as GuardedString.Accessor
                );

                builder.setDefaultCredentialsProvider(credentialsProvider);
                break;
            case ScriptedRESTConfiguration.AuthMethod.NONE:
                break;
            default:
                throw new IllegalArgumentException();
        }

        c.propertyBag.put(HttpClientContext.COOKIE_STORE, new BasicCookieStore());
    }

    /**
     * This Closure can customize the httpClient and the returning object is injected into the Script Binding.
     */
    decorate { HttpClient httpClient ->

        //SETUP: groovyx.net.http

        def c = delegate as ScriptedRESTConfiguration

        def authCache = null
        if (AuthMethod.valueOf(c.defaultAuthMethod).equals(AuthMethod.BASIC_PREEMPTIVE)) {
            authCache = new BasicAuthCache();
            authCache.put(new HttpHost(c.serviceAddress?.host, c.serviceAddress?.port, c.serviceAddress?.scheme), new BasicScheme());

        }

        def cookieStore = c.propertyBag.get(HttpClientContext.COOKIE_STORE)

        RESTClient restClient = new InnerRESTClient(c.serviceAddress, c.defaultContentType, authCache, cookieStore)

        Map<Object, Object> defaultRequestHeaders = new StringHashMap<Object>();
        if (null != c.defaultRequestHeaders) {
            c.defaultRequestHeaders.each {
                if (null != it) {
                    def kv = it.split('=')
                    assert kv.size() == 2
                    defaultRequestHeaders.put(kv[0], kv[1])
                }
            }
        }

        restClient.setClient(httpClient);
        restClient.setHeaders(defaultRequestHeaders)

        // Return with the decorated instance
        return restClient
    }

}

RequestConfigDelegate blank = null;

class InnerRESTClient extends RESTClient {

    def authCache = null;
    def cookieStore = null;

    InnerRESTClient(Object defaultURI, Object defaultContentType, authCache, cookieStore) throws URISyntaxException {
        super(defaultURI, defaultContentType)
        this.authCache = authCache
        this.cookieStore = cookieStore
    }

    @Override
    protected Object doRequest(
            final RequestConfigDelegate delegate) throws ClientProtocolException, IOException {

        // Add AuthCache to the execution context
        if (null != authCache) {
            //do Preemptive Auth
            delegate.getContext().setAttribute(HttpClientContext.AUTH_CACHE, authCache);
        }
        // Add AuthCache to the execution context
        if (null != cookieStore) {
            //do Preemptive Auth
            delegate.getContext().setAttribute(HttpClientContext.COOKIE_STORE, cookieStore);
        }
        return super.doRequest(delegate)
    }
}
