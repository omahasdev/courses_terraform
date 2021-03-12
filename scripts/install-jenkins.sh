wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > \
    /etc/apt/sources.list.d/jenkins.list'

apt-get update
apt-get install -y jenkins

systemctl enable jenkins
systemctl start jenkins

# print password file
PASSWORD_FILE=/var/lib/jenkins/secrets/initialAdminPassword

until [ -s $PASSWORD_FILE ]
do
     sleep 1
done

echo "=========================================================================="
echo "Jenkins initial password:"
cat $PASSWORD_FILE
echo "=========================================================================="
