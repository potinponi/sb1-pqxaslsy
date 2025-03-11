import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { resolve } from 'path';
import tailwindcss from 'tailwindcss';
import autoprefixer from 'autoprefixer';
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  define: {
    'process.env.NODE_ENV': JSON.stringify(process.env.NODE_ENV)
  },
  css: {
    postcss: {
      plugins: [
        tailwindcss,
        autoprefixer,
      ],
    },
  },
  build: {
    outDir: 'dist/widget',
    lib: {
      entry: resolve(__dirname, 'src/widget.ts'),
      name: 'ChatbotWidget',
      fileName: (format) => `chatbot.${format}.js`,
      formats: ['umd']
    },
    rollupOptions: {
      external: ['react', 'react-dom', '@supabase/supabase-js'],
      output: {
        name: 'ChatbotWidget',
        assetFileNames: (assetInfo) => {
          if (assetInfo.name === 'style.css') {
            return 'widget/styles.css';
          }
          return assetInfo.name;
        },
        globals: {
          react: 'React',
          'react-dom': 'ReactDOM',
          '@supabase/supabase-js': 'supabase'
        }
      }
    },
    minify: 'esbuild',
    sourcemap: false
  }
});