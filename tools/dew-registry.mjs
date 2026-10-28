#!/usr/bin/env bun
import { homedir } from "node:os";
import { dirname, join, resolve } from "node:path";
import { chmod, mkdir, readFile, rename, writeFile } from "node:fs/promises";

const repositoryRoot = resolve(import.meta.dir, "..");
const command = process.argv[2] ?? "";
const arguments_ = process.argv.slice(3);

function fail(message, status = 2) {
  const error = new Error(message);
  error.status = status;
  throw error;
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
  const local = url.hostname === "localhost" || url.hostname === "127.0.0.1" || url.hostname === "[::1]";
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
  const child = Bun.spawn(commandLine, { cwd: options.cwd ?? process.cwd(), stdin: "inherit", stdout: options.capture ? "pipe" : "inherit", stderr: "inherit", env: options.env ?? process.env });
  const output = options.capture ? await new Response(child.stdout).text() : "";
  const status = await child.exited;
  if (status !== 0) fail(`${options.message ?? `${commandLine[0]} failed`} (exit ${status})`, 1);
  return output.trim();
}

function packageOptions() {
  const values = new Map();
  const valued = new Set(["--manifest", "--registry", "--output"]);
  const flags = new Set(command === "publish" ? ["--help", "--dry-run"] : ["--help"]);
  for (let index = 0; index < arguments_.length; index++) {
    const name = arguments_[index];
    if (!valued.has(name) && !flags.has(name)) fail(`${name.startsWith("-") ? "unknown option" : "unexpected argument"}: ${name}`);
    if (values.has(name)) fail(`duplicate option: ${name}`);
    if (valued.has(name)) {
      const value = arguments_[++index];
      if (!value || value.startsWith("-")) fail(`${name} requires a value`);
      values.set(name, value);
    } else values.set(name, true);
  }
  if (command === "publish" && values.has("--output") && !values.has("--dry-run")) fail("--output requires publish --dry-run");
  return values;
}

function packageHelp() {
  console.log(`usage: dew ${command} [--manifest PATH] [--registry ORIGIN] [--help]${command === "publish" ? " [--dry-run [--output DIR]]" : " [--output DIR]"}`);
  console.log("--manifest PATH: package manifest (default: ./dew.json).");
  console.log("--registry ORIGIN: capsule source origin (no lookup for local preparation).");
  if (command === "publish") console.log("--dry-run: save local checked inputs without login or upload.");
  console.log("--output DIR: new output directory. It must not exist; its parent must exist.");
  console.log("Local output: package.dpa and INPUTS.json. This is not a public release descriptor.");
}

async function packageCommand() {
  const options = packageOptions();
  if (options.has("--help")) { packageHelp(); return; }
  const registry = registryOrigin();
  const local = command === "pack" || options.has("--dry-run");
  // Preserve the existing publish credential lookup and upload contract.
  const credential = local ? null : await credentialFor(registry);
  const manifestPath = resolve(options.get("--manifest") ?? join(process.cwd(), "dew.json"));
  const { preparePackage, retainPackage } = await import("./dew-package-snapshot.mjs");
  console.log("Building and checking captured package inputs...");
  const artifact = await preparePackage({ manifestPath, source: `registry:${registry}`, repositoryRoot, run });
  if (local) {
    const defaultOutput = `${artifact.manifest.name.slice(1).replaceAll("/", "-")}-${artifact.manifest.version}.pack`;
    const inputs = await retainPackage(artifact, resolve(options.get("--output") ?? defaultOutput));
    console.log(JSON.stringify(inputs, null, 2));
    return;
  }
  console.log(`Publishing ${artifact.manifest.name}@${artifact.manifest.version} (${(artifact.encoded.length / 1024).toFixed(1)} KiB)...`);
  const response = await fetch(`${registry}/api/cli/packages`, {
    method: "PUT",
    headers: { Authorization: `Bearer ${credential.value.token}`, "Content-Type": "application/vnd.dewdrop.package-v1", "Content-Length": String(artifact.encoded.length), "User-Agent": "Dewdrop-CLI/0.1" },
    body: artifact.encoded,
  });
  const result = await responseJson(response);
  if (!response.ok) fail(result.error ?? `registry returned ${response.status}`, 1);
  console.log(`Published ${result.name}@${result.version}\n${registry}${result.url}`);
}

try {
  if (command === "login") await login();
  else if (command === "logout") await logout();
  else if (command === "whoami") await whoami();
  else if (command === "pack" || command === "publish") await packageCommand();
  else fail("unsupported registry command");
} catch (error) {
  console.error(`dew ${command}: ${error.message ?? error}`);
  process.exitCode = error.status ?? 1;
}
