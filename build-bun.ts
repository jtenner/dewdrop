console.log(process.argv);
for (const [env_var, env_val] of Object.entries(process.env)) {
  console.log(`${env_var} = ${env_val}`);
}
// await Bun.build({
//   entrypoints: [],
//   outdir: "./",
//   naming: "[dir]/[name].js",
// });
