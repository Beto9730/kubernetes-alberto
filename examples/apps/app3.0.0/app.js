//Require module
const express = require('express');
// Express Initialize
//app
const app = express();
const port = 8000;

const health = require('@cloudnative/health-connect');
let healthCheck = new health.HealthChecker();


const livePromise = () => new Promise((resolve, _reject) => {
    const appFunctioning = true;
    // You should change the above to a task to determine if your app is functioning correctly
    if (appFunctioning) {
      resolve();
    } else {
      reject(new Error("App is not functioning correctly"));
    }
  });
let liveCheck = new health.LivenessCheck("LivenessCheck", livePromise);
healthCheck.registerLivenessCheck(liveCheck);

let readyCheck = new health.PingCheck("google.com");
healthCheck.registerReadinessCheck(readyCheck);

//app
app.listen(port,()=> {
console.log('APP gc-hola-alberto 3.0.0 is running in port 8000');
})


//create api
app.get('/gc-hola-alberto', (req,res)=>{
    res.send('Hola Alberto Version 3.0.0');
    console.info(`${req.method} ${req.originalUrl}`) 
    })

app.use('/gc-hola-alberto/live', health.LivenessEndpoint(healthCheck));
app.use('/gc-hola-alberto/ready', health.ReadinessEndpoint(healthCheck));
app.use('/gc-hola-alberto/health', health.HealthEndpoint(healthCheck));
