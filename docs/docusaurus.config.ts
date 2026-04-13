import {themes as prismThemes} from 'prism-react-renderer';
import type {Config} from '@docusaurus/types';
import type * as Preset from '@docusaurus/preset-classic';

const config: Config = {
  title: 'Godot HealthKit Plugin',
  tagline: 'Native HealthKit step counting and App Tracking Transparency for Godot iOS games.',
  favicon: 'img/favicon.svg',

  future: {
    v4: true,
  },

  url: 'https://SomniGameStudios.github.io',
  baseUrl: '/godot-healthkit-plugin/',

  organizationName: 'SomniGameStudios', 
  projectName: 'godot-healthkit-plugin', 

  onBrokenLinks: 'throw',

  i18n: {
    defaultLocale: 'en',
    locales: ['en'],
  },

  presets: [
    [
      'classic',
      {
        docs: {
          sidebarPath: './sidebars.ts',
          routeBasePath: '/',
          versions: {
            current: {
              label: 'Next (Unreleased)',
            },
          },
        },
        blog: false,
        theme: {
          customCss: './src/css/custom.css',
        },
      } satisfies Preset.Options,
    ],
  ],

  themeConfig: {
    colorMode: {
      respectPrefersColorScheme: true,
    },
    navbar: {
      title: 'HealthKit Plugin',
      items: [
        {
          type: 'docSidebar',
          sidebarId: 'tutorialSidebar',
          position: 'left',
          label: 'Documentation',
        },
        {
          type: 'docsVersionDropdown',
          position: 'right',
        },
        {
          href: 'https://github.com/SomniGameStudios/godot-healthkit-plugin',
          label: 'GitHub',
          position: 'right',
        },
      ],
    },
    footer: {
      style: 'dark',
      links: [
        {
          title: 'Docs',
          items: [
            {
              label: 'Introduction',
              to: '/',
            },
            {
              label: 'GDScript API',
              to: '/api',
            },
            {
              label: 'Building',
              to: '/building',
            },
          ],
        },
      ],
      copyright: `Copyright © ${new Date().getFullYear()} Somni Game Studios. Built with Docusaurus.`,
    },
    prism: {
      theme: prismThemes.github,
      darkTheme: prismThemes.dracula,
      additionalLanguages: ['gdscript'],
    },
  } satisfies Preset.ThemeConfig,
};

export default config;
