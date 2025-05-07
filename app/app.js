
// Importa il modulo express
const express = require('express');

// Crea un'applicazione Express
const app = express();

// Definisce la porta su cui l'applicazione ascolterà
const port = 3000;

// Definisce una route per la root '/' che risponde con "Hello, World!"
app.get('/', (req, res) => {
    res.send('Hello, World!');
});

// Avvia il server e lo mette in ascolto sulla porta specificata
app.listen(port, () => {
    console.log(`App listening at http://localhost:${port}`);
});
