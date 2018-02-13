Shiny_GIE_config
============================

Install the Shiny Galaxy Interactive Environment (GIE) (From the "How to install a Shiny environment" of [CARPEM](https://github.com/CARPEM/GalaxyDocker))
----------------------------------------------------------------------------------------------------------------------------------------------------------

1. Clone the CARPEM repository.

`git clone https://github.com/CARPEM/GalaxyDocker.git`

2. Copy the folder interactiveShiny in the folder $GALAXY\_PATH/config/plugins/interactive_environments/.

`cp -r interactiveShiny $GALAXY_PATH/config/plugins/interactive_environments/`

3. In the interactiveShiny/config/interactiveShiny.ini.sample, verify the image is rocker/shiny.

4. In the interactiveShiny.xml file, you can define for which input your Shiny environment will be available.

5. In the templates folder, interactiveShiny.mako you can define how the data are mounted inside your Shiny app.
<!--
6. To finish you need to add a cron job [docker-cron](https://github.com/cheyer/docker-cron) to your Galaxy container in order to preserve your resources. The Shiny app is not fully recognize by Galaxy and need to be clean as reported by ValentinChCloud. He proposed to use is [Shiny app](https://github.com/ValentinChCloud/shiny-GIE) which will exited the container after 60 secondes of inactivity. We wanted to add also a cron job to delete containers which are still present, until a better solution is found. You need to provide both the app name and the duration of the app. In our cases the Shiny app is killed after 300 seconds of activity.
-->

Configure Node.js proxy (From the "Exercise - Running the Jupyter Galaxy Interactive Environment (GIE)" of [dagobah-training](https://github.com/galaxyproject/dagobah-training/blob/2018-oslo/sessions/21-gie/ex1-jupyter.md))
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

1.Configure proxy

First, you need to install the proxy in your Galaxy instance.

Note : 	Be careful of the node version. 
	Node has recently upgraded, and the galaxy proxy is pinned to an old version of sqlite3. As such you’ll currently need to have an older version of Node available (0.10.X - 0.11.X vintage).
	Please note that if you have NodeJS installed under Ubuntu, it often installs to /usr/bin/nodejs, whereas npm expects it to be /usr/bin/node. You will need to create that symlink yourself.
	cf "Change Node version"


To check your node version, run the command :
`node --version`

If you have not the `node` command or your version is over the 0.11.X, follow the "Change node version" tutorial.

Then :
```
cd $GALAXY_PATH/lib/galaxy/web/proxy/js
npm install
```


Next, edit /$GALAXY_PATH/config/galaxy.ini and add the following:
```
interactive_environment_plugins_directory = $GALAXY_PATH/config/plugins/interactive_environments
dynamic_proxy_external_proxy = True
dynamic_proxy_manage = True
dynamic_proxy_bind_port = 8800
dynamic_proxy_debug = True
dynamic_proxy_session_map = $GALAXY_PATH/config/gie_proxy_session_map.sqlite
dynamic_proxy_prefix = gie_proxy
dynamic_proxy_bind_ip = 127.0.0.1
```

2. Configure nginx

We'll now proxy the Node.js proxy with nginx. This is done by adding to /etc/nginx/sites-available/galaxy. Inside the server { ... } block, add:
```
    # Global GIE configuration
    location /gie_proxy {
        proxy_pass http://localhost:8800/gie_proxy;
        proxy_redirect off;
    }

    # Shiny
    location /gie_proxy/interactiveShiny/ {
        proxy_pass http://127.0.0.1:8800/;
        proxy_redirect off;
    }
```

Note : `proxy_pass http://127.0.0.1:8800/;` can be change to redirect to a Shiny App as `proxy_pass http://127.0.0.1:8800/samples/<APP_NAME>;`

Once saved, restart nginx to reread the config:
- If you don't use supervisor :
`sudo systemctl restart nginx`
`sh run.sh`
- If you use supervisor :
`sudo systemctl restart nginx`
`sudo supervisorctl restart galaxy` or `sudo supervisorctl restart all`
And part 3.


3. Configure proxy to start with supervisor

All that remains is to start the proxy, which we'll do with supervisor. Add to /etc/supervisor/conf.d/galaxy.conf:
```
[program:gie_proxy]
command         = node $GALAXY_PATH/lib/galaxy/web/proxy/js/lib/main.js --ip 127.0.0.1 --port 8800 --sessions $GALAXY_PATH/config/gie_proxy_session_map.sqlite --cookie galaxysession --verbose
directory       = $GALAXY_PATH/lib/galaxy/web/proxy
umask           = 022
autostart       = true
autorestart     = true
startsecs       = 5
user            = galaxy
numprocs        = 1
stdout_logfile  = $GALAXY_PATH/log/gie_proxy.log
redirect_stderr = true
```
Once saved, start the proxy by updating supervisor:
`sudo supervisorctl update`

And restart Galaxy and Nginx:
`sudo systemctl restart nginx`
`sudo supervisorctl restart all`


If it's work, you may can load a Shiny Interactive Environment from a txt/tabular/Rdata file.



Change Node version
-------------------
Help from [GitHub](https://github.com/creationix/nvm/blob/master/README.md#installation) and [Stackoverflow](https://stackoverflow.com/questions/9755841/how-can-i-change-the-version-of-npm-using-nvm)

In order to change the node version, install Node Version Manager :
`npm install nvm`
`. ~/nvm/nvm.sh`

Then, install node v0.10.48 (version I use):
`nvm install v0.10.48`
<!--`nvm use v0.10.48`-->

Please note that if you have NodeJS installed under Ubuntu, you should create a symlink from nodejs to node.
`ln -s $PATH_TO/v0.10.48/bin/node /usr/bin/nodejs`

