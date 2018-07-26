'use strict';

module.exports = {
    port: 3000,
    app: {
        name: 'API - Production'
    },
    dbMongo: 'mongodb://GorilasAppSuperUser:1963Operaciones@127.0.0.1:18509/GorilasApp',
	key: "ThisIsAFantasticKey",
    encKey: '2YcQKdZFWlxe4vV5Os36CZl1JSMNNFg5fzg8I0u/O0c=',
    sigKey: 'c48ZEoNNaQ1C6pg91wYxEaVOe9IqLnC5RMhwqd1GJJInf1hzSZMq9Fm6LQREzqC7jTuQX5KP0x89clI/NlT7Ew==',
    ConektaApiKey: 'key_ZSHP7w2kqxRELxrsEJ5rAw',
    UrbanAppKey: '7I-1KgjoQq2VTjsQu6qtEA',
    UrbanMasterSecret: 'Jc2tq77fRAqzEkELlH1jzQ',
    searchDistance: 5000,
    searchLimit: 10,
    mailgunUrl: 'gorilasapp.com.mx',
    mailgunKey: 'key-d3b4220e9454ff1ceb516820dee68cdf'
};


/**

use admin
db.createUser(
  {
    user: "GorilasAdmin",
    pwd: "Operaciones1963",
    roles: [ { role: "root", db: "admin" } ]
  }
)

use GorilasApp
db.createUser(
    {
      user: "GorilasAppSuperUser",
      pwd: "1963Operaciones",
      roles: [
         { role: "readWrite", db: "GorilasApp" }
      ]
    }
)



**/
