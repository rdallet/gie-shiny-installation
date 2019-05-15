Install a Shiny Galaxy Interactive Environment
==============================================

#### Requirements : 

- **node 0.10.X - 0.11.X** (v0.10.48 tested)
- nvm (v0.33.8) <!--*if node \>0.11.X installed*-->
- Docker

*Note : Be careful of the node version. 
	Node has recently upgraded, and the galaxy proxy is pinned to an old version of sqlite3. As such you’ll currently need to have an older version of Node available (0.10.X - 0.11.X vintage).
	Please note that if you have NodeJS installed under Ubuntu, it often installs to /usr/bin/nodejs, whereas npm expects it to be /usr/bin/node. You will need to create that symlink yourself.
	cf "Install the requirements".*


Install the requirements
------------------------

#### 1. Install Docker (v1.13.1) <!--Ubuntu 14.04 and 16.04-->

`sudo apt-get install docker.io`


#### 2. Install node (if node v0.10.X-0.11.X already installed, go to the next section)

`sudo apt-get install npm`
<!--VERIFY IF IT WORKS-->


#### 3. Install nvm to change node version

To install or update nvm, you can use the install script using cURL:

`curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash`

or Wget:

`wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash`

The script clones the nvm repository to \~/.nvm and adds the source line to your profile (\~/.bash_profile, \~/.zshrc, \~/.profile, or \~/.bashrc).

So, you need to `source` your profile : `source ~/.bashrc`

You can check if nvm is correctly installed and if you have the good nvm version (v0.33.8) with : `nvm --version`

Then, install node v0.10.48 (version tested):

`nvm install v0.10.48`
<!--`nvm use v0.10.48`-->

Please note that `npm` expects `node` to be in /usr/bin/node, so you should create a symlink from node v0.10.48 to /usr/bin/node.

`ln -s $HOME_PATH/.nvm/v0.10.48/bin/node /usr/bin/node`

Finally you should have node v0.10.48 with the command `node --version`

<!--
#### 4. Install uwsgi

