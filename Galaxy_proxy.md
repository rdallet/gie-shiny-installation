Configure Galaxy reverse proxy nginx
====================================

0. Before you begin

Make sure nothing is running on port 80. If there is Apache : `/etc/init.d/apache2 stop`


1. Install nginx as a reverse proxy

```
sudo apt-get update
sudo apt-get install nginx
```

You can check if nginx is running by the command `/etc/init.d/nginx status` and on `http://<your_ip>/` you should see the Ubuntu nginx default page.


2. Configure nginx


You need to create a config for the Galaxy "site". Create the file `/etc/nginx/sites-available/galaxy` as the root user (e.g with `sudo vi /etc/nginx/sites-available/galaxy`). Unlike Apache, nginx does not have a "default" virtualhost, you have to create one using the server { ... } block:

```
upstream galaxy {
    server 127.0.0.1:8080;
}

server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name _;

    client_max_body_size 10G; # max upload size that can be handled by POST requests through nginx

    location / {
        proxy_pass          http://galaxy;
        proxy_set_header    X-Forwarded-Host $host;
        proxy_set_header    X-Forwarded-For  $proxy_add_x_forwarded_for;
    }
}
```

Next you have to create/remove symbolic links between the sites-enabled/ directory and the sites-available/ directory to enable and disable sites and modules. With nginx you have to disable the "default" site and enable the Galaxy site we just created:

```
cd /etc/nginx/
sudo rm sites-enabled/default
sudo ln -s /sites-available/galaxy sites-enabled/galaxy
```

After these config changes, nginx must be restarted.

`/etc/init.d/nginx restart`

Your Galaxy server should now be visible at `http://<your_ip>/` (if you receive a page with the message "502 Bad Gateway", ensure that your Galaxy server is running).


Note : To improve the performances, you can follow the Section 2 of the [Dagobah Training nginx exercise](https://github.com/galaxyproject/dagobah-training/blob/2018-oslo/sessions/03-production-basics/ex3-nginx.md)

