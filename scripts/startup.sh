# Mount Data Disk 
# Format disk sdb
directory=/mnt/disks/data

if [ ! -d $directory ]; then
      sudo mkfs.ext4 -m 0 -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdb

      # Make data directory 
      sudo mkdir -p /mnt/disks/data

      # Mount disk to directory 
      sudo mount -o discard,defaults /dev/sdb /mnt/disks/data

      # Grant read/write permissions to all users 
      sudo chmod a+w /mnt/disks/data

      # Get UUID of sdb disk and create uuid variable containing string to add to /etc/fstab
      uuid="UUID-\"$(sudo blkid /dev/sdb -s UUID -o value)\" /mnt/disks/data ext4 discard,defaults,nofail 0 2"
      echo $uuid | sudo tee -a /etc/fstab
fi




# Create Zabbix Docker Network 

docker network create --subnet 172.20.0.0/16 --ip-range 172.20.240.0/20 zabbix-net

# Start emply MySql instance 

docker run --name mysql-server -t \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="zabbix_pwd" \
      -e MYSQL_ROOT_PASSWORD="root_pwd" \
      --network=zabbix-net \
      -d mysql:8.0 \
      --restart unless-stopped \
      --character-set-server=utf8 --collation-server=utf8_bin \
      --default-authentication-plugin=mysql_native_password

# Start Zabbix Server instance and link with MySql Instance 

docker run --name zabbix-server-mysql -t \
      -e DB_SERVER_HOST="mysql-server" \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="zabbix_pwd" \
      -e MYSQL_ROOT_PASSWORD="root_pwd" \
      -e ZBX_JAVAGATEWAY="zabbix-java-gateway" \
      --network=zabbix-net \
      -p 10051:10051 \
      --restart unless-stopped \
      -d zabbix/zabbix-server-mysql:alpine-6.2-latest

# Start Zabbix Web Interface and link with the Zabbix Server and MySql instances 

docker run --name zabbix-web-nginx-mysql -t \
      -e ZBX_SERVER_HOST="zabbix-server-mysql" \
      -e DB_SERVER_HOST="mysql-server" \
      -e MYSQL_DATABASE="zabbix" \
      -e MYSQL_USER="zabbix" \
      -e MYSQL_PASSWORD="zabbix_pwd" \
      -e MYSQL_ROOT_PASSWORD="root_pwd" \
      --network=zabbix-net \
      -p 80:8080 \
      --restart unless-stopped \
      -d zabbix/zabbix-web-nginx-mysql:alpine-6.2-latest