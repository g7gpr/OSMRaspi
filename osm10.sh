#!/bin/bash
#Based on 
#https://www.linuxbabe.com/debian/openstreetmap-osm-tile-server-debian-10-buster

echo $HOSTNAME ": Starting openstreetmap server installation Raspberry pi"

#Step 0  Upgrade and install


sudo apt -y update 
sudo apt -y upgrade
echo $HOSTNAME  ": Install dependancies Part 1/6"
apt-get install -qq git postgresql postgresql-contrib postgis postgresql-11-postgis-2.5 osm2pgsql
echo $HOSTNAME  ": Install dependancies Part 2/6"
apt-get install -qq autoconf libtool libmapnik-dev apache2-dev psmisc acl
echo $HOSTNAME  ": Install dependancies Part 3/6"
apt-get install -qq build-essential autoconf libcairo2-dev libcurl4-gnutls-dev libiniparser-dev
echo $HOSTNAME "Install dependancies Part 4/6"
apt-get install -qq curl unzip gdal-bin mapnik-utils libmapnik-dev python3-pip python3-psycopg2
echo $HOSTNAME "Install dependancies Part 5/6"
apt-get install -qq ttf-dejavu apache2
echo $HOSTNAME "Install dependancies Part 6/6"
apt-get install -qq fonts-noto-cjk fonts-noto-cjk-extra fonts-noto-hinted fonts-noto-unhinted ttf-unifont
pip3 install pyyaml
sudo systemctl start postgresql@11-main
sudo pg_lsclusters
echo $HOSTNAME "All dependancies installed"
echo $HOSTNAME "Deploying configuration files"
cp renderd.service      /etc/systemd/system/renderd.service
cp 000-default.conf     /etc/apache2/sites-enabled/000-default.conf
cp renderd.conf.apache  /etc/apache2/conf-available/renderd.conf
cp renderd.conf         /etc/renderd.conf
cp mod_tile.load        /etc/apache2/mods-available
tar -cf www.tar www/
cp www.tar              /var/
rm www.tar
cd /var
sudo tar -xf www.tar
sudo rm www.tar
sudo mkdir -p /var/cache/renderd/tiles
sudo chown osm /var/cache/renderd/tiles

#Step 1  Tidy up any previous installations

echo $HOSTNAME "Step 1  Tidy up any previous installations"


killall -u osm
userdel osm
rm -rf /home/osm
sudo -u postgres -i -- sh -c "dropdb gis; dropuser osm; createuser osm; createdb -E UTF8 -O osm gis;"

#Step 2  Install PostgresSQL Database Server and the PostGIS Extension

echo $HOSTNAME "Step 2  Install PostgresSQL Database Server and the PostGIS Extension"

sudo -u postgres -i psql -d gis -c "CREATE EXTENSION postgis; CREATE EXTENSION hstore; ALTER TABLE spatial_ref_sys OWNER TO osm;"
sudo adduser --system osm

#Step 3  Download Map Stylesheet and Map Data

echo $HOSTNAME "Step 3  Download Map Stylesheet and Map Data"

cd /home/osm

until [ -d openstreetmap-carto ]
do
 echo "Cloning openstreetmap-carto"
 sudo -u osm git clone https://github.com/gravitystorm/openstreetmap-carto.git
 if [[ -d openstreetmap-carto ]]
  then 
   echo "Cloned openstreetmap-carto" 
  else
   echo "Retrying after a delay"
   sleep 23
 fi
done

wget -c http://192.168.1.230/australia-latest.osm.pbf

#Step 4  Optimize PostgreSQL

echo $HOSTNAME "Step 4  Optimize PostgreSQL"

#Not required at this stage

#Step 5  Import the map data to PostgreSQL

echo $HOSTNAME "Step 5  Import the map data to PostgreSQL"

setfacl -R -m u:david:rwx /home/osm
sudo -u postgres -i -- sh -c "osm2pgsql --slim -d gis --hstore --multi-geometry --number-processes 1 --tag-transform-script /home/osm/openstreetmap-carto/openstreetmap-carto.lua --style /home/osm/openstreetmap-carto/openstreetmap-carto.style -C 250 /home/osm/australia-latest.osm.pbf"
sudo -u postgres -i -- sh -c 'psql -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO osm;" -d gis'

#Step 6   Install mod_tile and Renderd

echo $HOSTNAME "Step 6   Install mod_tile and Renderd"

cd /home/osm
sudo rm -rf mod_tile
until [ -d mod_tile ]
do
 echo "Cloning mod_tile"
 sudo -u osm git clone https://github.com/openstreetmap/mod_tile.git
 if [[ -d mod_tile ]]
  then 
   echo "Cloned mod_tile" 
  else
   echo "Retrying after a delay"
   sleep 23
 fi
done
echo "Cloned mod_tile"
cd mod_tile/
sudo -u osm ./autogen.sh
sudo -u osm ./configure
sudo -u osm make
sudo make install
sudo make install-mod_tile
sudo systemctl stop apache2
sudo a2enmod mod_tile
sudo a2enconf renderd
sudo rm -rf /var/run/renderd
mkdir /var/run/renderd
hown osm /var/run/renderd
sudo mkdir -p /var/lib/mod_tile
sudo chown osm /var/lib/mod_tile -R
sudo apache2ctl restart
sudo systemctl restart apache2


#Step 7   Generate Mapnik Stylesheet

echo $HOSTNAME "Step 7   Generate Mapnik Stylesheet"

curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
apt-get install -y nodejs
npm install -g carto
sudo -H pip3 install pyyaml
chown -R postgres /home/osm/openstreetmap-carto
sudo -u postgres -i -- sh -c "cd /home/osm/openstreetmap-carto/; scripts/get-external-data.py; carto project.mml > style.xml"
sudo -u postgres -i psql -d gis -c "GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO osm;" 


#Step 8   Install fonts

echo $HOSTNAME "Step 8   Install fonts"

#No work required here all done at Step 0

#Step 9   Configure renderd

#No work required here all done at Step 0

#Step 9   Restart everything

echo $HOSTNAME "Step 9   daemon-reload and restart renderd"

sudo systemctl daemon-reload
sudo systemctl enable renderd
sudo systemctl restart renderd

#Step 10  Configure Apache

echo $HOSTAME "Step 10   Configure Apache"

sudo apache2ctl restart
