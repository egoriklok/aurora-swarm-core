import { createRequire } from "node:module";

const require = createRequire(import.meta.url);
const { Client } = require("./.vector-test/node_modules/pg");

const connectionString =
  "postgresql://postgres:qtp7qlkv@aurora-db-postgresql.ns-i2ab7ngu.svc:5432";

const createExtensionSql = "CREATE EXTENSION IF NOT EXISTS vector;";
const selectVersionSql =
  "SELECT extversion FROM pg_extension WHERE extname = 'vector';";

const client = new Client({
  connectionString,
});

try {
  await client.connect();

  const createResult = await client.query(createExtensionSql);
  const versionResult = await client.query(selectVersionSql);

  console.log(createExtensionSql);
  console.log(
    JSON.stringify(
      {
        command: createResult.command,
        rowCount: createResult.rowCount,
      },
      null,
      2,
    ),
  );
  console.log(selectVersionSql);
  console.log(JSON.stringify(versionResult.rows, null, 2));
} catch (error) {
  console.error(error?.stack ?? String(error));
  process.exitCode = 1;
} finally {
  await client.end().catch(() => {});
}
