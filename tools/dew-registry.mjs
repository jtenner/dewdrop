#!/usr/bin/env bun
import { createHash } from "node:crypto";
import { homedir, tmpdir } from "node:os";
import { dirname, join, relative, resolve } from "node:path";
import { chmod, mkdir, mkdtemp, readFile, readdir, rename, rm, stat, writeFile } from "node:fs/promises";

const repositoryRoot = resolve(import.meta.dir, "..");
const command = process.argv[2] ?? "";
const arguments_ = process.argv.slice(3);

function fail(message, status = 2) {
  console.error(`dew ${command}: ${message}`);
  process.exit(status);
}

function option(name, fallback = "") {
  const index = arguments_.indexOf(name);
  if (index < 0) return fallback;
  if (!arguments_[index + 1] || arguments_[index + 1].startsWith("--")) fail(`${name} requires a value`);
  return arguments_[index + 1];
}

function registryOrigin() {
  const raw = option("--registry", process.env.DEW_REGISTRY_URL ?? "https://drops.dewdrop.sh");
  let url;
  try { url = new URL(raw); } catch { fail("registry must be an absolute URL"); }
  if (url.username || url.password || url.search || url.hash || url.pathname !== "/") fail("registry URL must contain only an origin");
  const local = url.hostname === "localhost" || url.hostname === "127.0.0.1" || url.hostname === "::1";
  if (url.protocol !== "https:" && !(local && url.protocol === "http:")) fail("registry must use HTTPS unless it is local development");
  return url.origin;
}

function configPath() {
  const root = process.env.DEW_CONFIG_HOME || (process.env.XDG_CONFIG_HOME ? join(process.env.XDG_CONFIG_HOME, "dew") : join(homedir(), ".config", "dew"));
  return join(root, "credentials.json");
}

async function readCredentials() {
  try {
    const parsed = JSON.parse(await readFile(configPath(), "utf8"));
    if (parsed?.version === 1 && parsed.registries && typeof parsed.registries === "object") return parsed;
  } catch (error) {
    if (error?.code !== "ENOENT") fail("credentials file is invalid");
  }
  return { version: 1, registries: {} };
}

async function writeCredentials(value) {
  const path = configPath();
  await mkdir(dirname(path), { recursive: true, mode: 0o700 });
  await chmod(dirname(path), 0o700);
  const temporary = `${path}.tmp-${process.pid}`;
  await writeFile(temporary, `${JSON.stringify(value, null, 2)}\n`, { mode: 0o600, flag: "wx" });
  await rename(temporary, path);
  await chmod(path, 0o600);
}

async function responseJson(response) {
  try { return await response.json(); } catch { return {}; }
}

async function login() {
  const registry = registryOrigin();
  const response = await fetch(`${registry}/api/cli/device/start`, {
    method: "POST",
    headers: { "Content-Type": "application/json", "User-Agent": "Dewdrop-CLI/0.1" },
    body: JSON.stringify({ client: "dew" }),
  });
  const flow = await responseJson(response);
  if (!response.ok) fail(flow.error ?? `registry returned ${response.status}`, 1);
  console.log(`Open this URL in your browser:\n\n  ${flow.verification_uri_complete}\n\nConfirm code: ${flow.user_code}`);
  let interval = Math.max(5, Number(flow.interval) || 5);
  const deadline = Date.now() + Math.min(600, Number(flow.expires_in) || 600) * 1_000;
  while (Date.now() < deadline) {
    await Bun.sleep(interval * 1_000);
    const tokenResponse = await fetch(`${registry}/api/cli/device/token`, {
      method: "POST",
      headers: { "Content-Type": "application/json", "User-Agent": "Dewdrop-CLI/0.1" },
      body: JSON.stringify({ device_code: flow.device_code }),
    });
    const token = await responseJson(tokenResponse);
    if (tokenResponse.ok) {
      const credentials = await readCredentials();
      credentials.registries[registry] = { token: token.access_token, username: token.username, expiresAt: new Date(Date.now() + token.expires_in * 1_000).toISOString() };
      await writeCredentials(credentials);
      console.log(`Authenticated to ${registry} as @${token.username}.`);
      return;
    }
    if (token.error === "authorization_pending") continue;
    if (token.error === "slow_down") { interval += 5; continue; }
    fail(token.error ?? `registry returned ${tokenResponse.status}`, 1);
  }
  fail("authorization expired before it was approved", 1);
}

async function credentialFor(registry) {
  const credentials = await readCredentials();
  const value = credentials.registries[registry];
  if (!value?.token) fail(`not authenticated to ${registry}; run dew login`, 1);
  return { credentials, value };
}

async function whoami() {
  const registry = registryOrigin();
  const { value } = await credentialFor(registry);
  const response = await fetch(`${registry}/api/cli/me`, { headers: { Authorization: `Bearer ${value.token}`, "User-Agent": "Dewdrop-CLI/0.1" } });
  const result = await responseJson(response);
  if (!response.ok) fail(result.error ?? "stored login is no longer valid", 1);
  console.log(`@${result.username} (${registry})`);
}

async function logout() {
  const registry = registryOrigin();
  const credentials = await readCredentials();
  const token = credentials.registries[registry]?.token;
  if (token) {
    try { await fetch(`${registry}/api/cli/token`, { method: "DELETE", headers: { Authorization: `Bearer ${token}`, "User-Agent": "Dewdrop-CLI/0.1" } }); }
    catch { console.warn("Could not contact the registry; removing the local login only."); }
  }
  delete credentials.registries[registry];
  await writeCredentials(credentials);
  console.log(`Removed the local login for ${registry}.`);
}

