const path = require('path');

require("esbuild").build({
  entryPoints: ["application.jsx"],
  bundle: true,
  outdir: path.join(process.cwd(), "app/assets/builds"),
  absWorkingDir: path.join(process.cwd(), "app/javascript"),
  publicPath: "/assets",
  assetNames: "[name]-[hash].digested",
  sourcemap: true,
  watch: process.argv.includes('--watch'),
  plugins: [],
  loader: {
    '.js': 'jsx',
    '.png': 'file',
  },
}).catch(() => process.exit(1));