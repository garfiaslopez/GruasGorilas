'use strict';

module.exports = {
    port: 3001,
    authAPIURL: 'http://qa-service-auth.karmapulse.com/',
    baseURL: 'http://localhost:3001',
    ApiURL: 'http://localhost:3000'
    app: {
        name: 'API - Development',
        url: 'http://localhost:3001',
    },
    jwtSecret: 'KcNy;R6fJg9Le7b4{Yr.d+vEje7Fv.RV',
    mailGun: {
        apiKey: 'key-e5a05f5bc728f7f6b83efee2fd369b95',
        from: "'KarmaPulse' <hola@karmapulse.com>",
    },
    cdn: {
        mailing: "http://b7e884d32a0f9960cfb4-022a22b577be68b376f5fb8cef6a5572.r94.cf1.rackcdn.com/Mailing/",
    },
};
