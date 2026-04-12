import type {SidebarsConfig} from '@docusaurus/plugin-content-docs';

const sidebars: SidebarsConfig = {
  tutorialSidebar: [
    {
      type: 'category',
      label: 'Documentation',
      items: ['intro', 'api', 'building'],
    },
  ],
};

export default sidebars;
