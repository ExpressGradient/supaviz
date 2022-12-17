const { Client } = require("pg");
const { readFileSync } = require("fs");
const { config } = require("dotenv");

config({ path: ".env.local" });

const client = new Client({
    connectionString: process.env.POSTGRES_CONNECTION_STRING,
});

client.connect();

const sqlFile = readFileSync("meta.sql", "utf-8");

client.query(sqlFile, (err, res) => {
    if (err) console.error("Error while setting up SupaViz!!!", err);
    else console.log("SupaViz setup complete!");

    client.end();
});
