# Rinha de backend!
### Using Vlang

<div align="center">
<p>
    <a href="https://vlang.io/" target="_blank"><img width="80" src="https://raw.githubusercontent.com/vlang/v-logo/master/dist/v-logo.svg?sanitize=true" alt="V logo"></a>
</p>

</div>
<hr>
This is a project that I did to participate the "rinha-de-backend-2024-q1" challenge.

You can see the criterias of the project in the following link: https://github.com/zanfranceschi/rinha-de-backend-2024-q1 but basically the objective was create an application with two endpoints, using any programming language, and then create the infrastructure using a docker compose file.

#### This is the stack of my app:

- Vlang v0.4.4 (https://vlang.io)
  - Vweb (https://modules.vlang.io/vweb.html)
  - orm (https://modules.vlang.io/orm.html)
  - db.pg (https://modules.vlang.io/db.pg.html)

- Nginx
- PostgreSQL
  - PLPGSQL


If you wanna run this project localy, you will also need to instal libpg, witch is used by db.pg to connect with postgres, if that doesn't work, try to install postgresql-dev.

You can build the image using the following command:
```docker build --tag 'rinha_vlang_marco' .```
And then run with:
```docker run -p 8080:8080 rinha_vlang_marco```
Be aware that you will need to change the connect info string.

You can also run the docker compose using 
```docker compose up```
This way, the app will run with two instances, a postgres instance and a nginx load balancer.
<hr>

## Stress test

Here is the stress test result that the challenge provided to the participants, i used the docker compose up command to start the infrastructure of my app and then i started the stress test (https://github.com/zanfranceschi/rinha-de-backend-2024-q1/blob/main/executar-teste-local.sh). Here is the machine specs that i runned the test:

- Processor: Intel Core i5-10210U
- Ram: 8GB DDR4 
- OS: Linux Mint Cinnamon 21.3

<img src="https://github.com/marcoagpegoraro/rinha-de-backend-2024-q1-marcoagpegoraro/blob/main/stresstest/1.jpeg?raw=true" alt="Request Time Ranges"/>
<img src="https://github.com/marcoagpegoraro/rinha-de-backend-2024-q1-marcoagpegoraro/blob/main/stresstest/1.jpeg?raw=true" alt="Request Time Ranges"/>
<img src="https://github.com/marcoagpegoraro/rinha-de-backend-2024-q1-marcoagpegoraro/blob/main/stresstest/3.jpeg?raw=true" alt="Requests"/>
<img src="https://github.com/marcoagpegoraro/rinha-de-backend-2024-q1-marcoagpegoraro/blob/main/stresstest/4.jpeg?raw=true" alt="Response Time Percentiles over Time (OK)"/>
<img src="https://github.com/marcoagpegoraro/rinha-de-backend-2024-q1-marcoagpegoraro/blob/main/stresstest/5.jpeg?raw=true" alt="Number of requests per second"/>
<img src="https://github.com/marcoagpegoraro/rinha-de-backend-2024-q1-marcoagpegoraro/blob/main/stresstest/6.jpeg?raw=true" alt="Number of responses per second"/>
<img src="https://github.com/marcoagpegoraro/rinha-de-backend-2024-q1-marcoagpegoraro/blob/main/stresstest/7.jpeg?raw=true" alt="Response Time Distribution"/>
