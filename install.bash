#!/bin/bash
RED="\e[31m" GREEN="\e[32m" ENDCOLOR="\e[0m" 
echo -e "${GREEN}[+] Select installation method: ${ENDCOLOR}"
PS3='Please enter your choice: '
options=("Collector" "Sensor" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Collector")
            echo "You chose Collector installation"
			echo "Stop TPOT service"
			service tpot stop
			sleep 5
			echo
			echo -e "${GREEN}[+] Copying files, please wait${ENDCOLOR}"
			echo -e "${RED}------------------------------${ENDCOLOR}"
			cp -r logstash_collector/ /opt/tpot/docker/elk/
			ls -la /opt/tpot/docker/elk/ | grep logstash_collector
			sleep 3
			echo -e "${GREEN}[+] Copying docker compose files, please wait${ENDCOLOR}"
			echo -e "${RED}------------------------------${ENDCOLOR}"
			cp collector.yml /opt/tpot/etc/compose/collector.yml
			ls -la /opt/tpot/etc/compose/collector.yml
			echo -e "${GREEN}[+] Generating certificate!${ENDCOLOR}"
			echo -e "${RED}---------------${ENDCOLOR}"
			openssl req -x509 -batch -nodes -newkey rsa:2048 -keyout tpot.key -out tpot.crt -days 1095
			cp tpot.key /opt/tpot/docker/elk/logstash_collector/dist/
			cp tpot.crt /opt/tpot/docker/elk/logstash_collector/dist/
			rm tpot.key
			rm tpot.crt
			ls -la /opt/tpot/docker/elk/logstash_collector/dist/tpot.key
			ls -la /opt/tpot/docker/elk/logstash_collector/dist/tpot.crt
			echo -e "${GREEN}[+] Building docker!${ENDCOLOR}"
			echo -e "${RED}---------------${ENDCOLOR}"
			docker image build -t logstash_collector:latest /opt/tpot/docker/elk/logstash_collector/
			docker image ls | grep logstash_collector
			echo -e "${GREEN}[+] All done!${ENDCOLOR}"
			echo -e "${RED}---------------${ENDCOLOR}"
			
			break
            ;;
        "Sensor")
            echo "You chose Sensor installation"
			echo "Stop TPOT service"
			service tpot stop
			sleep 5
			echo
			echo -e "${GREEN}[+] Copying logstash_sensor container, please wait${ENDCOLOR}"
			echo -e "${RED}------------------------------${ENDCOLOR}"
			cp -r logstash_sensor/ /opt/tpot/docker/elk/
			ls -la /opt/tpot/docker/elk/ | grep logstash_sensor
			sleep 3
			echo -e "${GREEN}[+] Copying Certificate file (from /tmp/tpot.crt), please wait${ENDCOLOR}"
			echo -e "${RED}------------------------------${ENDCOLOR}"
			cp /tmp/tpot.crt /opt/tpot/docker/elk/logstash_sensor/dist/
			ls -la /opt/tpot/docker/elk/logstash_sensor/dist/tpot.crt
			echo -e "${GREEN}[+] Removing /tmp/tpot.crt, please wait${ENDCOLOR}"
			rm /tmp/tpot.crt
			echo -e "${GREEN}[+] Copying docker compose files, please wait${ENDCOLOR}"
			echo -e "${RED}------------------------------${ENDCOLOR}"
			cp sensor.yml /opt/tpot/etc/compose/sensor.yml
			ls -la /opt/tpot/etc/compose/sensor.yml
			filename="/opt/tpot/docker/elk/logstash_sensor/dist/logstash.conf"
			default="0.0.0.0"
			# Take the replace string
			read -p "Collector IP address: " replace

			if [[ $default != "" && $replace != "" ]]; then
			sed -i "s/$default/$replace/gi" $filename
			fi
			docker image build -t logstash_sensor:latest /opt/tpot/docker/elk/logstash_sensor/
			docker image ls | grep logstash_sensor
			
			echo -e "${GREEN}[+] All done!${ENDCOLOR}"
			echo -e "${RED}---------------${ENDCOLOR}"
			echo
			break
			;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
