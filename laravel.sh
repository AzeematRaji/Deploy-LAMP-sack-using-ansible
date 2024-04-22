#!/bin/bash

#Add new software repositories
sudo apt update
sudo apt install software-properties-common -y
sudo apt update

# Add repositories for latest PHP versions
sudo add-apt-repository ppa:ondrej/php -y

# Update package lists again to include new packages from the PPA
sudo apt update

# Install PHP 8.2 and essential extensions
sudo apt install -y php8.2 php8.2-xml php8.2-mbstring php8.2-dom php8.2-zip php8.2-curl php8.2-redis php8.2-gd php8.2-intl php8.2-bcmath php8.2-mysql zip unzip


# Install Apache2 web server
sudo apt install apache2 -y

# Enable mod_rewrite for URL rewriting (essential for Laravel)
sudo a2enmod rewrite -y

# Restart Apache2 to apply changes
sudo systemctl restart apache2

echo "PHP 8.2 installation complete!"
echo "To verify PHP version, run: php -m"
echo "To test Apache2, open http://localhost in your web browser."

cd /usr/bin
install composer globally -y
curl -sS https://getcomposer.org/installer | sudo php -q
sudo mv composer.phar composer

#Install git and clone laravel application
sudo apt install git -y
cd /var/www/
sudo git clone https://github.com/laravel/laravel.git
sudo chown -R $USER:$USER /var/www/laravel
cd laravel/

#Install laravel dependencies
install composer autoloader
composer install --optimize-autoloader --no-dev --no-interaction
composer update --no-interaction

# Set up Laravel environment file
sudo cp .env.example .env
sudo chown -R www-data storage
sudo chown -R www-data bootstrap/cache

# Configure Apache virtual host
cd ~
cd /etc/apache2/sites-available/
sudo touch laravel.conf
sudo echo '<VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/laravel/public

    <Directory /var/www/laravel>
        AllowOverride All
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/laravel-error.log
    CustomLog ${APACHE_LOG_DIR}/laravel-access.log combined
</VirtualHost>' | sudo tee /etc/apache2/sites-available/laravel.conf

sudo a2dissite 000-default.conf
sudo a2ensite laravel.conf
sudo systemctl restart apache2
cd

#Install mysql
sudo apt install mysql-server -y
sudo apt install mysql-client -y
sudo systemctl start mysql


# Secure MySQL Installation
sudo mysql -uroot -e "CREATE DATABASE Laravel;"
sudo mysql -uroot -e "CREATE USER 'olayinka'@'localhost' IDENTIFIED BY 'olayinka';"
sudo mysql -uroot -e "GRANT ALL PRIVILEGES ON Laravel.* TO 'olayinka'@'localhost';"
cd /var/www/laravel

#Set up Laravel environment
sudo sed -i "23 s/^#//g" /var/www/laravel/.env
sudo sed -i "24 s/^#//g" /var/www/laravel/.env
sudo sed -i "25 s/^#//g" /var/www/laravel/.env
sudo sed -i "26 s/^#//g" /var/www/laravel/.env
sudo sed -i "27 s/^#//g" /var/www/laravel/.env
sudo sed -i '22 s/=sqlite/=mysql/' /var/www/laravel/.env
sudo sed -i '23 s/=127.0.0.1/=localhost/' /var/www/laravel/.env
sudo sed -i '25 s/=laravel/=Laravel/' /var/www/laravel/.env
sudo sed -i '26 s/=root/=olayinka/' /var/www/laravel/.env
sudo sed -i '27 s/=/=olayinka/' /var/www/laravel/.env

# Generate Laravel application key
sudo php artisan key:generate
sudo php artisan storage:link
sudo php artisan migrate
sudo php artisan db:seed

sudo systemctl restart apache2
