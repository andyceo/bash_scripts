const port = process.env.PORT || 8130
const dockerCommand = process.env.DOCKER || '/usr/bin/docker'
const http = require('http');
const child_process = require('child_process')
const stacks = require(`./config.json`)['stacks']
const services = require(`./config.json`)['services']

let server = new http.Server(function(req, res) {
    // Server API will receive only POST-requests and only JSON, so write all received info to jsonString variable
    var jsonString = '';
    res.setHeader('Content-Type', 'application/json');
    req.on('data', (data) => { // Info received = write it down.
        jsonString += data;
    });

    req.on('end', () => { // no more info - move it forward
        const payload = JSON.parse(jsonString)
        const image = `${payload.repository.repo_name}:${payload.push_data.tag}`

        console.log('Received:')
        console.log(jsonString)
        console.log(`Image: ${image}`)

        if (!services[image] && !stacks[image]) {
            console.log(`Received update for "${image}" but nor services nor stacks are configured to handle updates for this image.`)
            res.writeHead(404, {'content-type': 'text/plain'})
            res.end('Not Found\n')
        }
        else if (stacks[image]) {
            const stack = stacks[image].stack
            const filepath = stacks[image].filepath
            // (Re)Deploy the stack
            console.log(`Deploying ${image} to stack ${stack}...`)
            error = child_process.exec(`${dockerCommand} stack deploy -c ${filepath} ${stack}`, (error, stdout, stderr) => {
                if (error) {
                    console.error(`Failed to deploy ${image} to stack ${stack}!`)
                    console.error(error)
                    res.writeHead(500, {'content-type': 'text/plain'})
                    res.end('Internal Server Error\n')
                }
                else {
                    console.log(`Deployed ${image} to stack ${stack} successfully.`)
                    res.writeHead(200, {'content-type': 'text/plain'})
                    res.end('OK (stack)\n')
                }
            })
        }
        // This branch is emporary disabled
        else if (service[image] && false) {
            const service = services[image].service
            // (Re)Deploy the image and force a restart of the associated service
            console.log(`Deploying ${image} to service ${service}...`)
            child_process.exec(`${dockerCommand} service update ${service} --force --image=${image}`, (error, stdout, stderr) => {
                if (error) {
                    console.error(`Failed to deploy ${image} to ${service}!`)
                    return console.error(error)
                }
                console.log(`Deployed ${image} to ${service} successfully and restarted the service.`)
            })
            res.status(200).send('OK (service)')
        }
    });
});

server.listen(port, '0.0.0.0');
