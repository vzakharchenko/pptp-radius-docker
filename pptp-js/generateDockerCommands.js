const fs = require('fs');

const configPath = process.env['CONFIG_PATH'] || '../examples/config.json';

function parseFile(cJson) {
    let redir = '';
    let radsec = '';
    if (cJson.radsec) {
        if (!fs.existsSync(cJson.radsec.privateKey)) {
            throw new Error('Radsec Private key does not exist')
        }
        if (!fs.existsSync(cJson.radsec.certificateFile)) {
            throw new Error('Radsec Public key does not exist')
        }
        if (!fs.existsSync(cJson.radsec.CACertificateFile)) {
            throw new Error('Radsec CA key does not exist')
        }
        radsec = `-v ${cJson.radsec.privateKey}:${cJson.radsec.privateKey} -v ${cJson.radsec.certificateFile}:${cJson.radsec.certificateFile} -v ${cJson.radsec.CACertificateFile}:${cJson.radsec.CACertificateFile} `
    }
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
        `-v ${configPath}:/opt/config.json ${radsec} --privileged --restart=always vassio/pptp-port-forwarding:latest`)
}

const f = fs.readFileSync(configPath, 'utf8');

const configJson = JSON.parse(f);
parseFile(configJson);

