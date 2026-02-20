// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import icon from 'astro-icon';

// https://astro.build/config
export default defineConfig({
    // This project is deployed with GitHub Pages on multiple remotes,
    // so these fields are configured from the deployment workflow.
    // These defaults are provided for development purposes only.
    site: process.env.ASTRO_SITE || 'https://bizrush-capstone.github.io',
    base: process.env.ASTRO_BASE || '',
    integrations: [
        starlight({
            title: 'BizRush',
            social: [
                {
                    icon: 'github',
                    label: 'GitHub',
                    href: 'https://github.com/bizrush-capstone',
                },
            ],
            sidebar: [
                {
                    label: 'Project',
                    items: [
                        { label: 'Home', slug: 'index' },
                        { label: 'Project Overview', slug: 'project-overview' },
                        { label: 'Month 1', slug: 'month-1' },
                        { label: 'Month 2', slug: 'month-2' },
                        { label: 'Month 3', slug: 'month-3' },
                    ],
                },
            ],
        }),
        icon({
            include: {
                mdi: ['*'],
            },
        }),
    ],
});
