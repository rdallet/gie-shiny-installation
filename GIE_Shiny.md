Install a Shiny Galaxy Interactive Environment
==============================================

#### Requirements : 

- node 0.10.X - 0.11.X (v0.10.48 tested)
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

You can check if nvm is correctly installed and if you have the good nvm version (v0.33.8) with : `nvm --version`

Then, install node v0.10.48 (version tested):

`nvm install v0.10.48`
<!--`nvm use v0.10.48`-->

Please note that if you have NodeJS installed under Ubuntu, you should create a symlink from nodejs to node.

`ln -s $PATH_TO/v0.10.48/bin/node /usr/bin/nodejs`

Finally you should have node v0.10.48 with the command `node --version`



Install the Shiny Galaxy Interactive Environment (GIE) (From the "How to install a Shiny environment" of [CARPEM](https://github.com/CARPEM/GalaxyDocker))
----------------------------------------------------------------------------------------------------------------------------------------------------------

#### 1. Clone this repository.

`git clone https://github.com/RomainDallet/Shiny_GIE_installation.git`

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

Next, edit $GALAXY_PATH/config/galaxy.ini and add the following:

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
        proxy_pass http://localhost:8800/gie_proxy;
        proxy_redirect off;
    }

    # Shiny
    location /gie_proxy/interactiveShiny/ {
        proxy_pass http://127.0.0.1:8800/;
        proxy_redirect off;
    }
```

*Note : `proxy_pass http://127.0.0.1:8800/;` can be change to redirect to a Shiny App as `proxy_pass http://127.0.0.1:8800/samples/<APP_NAME>;`*


Once saved, restart nginx to reread the config:

- If you don't use supervisor :
	- `/etc/init.d/nginx restart` or `sudo systemctl restart nginx`
	- `sh run.sh`
<!--
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


**If it's work, you may can load a Shiny Interactive Environment from a txt/tabular/Rdata file.**