async function run(commandLine, options = {}) {
  const child = Bun.spawn(commandLine, { cwd: options.cwd ?? process.cwd(), stdin: "inherit", stdout: options.capture ? "pipe" : "inherit", stderr: "inherit", env: process.env });
  const output = options.capture ? await new Response(child.stdout).text() : "";
  const status = await child.exited;
  if (status !== 0) fail(options.message ?? `${commandLine[0]} failed`, 1);
  return output.trim();
}

async function sourceFiles(packageRoot) {
  const sourceRoot = join(packageRoot, "src");
  const files = [];
  async function collect(directory) {
    const entries = await readdir(directory, { withFileTypes: true });
    entries.sort((left, right) => Buffer.compare(Buffer.from(left.name), Buffer.from(right.name)));
    for (const entry of entries) {
      const path = join(directory, entry.name);
      if (entry.isDirectory()) await collect(path);
      else if (entry.isFile() && entry.name.endsWith(".dew")) files.push(path);
    }
  }
  try {
    if ((await stat(sourceRoot)).isDirectory()) await collect(sourceRoot);
  } catch {
    const entries = await readdir(packageRoot, { withFileTypes: true });
    entries.sort((left, right) => Buffer.compare(Buffer.from(left.name), Buffer.from(right.name)));
    for (const entry of entries) if (entry.isFile() && entry.name.endsWith(".dew")) files.push(join(packageRoot, entry.name));
  }
  if (files.length === 0) fail("package has no conventional .dew sources", 1);
  return files;
}

function u32(value) {
  const bytes = Buffer.alloc(4);
  bytes.writeUInt32LE(value);
  return bytes;
}

function field(value) {
  const bytes = Buffer.isBuffer(value) ? value : Buffer.from(value, "utf8");
  return Buffer.concat([u32(bytes.length), bytes]);
}

async function capsule(manifestPath, source, interfaceFingerprint, integrity) {
  let manifest;
  try { manifest = JSON.parse(await readFile(manifestPath, "utf8")); } catch { fail("dew.json is invalid JSON", 1); }
  if (typeof manifest?.name !== "string" || typeof manifest?.version !== "string" || !manifest.dependencies || typeof manifest.dependencies !== "object" || Array.isArray(manifest.dependencies)) fail("dew.json does not contain a package manifest", 1);
  if (!/^[0-9a-f]{64}$/.test(interfaceFingerprint) || !/^sha256-[0-9a-f]{64}$/.test(integrity)) fail("compiler returned invalid package provenance", 1);
  const packageRoot = dirname(manifestPath);
  const dependencies = Object.entries(manifest.dependencies).sort(([left], [right]) => Buffer.compare(Buffer.from(left), Buffer.from(right)));
  const files = await sourceFiles(packageRoot);
  const parts = [Buffer.from("DEWPKG1\0", "binary"), field(manifest.name), field(manifest.version), field(source), field(integrity), field(interfaceFingerprint), u32(dependencies.length)];
  for (const [name, requirement] of dependencies) {
    if (typeof requirement !== "string") fail(`dependency ${name} requirement is not a string`, 1);
    parts.push(field(name), field(requirement));
  }
  parts.push(u32(files.length));
  for (const path of files) parts.push(field(relative(packageRoot, path).replaceAll("\\", "/")), field(await readFile(path)));
  const payload = Buffer.concat(parts);
  const encoded = Buffer.concat([payload, createHash("sha256").update(payload).digest()]);
  if (encoded.length > 64 * 1_048_576) fail("package capsule exceeds the 64 MiB upload limit", 1);
  return { encoded, manifest };
}

async function publish() {
  const registry = registryOrigin();
  const { value } = await credentialFor(registry);
  const manifestPath = resolve(option("--manifest", join(process.cwd(), "dew.json")));
  const temporary = await mkdtemp(join(tmpdir(), "dew-publish-"));
  try {
    const wasm = join(temporary, "package.wasm");
    console.log("Building and validating the package…");
    await run([join(repositoryRoot, "tools/dew"), "build", "--manifest", manifestPath, "-o", wasm]);
    const abiText = await run(["node", join(repositoryRoot, "tools/dew-abi.mjs"), wasm, "interface"], { capture: true, message: "could not read the compiled package interface" });
    let abi;
    try { abi = JSON.parse(abiText); } catch { fail("compiler emitted invalid interface metadata", 1); }
    const integrity = await run([join(repositoryRoot, "tools/dew"), "package-integrity", manifestPath], { capture: true, message: "could not calculate package integrity" });
    const source = `registry:${registry}`;
    const artifact = await capsule(manifestPath, source, abi.interfaceFingerprint, integrity);
    console.log(`Publishing ${artifact.manifest.name}@${artifact.manifest.version} (${(artifact.encoded.length / 1024).toFixed(1)} KiB)…`);
    const response = await fetch(`${registry}/api/cli/packages`, {
      method: "PUT",
      headers: { Authorization: `Bearer ${value.token}`, "Content-Type": "application/vnd.dewdrop.package-v1", "Content-Length": String(artifact.encoded.length), "User-Agent": "Dewdrop-CLI/0.1" },
      body: artifact.encoded,
    });
    const result = await responseJson(response);
    if (!response.ok) fail(result.error ?? `registry returned ${response.status}`, 1);
    console.log(`Published ${result.name}@${result.version}\n${registry}${result.url}`);
  } finally {
    await rm(temporary, { recursive: true, force: true });
  }
}

if (command === "login") await login();
else if (command === "logout") await logout();
else if (command === "whoami") await whoami();
else if (command === "publish") await publish();
else fail("unsupported registry command");
