import * as lmdb from "lmdb";
import * as path from "node:path";

const db = lmdb.open<readonly [number, string], string>(".build-cache", {
  name: "build-cache",
  strictAsyncOrder: false,
});
const transpiler = new Bun.Transpiler({
  target: "bun",
  loader: "ts",
  treeShaking: true,
  minifyWhitespace: true,
  allowBunRuntime: true,
});

const build = async (src: string) => {
  const cacheName = Bun.hash(src).toString(32);
  console.log(`Found: ${src} -> ${cacheName}`);

  const file = Bun.file(src);
  const { dir, name } = path.parse(src);
  const outputPath = path.join(dir, `${name}.js`);
  const outfileExists = await Bun.file(outputPath).exists();
  console.log(
    `Output file ${outputPath} ${outfileExists ? "exists" : "does not exist"}`,
  );
  if (!outfileExists) {
    console.log(`Removing: ${cacheName} because ${outputPath} does not exist`);
    await db.remove(cacheName);
  }
  const textPromise = file.text();
  const lastModified = file.lastModified;
  let text: string | null = null;
  let hash: string | null = null;
  if (db.doesExist(cacheName)) {
    console.log(`Found cached value entry for ${cacheName}`);

    const cachedValue = await db.getAsync(cacheName);
    if (cachedValue) {
      const [cachedLastModified, outputHash] = cachedValue;
      if (cachedLastModified === lastModified) {
        console.log(`Unmodified: ${src}`);
        return void 0;
      }

      text = await textPromise;
      hash = Bun.hash(text).toString(32);
      if (outputHash === hash) {
        console.log(`Unmodified: ${src}`);
        return void 0;
      }
    }
  }
  if (!text) text = await textPromise;
  if (!hash) hash = Bun.hash(text).toString(32);

  console.log(`Transpiling: ${src} with hash ${hash}`);
  const output = await transpiler.transform(text);
  console.log(`Writing: ${outputPath}`);
  await Bun.write(outputPath, output);
  console.log(`Caching: ${cacheName}`);
  await db.put(cacheName, [Bun.file(src).lastModified, hash]);
  console.log("Done!");
};

const toResolve = [] as Promise<void>[];
for await (const src of new Bun.Glob("src/**/*.ts").scan()) {
  toResolve.push(build(src));
}

await Promise.all(toResolve).catch((ex) => console.error(ex));
