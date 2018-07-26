'use strict';

module.exports = {
    port: 3002,
    authAPIURL: 'http://104.239.138.115:3100',
    profileAPIURL: 'http://104.239.138.115:3101',
    twitterAPIURL: 'http://104.239.138.115:3102',
    facebookAPIURL: 'http://104.239.138.115:3105',
    baseURL: 'http://104.239.138.115:3103', 
    app: {
        name: 'API - Test',
        url: 'http://104.239.138.115:3103',
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
