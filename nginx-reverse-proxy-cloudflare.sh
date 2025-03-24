#!/bin/zsh

# Pre-grant sudo access with absolute paths
if [ "$EUID" -ne 0 ]; then
    echo "Script needs to be run as root. Re-running with sudo..."
    exec sudo /bin/zsh "$0" "$@"
fi

if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <subdomain.domain.com> <path> <upstream_url>"
    exit 1
fi

SUBDOMAIN=$1
PATH=$2
UPSTREAM_URL=$3

NGINX_CONFIG="/etc/nginx/sites-available/$SUBDOMAIN"
NGINX_LINK="/etc/nginx/sites-enabled/$SUBDOMAIN"

# Create the Nginx configuration file using absolute paths
/usr/bin/cat > "$NGINX_CONFIG" <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $SUBDOMAIN;
    return 302 https://\$server_name\$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $SUBDOMAIN;

    location $PATH {
        proxy_pass $UPSTREAM_URL;
        proxy_http_version 1.1;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    ssl_certificate /etc/ssl/cloudflare/cert.pem;
    ssl_certificate_key /etc/ssl/cloudflare/privkey.pem;
    ssl_client_certificate /etc/ssl/cloudflare/client.pem;
    ssl_verify_client on;
}
EOF

# Enable the site by creating a symlink using absolute paths
/usr/bin/ln -sf "$NGINX_CONFIG" "$NGINX_LINK"



# sudo chmod +x ./nginx-reverse-proxy-cloudflare.sh
# sudo chown root:root nginx-reverse-proxy-cloudflare.sh


# Test and reload Nginx using absolute paths
/usr/sbin/nginx -t && /bin/systemctl reload nginx

echo "Reverse proxy setup complete for $SUBDOMAIN"