[HERE](https://github.com/galaxyproject/dagobah-training/blob/2018-oslo/sessions/10-uwsgi/ex1-uwsgi.md)

##### Installation

You can install uWSGI with the following line:

`$ sudo apt install uwsgi uwsgi-plugin-python`

##### Configure uwsgi

We'll use uWSGI's "Paste Deploy" support to configure uWSGI with just a few small modifications to galaxy.ini. Begin by opening galaxy.ini in your editor:

`sudo vi $GALAXY_PATH/config/galaxy.ini`

And add the following section (the easiest place to put it is above the [server:main] section, which will now be unused):

```
[uwsgi]
processes = 2
threads = 2
socket = 127.0.0.1:4001     # uwsgi protocol for nginx
pythonpath = lib
master = True
logto = $GALAXY_PATH/log/uwsgi.log
logfile-chmod = 644
```

Then, save and quit your editor.

##### Configure the reverse proxy

We previously configured nginx to communicate with Galaxy using the HTTP protocol on port 8080. We need to change this to communicate using the uWSGI protocol on port 4001, as we configured in the [uwsgi] section above. To do this, we need to return to the nginx configs we worked on in the nginx session:

`sudo vi /etc/nginx/sites-available/galaxy`

Locate the location / { ... } block and comment out the proxy_* directives within, and adding new directives:

```
    location / {
        #proxy_pass          http://galaxy;
        #proxy_set_header    X-Forwarded-Host $host;
        #proxy_set_header    X-Forwarded-For  $proxy_add_x_forwarded_for;
        uwsgi_pass           127.0.0.1:4001;
        include              uwsgi_params;
    }
```

Then, save and quit your editor. Restart nginx with:

`/etc/init.d/nginx restart` or `sudo systemctl restart nginx`

#### 5. Install supervisor


###### Supervisor installation

[HERE](https://github.com/galaxyproject/dagobah-training/blob/2018-oslo/sessions/11-systemd-supervisor/ex1-supervisor.md)

Install supervisor from the system package manager using:

`$ sudo apt install supervisor`

Check if Supervisor is running and start it if it isn't:

```
$ sudo systemctl status supervisor
$ sudo systemctl start supervisor
```

If supervisorctl status returns no output, it means it's working (but nothing has been configured yet):

`$ sudo supervisorctl status`

Then, we need to add a [program:x] section to the supervsior config to manage uWSGI. The default supervisor config file is at /etc/supervisor/supervisord.conf. This file includes any files matching /etc/supervisor/conf.d/*.conf. We'll create a galaxy.conf:

`$ sudo vi /etc/supervisor/conf.d/galaxy.conf`

Add the following new section:

```
[program:galaxy]
command         = uwsgi --plugin python --virtualenv /srv/galaxy/venv --ini-paste /srv/galaxy/config/galaxy.ini
directory       = /srv/galaxy/server
autostart       = true
autorestart     = true
startsecs       = 10
user            = root
stopsignal      = INT
```

Define handlers and groups managing is possible too.
-->


Install the Shiny Galaxy Interactive Environment (GIE) (From the "How to install a Shiny environment" of [CARPEM](https://github.com/CARPEM/GalaxyDocker))
----------------------------------------------------------------------------------------------------------------------------------------------------------

#### 1. Clone this repository.

`git clone https://github.com/RomainDallet/gie-shiny-installation.git`

#### 2. Copy the folder shiny in the folder $GALAXY\_PATH/config/plugins/interactive_environments/.

`cp -r shiny $GALAXY_PATH/config/plugins/interactive_environments/`

#### 3. In the shiny/config/allowed_images.yml, verify the image is quay.io/workflow4metabolomics/gie-shiny.

#### 4. In the shiny.xml file, you can define for which input your Shiny environment will be available.

#### 5. In the templates folder, you can define how the data are mounted inside your Shiny app in the shiny.mako.



Configure Node.js proxy (From the "Exercise - Running the Jupyter Galaxy Interactive Environment (GIE)" of [dagobah-training](https://github.com/galaxyproject/dagobah-training/blob/2018-oslo/sessions/21-gie/ex1-jupyter.md))
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#### 1. Configure proxy

First, check your node version by running the command :
`node --version`

If you have not the `node` command or your version is not between the 0.10.X - 0.11.X, follow the "Install the requirements" part.

Then you need to install the proxy in your Galaxy instance.:

```
cd $GALAXY_PATH/lib/galaxy/web/proxy/js
npm install
```

Next, edit $GALAXY_PATH/config/galaxy.ini and change the following options:

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


#### 2. Configure nginx

We'll now proxy the Node.js proxy with nginx. This is done by adding to /etc/nginx/sites-available/galaxy. Inside the server {...} block, add:

```
    # Global GIE configuration
    location /gie_proxy {
        proxy_pass http://127.0.0.1:8800/gie_proxy;
        proxy_redirect off;
    }

    # Shiny
    location /gie_proxy/shiny/ {
        proxy_pass http://127.0.0.1:8800/;
        proxy_redirect off;
    }
```

<!--*Note : `proxy_pass http://127.0.0.1:8800/;` can be change to redirect to a Shiny App as `proxy_pass http://127.0.0.1:8800/samples/<APP_NAME>;`*-->


Once saved, restart nginx to reread the config:
- `/etc/init.d/nginx restart` or `sudo systemctl restart nginx`
- `sh run.sh`

<!--
- If you don't use supervisor :
- If you use supervisor : Go to part 3


#### 3. Configure proxy to start with supervisor

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

`sudo systemctl restart nginx` and `sudo supervisorctl restart galaxy` 

or

`sudo supervisorctl restart all`
-->


**If it's work, you may can load a Shiny Interactive Environment from a txt file.**


