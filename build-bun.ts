import * as lmdb from "lmdb";
import * as path from "node:path";

const hashFunc = Bun.hash.cityHash32;

type HashResult = ReturnType<typeof hashFunc>;
type LastModified = number;
type CachedValueEntry = {
  lastModified: LastModified;
  hash: HashResult;
};
type CacheKey = HashResult;

const db = lmdb.open<CachedValueEntry, CacheKey>(".build-cache", {
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
  const cacheKey = hashFunc(src);

  const { dir, name } = path.parse(src);
  const outputPath = path.join(dir, `${name}.js`);
  const file = Bun.file(src);
  const outfile = Bun.file(outputPath);
  const cacheKeyDesc = `${outputPath}#${cacheKey.toString(36)}`;

  console.log(`Found: ${cacheKeyDesc} -> ${outputPath}`);

  // The text contents and hash of that text may or may not be computed, so
  // instead, assert they are calculated later if needed
  const outfileExistsPromise = outfile.exists();
  const textPromise = file.text();
  const lastModified = file.lastModified;

  let text: string | null = null;
  let hash = 0;

  // If the result of the operation is cached, we can short circuit to prevent
  // the file from needing to be regenerated
  if (db.doesExist(cacheKey) || !(await outfileExistsPromise)) {
    console.log(`Checking for changes ${cacheKey}`);

    // The async function seems to crash everything, so getting the information
    // in a synchronous manner is fine for now
    const cachedValue = db.get(cacheKey);
    
    // TODO: Replace the above code with some kind of async get
    // const cachedValue = (await db.getAsync(cacheKey)) as unknown as
    //   | CachedValueEntry
    //   | undefined;

    if (cachedValue) {
      const { lastModified: cachedLastModified, hash: outputHash } =
        cachedValue;

      if (cachedLastModified === lastModified) {
        console.log(`Unmodified: ${src}`);
        return void 0;
      }

      text = await textPromise;
      hash = hashFunc(text);
      if (outputHash === hash) {
        console.log(`Unmodified: ${src}`);
        return void 0;
      }
    }
  }

  // once the text must be read, we should also hash it's contents
  if (text === null) {
    text = await textPromise;
    hash = hashFunc(text);
  }

  // finally, the cache is invalid, time to update the database and transpile
  // the output
  console.log(`Transpiling: ${cacheKeyDesc} -> ${outputPath}`);

  await outfile.write(await transpiler.transform(text));
  await db.put(cacheKey, { lastModified: outfile.lastModified, hash });
  console.log("Done!");
};

const toResolve = [] as Promise<void>[];
for await (const src of new Bun.Glob("src/**/*.ts").scan()) {
  toResolve.push(build(src));
}

await Promise.all(toResolve).catch((ex) => console.error(ex));
