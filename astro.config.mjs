import { defineConfig } from 'astro/config';

// https://astro.build/config
export default defineConfig({
  site: 'https://aryanthepain.github.io',
  base: '/',
  build: {
    format: 'directory'
  }
});
