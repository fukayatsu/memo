import typescript from '@rollup/plugin-typescript';
import injectProcessEnv from 'rollup-plugin-inject-process-env';

export default {
  input: {
    index:       'dev/ts/index.ts',
    dragAndDrop: 'dev/ts/dragAndDrop.ts',
    reloader:    'dev/ts/reloader.ts'
  },
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
