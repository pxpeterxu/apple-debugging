const fs = require('fs');
const { getClientSecret } = require('apple-signin-auth');

const [, , clientId, teamId, keyId, privateKeyFile] = process.argv;
console.log(
  getClientSecret({
    clientID: clientId,
    keyIdentifier: keyId,
    privateKey: fs.readFileSync(privateKeyFile, 'utf8'),
    teamID: teamId,
    expAfter: 3600, // 1 hour
  }),
);
