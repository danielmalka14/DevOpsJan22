curl -X POST -H 'Content-Type: application/json' -d '{"clientVersion": "3.2","message": "Client Hello"}' http://devops-jan22-1273001359.eu-north-1.elb.amazonaws.com:8080/clienthello -o fromserver.json
sudo apt install jq
SESSION_ID=$(jq -r '.sessionID' fromserver.json)
jq -r '.serverCert' fromserver.json > cert.pem
wget https://devops-jan22.s3.eu-north-1.amazonaws.com/cert-ca-aws.pem
openssl verify -CAfile cert-ca-aws.pem cert.pem
# cert.pem: OK
head -c 32 /dev/urandom > masterKey.txt
MASTER_KEY=$(openssl smime -encrypt -aes-256-cbc -in masterKey.txt -outform DER cert.pem | base64 -w 0)
curl -X POST -H 'Content-Type: application/json' -d '{"sessionID": "'$SESSION_ID'","masterKey": "'$MASTER_KEY'","sampleMessage": "Hi server, please encrypt me and send to client!"}' http://devops-jan22-1273001359.eu-north-1.elb.amazonaws.com:8080/keyexchange -o encryptfromserver.txt