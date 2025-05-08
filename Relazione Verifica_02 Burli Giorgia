**Relazione Tecnica – Burli Giorgia**

**Obiettivo del Progetto**

L'obiettivo dell'esercitazione è stato quello di effettuare il deploy di
una semplice applicazione Node.js utilizzando Docker e K3s su una VM
creata su Microsoft Azure, gestendo l'infrastruttura con Terraform.
L'applicazione doveva rispondere con "Hello, World!" ed essere
accessibile via browser all'indirizzo pubblico della macchina.

Inoltre, su indicazione successiva del docente, si è previsto che la VM
fosse una sola anziché tre, ma che il pod fosse replicato tre volte
(replica di tipo Deployment).

**1. Preparazione Ambiente Terraform**

Si è creata la cartella Verifica\_02 con i file seguenti:

-   main.tf: provider, resource group, rete, subnet, NSG, IP pubblico,
    NIC, macchina virtuale-> https://github.com/GiorgiaBurli/Verifica_02/blob/main/main.tf

-   variables.tf: contiene variabili riutilizzabili-> https://github.com/GiorgiaBurli/Verifica_02/blob/main/variables.tf

-   outputs.tf: stampa IP pubblico della VM-> https://github.com/GiorgiaBurli/Verifica_02/blob/main/outputs.tf

Nota: si è scelto di usare variables.tf e non terraform.tfvars perché i
valori non variavano tra ambienti.

**Comandi eseguiti:**

terraform init

terraform plan

terraform apply

**Errore riscontrato:**

Error: unable to build authorizer for Resource Manager API: could not
configure AzureCli Authorizer

**Soluzione:**

az login

Dopo l'autenticazione, terraform apply ha restituito l’IP pubblico:

**Outputs:**

public\_ip\_address = "xxx.xxx.xx.xxx"

**2. Generazione e gestione chiavi SSH**

Poiché la cartella .ssh non esisteva, si è eseguito:

ssh-keygen

Confermato percorso suggerito C:\\Users\\user\\.ssh\\id\_ed25519.
Verifica:

dir C:\\Users\\user\\.ssh

**3. Connessione alla VM**

Da PowerShell:

ssh -i C:\\Users\\user\\.ssh\\id\_ed25519 azureuser@publicIP

Alla richiesta Are you sure you want to continue connecting? si è
risposto yes.

**4. Creazione dei file applicativi**

In Visual Studio Code, nella cartella Verifica\_02 si è creata la
sottocartella app/ con:

**app.js**: https://github.com/GiorgiaBurli/Verifica_02/blob/main/app/app.js


**package.json**:https://github.com/GiorgiaBurli/Verifica_02/blob/main/app/package.json


**Dockerfile**: https://github.com/GiorgiaBurli/Verifica_02/blob/main/app/Dockerfile

**5. Trasferimento file nella VM**

Compressione e invio dell'app:

Compress-Archive -Path .\\app\\\* -DestinationPath .\\app.zip

scp -i \~/.ssh/id\_ed25519 app.zip azureuser@172.publicIP:\~

Invio dello script di installazione:

scp -i \~/.ssh/id\_ed25519 install\_k3s.sh azureuser@172.pubblicIP:\~

**6. Installazione Docker, K3s e Deploy automatico**

Nella VM:

chmod +x install\_k3s.sh

sudo ./install\_k3s.sh

**Errore riscontrato:**

cd: /home/azureuser/app: No such file or directory

**Soluzione:**

unzip app.zip

mv app \~/app

cd \~/app

**Costruzione immagine Docker:**

sudo docker build -t hello-docker .

sudo docker images

**7. Creazione e deploy del deployment.yaml**

**Nella VM:**

nano \~/deployment.yaml

**Contenuto:** https://github.com/GiorgiaBurli/Verifica_02/blob/main/deployment.yaml

nano \~/service.yaml https://github.com/GiorgiaBurli/Verifica_02/blob/main/service.yaml

**Comando:**

sudo kubectl apply -f \~/deployment.yaml
sudo kubectl apply -f \~/service.yaml
sudo kubectl get pods

**8. Configurazione NSG**

Nel file main.tf, il blocco azurerm\_network\_security\_group conteneva
regole per porte 22, 3000 e 30080.

**9. Verifica finale**

**Accesso da browser:**

http://publicIP:30080

**Risultato:**

Hello, World!

