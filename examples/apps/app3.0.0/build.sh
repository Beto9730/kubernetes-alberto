#!/bin/bash
docker build --no-cache -t localhost:5000/gc-hcmc-hola-alberto:3.0.0 .
docker push localhost:5000/gc-hcmc-hola-alberto:3.0.0
