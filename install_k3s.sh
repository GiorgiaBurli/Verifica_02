
#!/bin/bash

# Aggiorna pacchetti del sistema
sudo apt update -y && sudo apt upgrade -y

# Installa Docker
echo "Installazione Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh    # Scarica script ufficiale di installazione Docker
sudo sh get-docker.sh                                 # Esegue lo script per installare Docker

# Abilita Docker all'avvio del sistema e aggiunge l'utente corrente al gruppo docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Installa K3s configurato per usare Docker come runtime container
echo "Installazione K3s..."
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="--docker" sh -

# Verifica che il nodo sia attivo
sudo kubectl get nodes

# Spostati nella cartella dell'applicazione o esci se non esiste
cd ~/app || exit 1

# Costruisce l'immagine Docker dell'app
echo "Costruzione immagine Docker..."
sudo docker build -t hello-docker .

# Crea file YAML con Deployment e Service Kubernetes
cat <<EOF > deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-docker-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: hello-docker
  template:
    metadata:
      labels:
        app: hello-docker
    spec:
      containers:
      - name: hello-docker
        image: hello-docker
        imagePullPolicy: Never
        ports:
        - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: hello-docker-service
spec:
  type: NodePort
  selector:
    app: hello-docker
  ports:
    - protocol: TCP
      port: 3000
      targetPort: 3000
      nodePort: 30080
EOF

# Applica il deployment alla cluster K3s
echo "Deploy su K3s..."
sudo kubectl apply -f deployment.yaml

# Messaggio finale
echo "App deployata! Accedi da: http://<IP_PUBBLICO>:30080"