**10. Per automatizzare il provisioning della VM, abbiamo inserito nel
file main_2.tf (https://github.com/GiorgiaBurli/Verifica_02/blob/main/main_2.tf)un blocco null\_resource che utilizza i provisioner di
Terraform. Questo ci permette di:**

1.  Copiare automaticamente lo script install\_k3s.sh all'interno della
    VM tramite il file provisioner.

2.  Eseguire lo script subito dopo, usando il remote-exec provisioner.

**Passaggi effettuati:**

1\. Scrittura dello script di installazione

-   Creato il file install\_k3s.sh nella cartella Verifica\_02,
    contenente:

    -   aggiornamento pacchetti

    -   installazione Docker

    -   installazione K3s con flag --docker

    -   costruzione immagine Docker

    -   creazione file deployment.yaml

    -   comando kubectl apply per il deploy

Dopo aver aggiornato main_2.tf e verificato le chiavi SSH, è bastato
eseguire:

terraform apply

Al termine della creazione della VM, Terraform ha:

-   caricato lo script nella home dell’utente

-   reso lo script eseguibile

-   avviato l’installazione completa di Docker, K3s e dell’app

Questo approccio ha permesso di eliminare la necessità di usare scp, ssh
o comandi manuali per ogni nuova VM creata, aumentando l’automazione e
la replicabilità del progetto.

**Riepilogo comandi eseguiti**

**Comandi eseguiti localmente (dal PC - PowerShell/VS Code)**

terraform init

terraform plan

terraform apply

ssh-keygen

dir C:\\Users\\user\\.ssh

ssh -i C:\\Users\\user\\.ssh\\id\_ed25519 azureuser@&lt;IP\_PUBBLICO&gt;

Compress-Archive -Path .\\app\\\* -DestinationPath .\\app.zip

scp -i C:\\Users\\user\\.ssh\\id\_ed25519 install\_k3s.sh
azureuser@&lt;IP\_PUBBLICO&gt;:\~

scp -i C:\\Users\\user\\.ssh\\id\_ed25519 app.zip
azureuser@&lt;IP\_PUBBLICO&gt;:\~

**Comandi eseguiti nella VM (dopo essermi collegata via SSH)**

chmod +x install\_k3s.sh

sudo ./install\_k3s.sh

unzip app.zip

mv app \~/app

cd \~/app

sudo docker build -t hello-docker .

sudo docker images

nano \~/deployment.yaml

sudo kubectl apply -f \~/deployment.yaml

sudo kubectl get pods

sudo kubectl get services

sudo systemctl status k3s

**Conclusione**

L'applicazione è stata deployata con successo. I pod sono stati
replicati 3 volte come da richiesta, e l'app è accessibile via browser.
Tutti i problemi incontrati sono stati risolti durante il lavoro. Ogni
fase è documentata con i comandi PowerShell e Linux effettivamente
utilizzati. Il provisioning automatico tramite provisioner completa un
flusso di lavoro cloud-native ripetibile e scalabile.

**Pubblicazione del progetto su GitHub**

Per pubblicare i file del progetto creato localmente con Visual Studio
Code su GitHub, sono stati seguiti i seguenti passaggi:

**1. Creazione della repository GitHub**

-   Accedere a GitHub e creare una nuova repository pubblica chiamata
    Verifica\_02, **senza** inizializzarla con README o .gitignore (per
    evitare conflitti).

**2. Inizializzazione del progetto Git in locale**

-   Aprire Visual Studio Code nella cartella del progetto:

cd C:\\Users\\user\\OneDrive\\Desktop\\Verifica\_02

code .

-   Inizializzare il repository Git:

git init

**3. Collegamento con la repository GitHub**

-   Aggiungere la repository remota:

git remote add origin https://github.com/GiorgiaBurli/Verifica\_02.git

**4. Creazione del file .gitignore**

-   Nella cartella principale del progetto (Verifica\_02), creare un
    nuovo file chiamato **.gitignore**.-> https://github.com/GiorgiaBurli/Verifica_02/blob/main/.gitignore


**5. Aggiunta e commit dei file**

-   Aggiungere tutti i file tracciabili:

git add .

-   Fare il primo commit:

git commit -m "Caricamento iniziale progetto Verifica\_02"

**6. Impostazione del branch principale**

git branch -M main

**7. Primo push su GitHub**

git push -u origin main

Se si verifica un errore di tipo "non-fast-forward" (repo GitHub già
contiene qualcosa):

1.  Prima fare un pull:

git pull origin main --allow-unrelated-histories

2.  Verrà aperto un editor per confermare il merge:

    -   Premere Esc, poi scrivere :wq e premere Invio per salvare ed
        uscire.

3.  Infine, ripetere il push:

git push -u origin main

**Caricamento del file screenshots.md e delle immagini su GitHub**

Dopo aver salvato localmente tutti gli screenshot nella cartella
screenshots/ all’interno della cartella principale Verifica\_02, si è
proceduto a creare e pubblicare un file .md per documentare visivamente
i passaggi del progetto.

**Passaggi eseguiti:**

1.  **Creazione del file markdown**

    -   In Visual Studio Code, è stato creato il file screenshots.md.

    -   Al suo interno sono stati aggiunti i riferimenti alle immagini:https://github.com/GiorgiaBurli/Verifica_02/blob/main/screenshots.md



1.  **Caricamento manuale del file screenshots.md**

    -   Apertura della repository GitHub:\
        [*https://github.com/GiorgiaBurli/Verifica\_02*](https://github.com/GiorgiaBurli/Verifica_02)

    -   Clic su **“Add file”** → **“Upload files”**

    -   Selezione del file screenshots.md dal PC e **Commit** con
        messaggio:\
        "Aggiunto file screenshots.md con immagini del progetto"

2.  **Caricamento delle immagini**

    -   Sempre dalla repository GitHub, clic su **“Add file”** →
        **“Upload files”**

    -   Trascinati tutti i file .png presenti nella cartella
        screenshots/ locale

    -   Se GitHub richiede di caricarli dentro screenshots/, si accede
        prima alla cartella e poi si fa **“Upload files”**

    -   Eseguito il commit delle immagini

3.  **Verifica finale**

    -   Apertura del file screenshots.md direttamente su GitHub

    -   Tutte le immagini risultano ora **visibili correttamente**\
        perché la cartella screenshots/ è presente nel repository online
