# nginx — Reverse Proxy

Install and configure nginx on Ubuntu as a reverse proxy, including a force-HTTPS setup.

## Install

```bash
sudo apt update
sudo apt upgrade
sudo apt install nginx
sudo systemctl enable nginx
sudo systemctl start nginx
```

Configuration folder:

```
/etc/nginx
```

## Basic reverse proxy

Create a new site configuration:

```bash
sudo nano /etc/nginx/sites-available/app1.mondomaine.com
```

```nginx
server {
    listen 80;
    listen [::]:80;

    server_name app1.mondomaine.com;

    location / {
        proxy_pass http://127.0.0.1:3000;

        proxy_http_version 1.1;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable the site:

```bash
sudo ln -s /etc/nginx/sites-available/app1.mondomaine.com /etc/nginx/sites-enabled/
```

## Verification

Test the configuration before restarting:

```bash
sudo nginx -t
```

Reload nginx:

```bash
sudo systemctl reload nginx
```

## HTTPS (force HTTPS only)

In the default configuration `/etc/nginx/sites-available/default`, replace the content with a redirect to HTTPS:

```nginx
server {
    listen 80;
    listen [::]:80;

    server_name app1.mondomaine.com;

    return 301 https://$host$request_uri;
}
```

Create the site configuration with HTTPS, e.g. `/etc/nginx/sites-available/app1.mondomaine.com`:

```nginx
server {
    listen 443 ssl http2;

    server_name app1.mondomaine.com;

    ssl_certificate     /etc/nginx/certs/YOUR_CERTIFICATE.crt;
    ssl_certificate_key /etc/nginx/certs/YOUR_KEY.key;

    location / {
        proxy_pass http://127.0.0.1:8081;

        proxy_http_version 1.1;

        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```
