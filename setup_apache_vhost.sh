#!/bin/bash

# Usage: sudo ./setup_apache_vhost.sh yourdomain.com

DOMAIN=$1
EMAIL="your@email.com"  # <-- CHANGE THIS TO YOUR EMAIL
DOC_ROOT="/var/www/$DOMAIN/public_html"
APACHE_CONF="/etc/apache2/apache2.conf"
HTTP_CONF="/etc/apache2/sites-available/$DOMAIN.conf"

if [[ -z "$DOMAIN" ]]; then
  echo "❌ Usage: sudo $0 yourdomain.com"
  exit 1
fi

echo "🚀 Setting up Apache virtual host for $DOMAIN"

# Step 0: Ensure Apache has a global ServerName set
if ! grep -q '^ServerName' "$APACHE_CONF"; then
  echo "🔧 Adding 'ServerName localhost' to apache2.conf to suppress warnings..."
  echo "ServerName localhost" | sudo tee -a "$APACHE_CONF"
  sudo systemctl reload apache2
fi

# Step 1: Create Document Root
echo "📁 Creating document root at $DOC_ROOT..."
sudo mkdir -p "$DOC_ROOT"
sudo chown -R $USER:$USER "/var/www/$DOMAIN"
echo "<h1>$DOMAIN is active</h1>" | sudo tee "$DOC_ROOT/index.html"

# Step 2: Create HTTP VirtualHost config
if [[ ! -f "$HTTP_CONF" ]]; then
  echo "📝 Creating HTTP VirtualHost config at $HTTP_CONF..."
  sudo tee "$HTTP_CONF" > /dev/null <<EOF
<VirtualHost *:80>
    ServerName $DOMAIN
    ServerAlias www.$DOMAIN
    DocumentRoot $DOC_ROOT

    ErrorLog \${APACHE_LOG_DIR}/${DOMAIN}_error.log
    CustomLog \${APACHE_LOG_DIR}/${DOMAIN}_access.log combined
</VirtualHost>
EOF
else
  echo "⚠️ HTTP config already exists: $HTTP_CONF"
fi

# Step 3: Enable site & reload
echo "🟢 Enabling site $DOMAIN.conf"
sudo a2ensite "$DOMAIN.conf"
sudo systemctl reload apache2

# Step 4: Install Certbot & SSL
echo "🔐 Requesting Let's Encrypt SSL certificate..."
sudo apt install -y certbot python3-certbot-apache > /dev/null
sudo certbot --apache -d "$DOMAIN" -d "www.$DOMAIN" --non-interactive --agree-tos -m "$EMAIL"

# Step 5: Final Apache reload
echo "🔄 Final Apache reload..."
sudo systemctl reload apache2

# Step 6: Confirm HTTPS vhost is registered
echo "🔍 Verifying HTTPS VirtualHost for $DOMAIN..."
SSL_CONF="/etc/apache2/sites-enabled/${DOMAIN}-le-ssl.conf"

if [[ -f "$SSL_CONF" ]] && grep -q "$DOMAIN" "$SSL_CONF"; then
  echo "✅ HTTPS VirtualHost is active: $SSL_CONF"
else
  echo "⚠️ HTTPS VirtualHost not found or misconfigured."
fi

# Final Status
echo "🎉 Setup complete for $DOMAIN"
echo "🔗 Test URLs:"
echo "    → http://$DOMAIN"
echo "    → https://$DOMAIN"
