sudo docker stop cta-mongo
sudo docker stop cta-mysql
sudo docker rm cta-mongo
sudo docker rm cta-mysql
sudo docker ps -a
cd ~/shukun
sudo rm -rf *
wget --http-user=devops1 --http-password=skdev0ps! http://103.211.47.132:99/delivering-toolset/0.0.1/delivering-toolset-0.0.1.tar.gz && tar -xzvf delivering-toolset-0.0.1.tar.gz && chmod u+x delivering-toolset/common/*.sh && sudo ./delivering-toolset/chd-ai/install.sh
