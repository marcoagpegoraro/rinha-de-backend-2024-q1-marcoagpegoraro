#Rinha de backend!
##Using Vlang
<div align="center">
<p>
    <a href="https://vlang.io/" target="_blank"><img width="80" src="https://raw.githubusercontent.com/vlang/v-logo/master/dist/v-logo.svg?sanitize=true" alt="V logo"></a>
</p>

</div>
This is a project that I did to participate the "rinha-de-backend-2024-q1" challenge.

You can see the criterias of the project in the following link: https://github.com/zanfranceschi/rinha-de-backend-2024-q1 but basically the objective was create an application with two endpoints, using any programming language, and then create the infrastructure using a docker compose file.

The stack of my app is very simple, i just used the standart library of the V programming language (https://vlang.io/) and a postgres database.

You can build the image using the following command:
```docker build --tag 'rinha_vlang_marco' .```
And then run with:
```docker run -p 8080:8080 rinha_vlang_marco```
Be aware that you will need to change the connect info string.