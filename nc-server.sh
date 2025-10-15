#!/bin/sh
# kubectl delete -n phx-local configmap grafana-static-datasource-webserver; kubectl create -n phx-local configmap grafana-static-datasource-webserver --from-file=webserver.sh

mkdir -p /tmp/htdocs
cd /tmp/htdocs

cat <<\EOF >niederlassungen.csv
"city","city_ascii","lat","lng","country","iso2","iso3","admin_name","capital","population","id"
"Berlin","Berlin","52.5200","13.4050","Germany","DE","DEU","Berlin","primary","4890363","1276451290"
"Düsseldorf","Dusseldorf","51.2333","6.7833","Germany","DE","DEU","North Rhine-Westphalia","admin","629047","1276615258"
"München","Munich","48.1375","11.5750","Germany","DE","DEU","Bavaria","admin","2606021","1276692352"
"Hamburg","Hamburg","53.5500","10.0000","Germany","DE","DEU","Hamburg","admin","2484800","1276041799"
EOF

echo -e "proudly serving files:\n\n$(find ./ -type f | sed "s/^\./      /g" | sort)\n\n"

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
