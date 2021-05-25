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
			sleep 3
			echo

			echo -e "${GREEN}[+] Copying docker compose files, please wait${ENDCOLOR}"
			echo -e "${RED}------------------------------${ENDCOLOR}"
			cp collector.yml /opt/tpot/etc/compose/collector.yml
			echo

			echo -e "${GREEN}[+] All done!${ENDCOLOR}"
			echo -e "${RED}---------------${ENDCOLOR}"
			echo
			break
            ;;
        "Sensor")
            echo "You chose Sensor installation"
			echo "Stop TPOT service"
			service tpot stop
			sleep 5
			echo
			echo -e "${GREEN}[+] Copying files, please wait${ENDCOLOR}"
			echo -e "${RED}------------------------------${ENDCOLOR}"
			cp -r logstash_sensor/ /opt/tpot/docker/elk/
			sleep 3
			echo

			echo -e "${GREEN}[+] Copying docker compose files, please wait${ENDCOLOR}"
			echo -e "${RED}------------------------------${ENDCOLOR}"
			cp sensor.yml /opt/tpot/etc/compose/sensor.yml
			echo

			filename="/opt/tpot/docker/elk/logstash_sensor/dist/logstash.conf"
			default="0.0.0.0"
			# Take the replace string
			read -p "Collector IP address: " replace

			if [[ $default != "" && $replace != "" ]]; then
			sed -i "s/$default/$replace/gi" $filename
			fi

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
