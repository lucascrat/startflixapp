const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

const data = JSON.parse(fs.readFileSync(path.join(__dirname, 'migration_data.json'), 'utf8'));

// Use environment variable or internal Coolify host
const connectionString = process.env.DATABASE_URL || 'postgres://postgres:zCFVDGqdykKiwPi78aup96Sunk3xeT2tkqZ2osHLgXzGBqd9cna43Ht2UMOOBeEu@y8aiq8cbnhyvqghbv6gxprvf:5432/postgres';

const client = new Client({
    connectionString: connectionString,
    ssl: false // Internal connection doesn't need SSL usually
});

async function run() {
    try {
        console.log("Connecting to database...");
        await client.connect();
        console.log("Connected successfully!");

        console.log("Creating schema startflix...");
        await client.query("CREATE SCHEMA IF NOT EXISTS startflix;");

        for (const tableName in data.schema) {
            console.log(`Processing table ${tableName}...`);
            const columns = data.schema[tableName];
            const colDefs = columns.map(c => {
                let def = `"${c.column_name}" ${c.data_type}`;
                if (c.is_nullable === 'NO') def += " NOT NULL";
                if (c.column_default && !c.column_default.includes('nextval')) {
                    def += ` DEFAULT ${c.column_default}`;
                }
                return def;
            }).join(', ');

            await client.query(`DROP TABLE IF EXISTS startflix."${tableName}" CASCADE;`);
            await client.query(`CREATE TABLE startflix."${tableName}" (${colDefs});`);

            const rows = data.data[tableName];
            if (rows && rows.length > 0) {
                console.log(`Inserting ${rows.length} rows into ${tableName}...`);
                for (const row of rows) {
                    const keys = Object.keys(row);
                    const values = Object.values(row);
                    const placeholders = keys.map((_, i) => `$${i + 1}`).join(', ');
                    const sql = `INSERT INTO startflix."${tableName}" ("${keys.join('", "')}") VALUES (${placeholders})`;
                    await client.query(sql, values);
                }
            }
        }

        console.log("Migration finished successfully!");
        // Keep process alive for a bit so we can see logs
        setTimeout(() => process.exit(0), 5000);
    } catch (err) {
        console.error("Migration failed:", err);
        process.exit(1);
    }
}

run();
