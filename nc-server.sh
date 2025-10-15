#!/bin/sh

mkdir -p /tmp/htdocs && cd /tmp/htdocs

# create our files
cat <<\EOF >foo.json
{
  "foo": "bar"
}
EOF

cat <<\EOF >cities.csv
"city","city_ascii","lat","lng","country","iso2","iso3","admin_name","capital","population","id"
"Tokyo","Tokyo","35.6897","139.6922","Japan","JP","JPN","Tōkyō","primary","37732000","1392685764"
"Jakarta","Jakarta","-6.1750","106.8275","Indonesia","ID","IDN","Jakarta","primary","33756000","1360771077"
"Delhi","Delhi","28.6100","77.2300","India","IN","IND","Delhi","admin","32226000","1356872604"
"Guangzhou","Guangzhou","23.1300","113.2600","China","CN","CHN","Guangdong","admin","26940000","1156237133"
EOF

##########################################################
# create our web framework
cat <<\EOF >/tmp/websphere-ng
#!/bin/sh
file=/tmp/htdocs$(head -n1 <&0|cut -f2 -d" ") # first line from stdin (GET /path HTTP/1.1), parse out the path

length=$(echo "$(cat ${file})" | wc -c)

test -e ${file} &&
  printf "HTTP/1.1 200 OK \nContent-Length: ${length}\n\n$(cat ${file})\n" ||
  printf "HTTP/1.1 404 Not Found \nContent-Length: 10\n\nnot found\n"

EOF

chmod +x /tmp/websphere-ng

set -x
exec nc -lk -s 0.0.0.0 -p ${PORT:-80} -e "/tmp/websphere-ng"
