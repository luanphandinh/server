SHELL := /bin/bash

sudo-user:
	test $(name)
	adduser $(name)
	usermod -aG sudo $(name)

nginx:
	test $(domain)
	@echo "Installing packages:"
	sudo apt update
	sudo apt install
	sudo apt install nginx
	@echo "Create new http static sites for $(domain):"
	sudo mkdir -p /var/www/$(domain)/html
	sudo chown -R ${USER}:${USER} /var/www/$(domain)/html
	sudo chmod -R 755 /var/www/$(domain)
	DOMAIN=$(domain) envsubst < ./nginx/index.template.html > /var/www/$(domain)/html/index.html
	@echo "Create new site for $(domain):"
	sudo chown -R ${USER}:${USER} /etc/nginx/sites-available/
	DOMAIN=$(domain) envsubst < ./nginx/template > /etc/nginx/sites-available/$(domain)
	sudo ln -sfn /etc/nginx/sites-available/$(domain) /etc/nginx/sites-enabled/
	sudo systemctl restart nginx
	@echo "Make $(domain) https:"
	sudo apt install certbot python3-certbot-nginx
	sudo ufw allow 'Nginx Full'
	sudo certbot --nginx -d $(domain) -d www.$(domain)
	sudo systemctl restart nginx
