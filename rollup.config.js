import typescript from '@rollup/plugin-typescript';
import injectProcessEnv from 'rollup-plugin-inject-process-env';

export default {
  input: 'dev/ts/dev.ts',
  output: {
    dir: 'dev/js',
    format: 'esm'
  },
  plugins: [
    typescript(),
    injectProcessEnv({
      RELOADER_HOST: process.env.RELOADER_HOST || 'localhost:9293'
    }),
  ],
  watch: {
    clearScreen: false
  }
};
