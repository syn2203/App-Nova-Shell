#!/usr/bin/env node

const fs = require('node:fs/promises');
const path = require('node:path');
const process = require('node:process');
const {generateApi} = require('swagger-typescript-api');

const DEFAULT_OUTPUT_DIR = 'src/api/generated';

const schemaSource =
  process.argv[2] ||
  process.env.API_SCHEMA_URL ||
  process.env.OPENAPI_URL ||
  process.env.SWAGGER_URL;

const outputDirArg =
  process.argv[3] || process.env.API_OUTPUT_DIR || DEFAULT_OUTPUT_DIR;
const outputDir = path.resolve(process.cwd(), outputDirArg);

async function main() {
  if (!schemaSource) {
    console.error('Missing OpenAPI schema source.');
    console.error('Usage: npm run api:generate -- <schema-url-or-file> [output-dir]');
    console.error('You can also set API_SCHEMA_URL / OPENAPI_URL / SWAGGER_URL.');
    process.exit(1);
  }

  const isRemoteSource = /^https?:\/\//i.test(schemaSource);
  const sourceConfig = isRemoteSource
    ? {url: schemaSource}
    : {input: path.resolve(process.cwd(), schemaSource)};

  await fs.mkdir(outputDir, {recursive: true});

  await generateApi({
    ...sourceConfig,
    output: outputDir,
    name: 'Api.ts',
    httpClientType: 'axios',
    generateClient: true,
    singleHttpClient: true,
    extractRequestBody: true,
    extractRequestParams: true,
    extractResponseBody: true,
    extractResponseError: true,
    extractResponses: true,
    generateRouteTypes: true,
    enumNamesAsValues: true,
    sortRoutes: true,
    sortTypes: true,
    patch: true,
    cleanOutput: true,
  });

  await fs.writeFile(path.join(outputDir, 'index.ts'), "export * from './Api';\n", 'utf8');

  console.log(`[api:generate] source: ${schemaSource}`);
  console.log(`[api:generate] output: ${outputDir}`);
}

main().catch(error => {
  console.error('[api:generate] failed');
  console.error(error);
  process.exit(1);
});
