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
    outDir: 'dist/public/widget',
    emptyOutDir: true,
    lib: {
      entry: resolve(__dirname, 'src/widget.tsx'),
      name: 'ChatbotWidget',
      fileName: (format) => `chatbot.${format}`,
      formats: ['umd']
    },
    rollupOptions: {
      external: ['react', 'react-dom', '@supabase/supabase-js'],
      output: {
        preserveModules: false,
        assetFileNames: (assetInfo) => {
          if (assetInfo.name === 'style.css' || assetInfo.name === 'widget.css') {
            return 'widget.css';
          }
          return assetInfo.name;
        },
        inlineDynamicImports: true,
        globals: {
          react: 'React',
          'react-dom': 'ReactDOM',
          '@supabase/supabase-js': 'supabase',
        }
      }
    },
    minify: 'esbuild',
    sourcemap: true
  }
});