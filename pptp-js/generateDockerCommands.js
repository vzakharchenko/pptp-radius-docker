const fs = require('fs');

const configPath = process.env['CONFIG_PATH'] || '../examples/config.json';

function parseFile(cJson) {
    let redir = '';
    if (cJson.authorizationMap) {
        if (cJson.authorizationMap.roles) {
            Object.entries(cJson.authorizationMap.roles).forEach(((kv) => {
                const value = kv[1];
                if (value.forwarding) {
                    value.forwarding.forEach(f => {
                        redir = redir + `-p ${f.externalPort}:${f.externalPort} `
                    })

                }
            }));
        }
    }

    console.log('docker run -d --name=pptp-radius-docker -p 1723:1723 -p 3799:3799 ' + redir +
        `-v ${configPath}:/opt/config.json --privileged --restart=always vassio/pptp-port-forwarding:latest`)
}

const f = fs.readFileSync(configPath, 'utf8');

const configJson = JSON.parse(f);
parseFile(configJson);

