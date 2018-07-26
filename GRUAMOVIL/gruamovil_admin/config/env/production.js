'use strict';

module.exports = {
    port: 3010,
    authAPIURL: 'http://service-auth.karmapulse.com',
    profileAPIURL: 'http://service-profile.karmapulse.com',
    twitterAPIURL: 'http://service-twitter.karmapulse.com',
    facebookAPIURL: 'http://service-facebook.karmapulse.com',
    baseURL: 'http://admin.karmapulse.com', 
    app: {
        name: 'Admin Karma Metrics',
        url: 'http://admin.karmapulse.com',
    },
    jwtSecret: '=2.mS9PjKt7l1@FRzZMq58VmBI5[#mD9',
    mailGun: {
        apiKey: 'key-e5a05f5bc728f7f6b83efee2fd369b95',
        from: "'Karma Pulse' <hola@karmapulse.com>",
    },
    cdn: {
        mailing: "http://b7e884d32a0f9960cfb4-022a22b577be68b376f5fb8cef6a5572.r94.cf1.rackcdn.com/Mailing/",
    },
};
