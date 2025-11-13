import { defineConfig } from 'vitepress'

export default defineConfig({
  title: 'BabaVim',
  description: 'Neovim configuration for academic research, scientific computing, and document preparation',
  base: '/nvim-config/',
  
  themeConfig: {
    nav: [
      { text: 'Home', link: '/' },
      { text: 'Quick Start', link: '/quickstart' },
      { text: 'Reference', link: '/reference/keymaps' }
    ],

    sidebar: [
      {
        text: 'Getting Started',
        items: [
          { text: 'Quick Start', link: '/quickstart' },
          { text: 'Installation Guide', link: '/INSTALLATION_GUIDE' },
          { text: 'Troubleshooting', link: '/TROUBLESHOOTING_GUIDE' }
        ]
      },
      {
        text: 'Reference',
        items: [
          { text: 'Keymaps Reference', link: '/reference/keymaps' },
          { text: 'LSP Setup', link: '/advanced/lsp-setup' },
          { text: 'Changelog', link: '/CHANGELOG' }
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/SimonAB/nvim-config' }
    ],

    search: {
      provider: 'local'
    },

    footer: {
      message: 'Released under the MIT License.',
      copyright: 'BabaVim'
    }
  },

  markdown: {
    lineNumbers: true
  },

  head: [
    ['link', { rel: 'icon', type: 'image/svg+xml', href: '/nvim-config/favicon.svg' }]
  ]
})
