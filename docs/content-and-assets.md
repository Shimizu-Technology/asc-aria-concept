# ASC public content and asset sources

This branch turns the ARIA proof of concept into an ASC Trust website modernization concept. It imports ASC Trust public sitemap content and public image/logo assets from the existing ASC Trust website for private stakeholder review.

## Source pages reviewed

Public ASC Trust pages/posts were discovered from the WordPress public sitemaps and imported into a local manifest for review:

- `https://www.asctrust.com/wp-sitemap-posts-page-1.xml`
- `https://www.asctrust.com/wp-sitemap-posts-post-1.xml`

Imported result:

- 45 public pages/posts represented in `web/src/ascSiteData.ts`
- 131 public image references optimized into `web/public/asc-assets/full/`
- Source URLs preserved per page and per image asset so ASC can review provenance

The scrape was intentionally limited to publicly available ASC website pages/media. WordPress REST API access was blocked by site security, so public sitemap + HTML extraction was used instead.

## Local concept assets

The private concept preview stores ASC public site assets under:

```text
web/public/asc-assets/
web/public/asc-assets/full/
```

Included asset types:

- ASC Trust logo/favicon
- team and participant imagery
- current participant education/chart images
- current core-value icons
- service, investment, resources, media, and contact hero images
- current partner-logo graphic

The public UI shows a focused content-library slice by default and a 48-asset visual review mosaic, while the complete imported image set remains staged locally for ASC review.

## Usage boundary

These assets and excerpts are included only so ASC stakeholders can review what a modernized replacement site could feel like using their existing public brand/content foundation.

Before production launch:

1. Confirm ASC approves all image/logo/content usage.
2. Replace scraped/compressed web assets with official source files where available.
3. Confirm testimonial, partner, address, service, and form copy with ASC.
4. Replace sample-only ARIA workflow data with approved demo or production-safe data.
5. Keep `noindex,nofollow` until ASC explicitly approves a public launch.

## Data boundary

The public website sections use public ASC Trust content. The secure support workflow still uses fictional sample participant data (`Bank of Mila`, `Malia Santos`) and remains disconnected from Relias, Airtable, authentication, and live AI.
