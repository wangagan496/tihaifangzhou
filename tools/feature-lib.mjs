import fs from 'node:fs';
import path from 'node:path';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const deveco = process.env.DEVECO_HOME || 'C:/Huawei/DevEco Studio';
export const ts = require(path.join(deveco, 'tools/hvigor/hvigor/node_modules/typescript'));
export const json5 = require(path.join(deveco, 'tools/hvigor/hvigor-ohos-plugin/node_modules/json5'));
export const sourceRoot = 'entry/src/main/ets/';

export function references(file, source) {
  const imports = ts.preProcessFile(source, true, true).importedFiles
    .map((item) => item.fileName).filter((name) => name.startsWith('.'))
    .map((name) => path.posix.normalize(path.posix.join(path.posix.dirname(file), name)));
  const routes = [];
  const scanner = ts.createScanner(ts.ScriptTarget.Latest, true, ts.LanguageVariant.Standard, source);
  for (let token = scanner.scan(); token !== ts.SyntaxKind.EndOfFileToken; token = scanner.scan()) {
    if (token === ts.SyntaxKind.StringLiteral && /^pages\/[A-Za-z0-9_]+$/.test(scanner.getTokenValue())) {
      routes.push(scanner.getTokenValue());
    }
  }
  return { imports, routes: [...new Set(routes)] };
}

export function resolveImport(name, available) {
  const result = [name, `${name}.ets`, `${name}.ts`, `${name}/index.ets`].find((candidate) => available.has(candidate));
  if (!result) throw new Error(`Unresolved relative import: ${name}`);
  return result;
}

export function safePath(root, relative) {
  const absolute = path.resolve(root, relative);
  if (!absolute.startsWith(path.resolve(root) + path.sep)) throw new Error(`Path outside workspace: ${relative}`);
  return absolute;
}

export function write(root, relative, content) {
  const absolute = safePath(root, relative);
  fs.mkdirSync(path.dirname(absolute), { recursive: true });
  fs.writeFileSync(absolute, content);
}
