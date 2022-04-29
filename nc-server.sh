cat<<\EOF>/tmp/websphere
#!/bin/sh
file=/tmp$(head -n1 <&0|cut -f2 -d" ") # first line from stdin (GET /path HTTP/1.1), parse out the path
test -e ${file} || file=/tmp/index.html

# on purpose this convoluted as this won't count trailing newlines (which are ommited below)
length=$(echo $(cat ${file})|wc -c)

printf "HTTP/1.1 200 OK \nContent-Length: ${length}\n\n$(cat ${file})\n"
EOF

nc -lk -s 0.0.0.0 -p 80 -e "/tmp/websphere"
