# openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt
openssl genrsa -out /etc/nginx/ssl/nginx.key 4096
sudo openssl req -new -key /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt
expect "Country Name (2 letter code) [AU]:"
send "US\n"
expect "State or Province Name (full name) [Some-State]:"
send "New Jersey\n"
expect "Locality Name (eg, city) []:"
send "Clementon\n"
expect "Organization Name (eg, company) [Internet Widgits Pty Ltd]:"
send "NCSU\n"
expect "Organizational Unit Name (eg, section) []:"
send "DevOps\n"
expect "Common Name (e.g. server FQDN or YOUR name) []:"
send "192.168.33.10\n"
expect "Email Address []:"
send "akhan7@ncsu.edu\n"

