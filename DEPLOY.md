# Deploying djrasmussen.co

This repo is the **source** for https://djrasmussen.co. The live site is built and
hosted by a **Cloudflare Worker** (`dj-research`) using Workers Builds, which builds
and deploys automatically on every push to `master`.

> **Edit content here, never the built HTML.** Cloudflare regenerates the site from
> this source on each push. (The old `dmr2.github.io` repo, `update_webpage.sh`, and
> GitHub Pages are retired — they predate the Cloudflare setup.)

## Local development

```bash
bundle install
bundle exec jekyll serve            # preview at http://localhost:4000
JEKYLL_ENV=production bundle exec jekyll build   # production build into _site/
```

`JEKYLL_ENV=production` is what enables the Google Analytics tag — a plain build omits it.

## Cloudflare Workers Builds settings

The `dj-research` Worker is connected to `dmr2/minimal-mistakes`, branch `master`
(dashboard → Workers & Pages → `dj-research` → Settings → Build).

| Setting | Value |
| --- | --- |
| Build command | `JEKYLL_ENV=production bundle exec jekyll build` |
| Deploy command | `npx wrangler deploy` |
| Path | `/` |

The rest of the deploy is driven by `wrangler.jsonc` in this repo:

```jsonc
{
  "name": "dj-research",
  "assets": { "directory": "_site" },        // upload the built site as static assets
  "routes": [                                  // bind the custom domains to the Worker
    { "pattern": "djrasmussen.co", "custom_domain": true },
    { "pattern": "www.djrasmussen.co", "custom_domain": true }
  ]
}
```

Having `wrangler.jsonc` present is important: without it, `wrangler deploy` runs an
auto-config step that mis-detects the build command (as `npx bundle exec jekyll build`,
which fails — `bundle` is a Ruby executable, not an npm package).

### Build gotchas

- **Ruby version** is pinned by `.ruby-version` (3.1.3). If a build fails because that
  version isn't on Cloudflare's image, change it to the nearest version the log offers
  (any 3.2/3.3 works — the gems are compatible) and push.
- **`Gemfile.lock`** is committed and includes the `x86_64-linux` platform so the Linux
  build runners can resolve gems. If you change gems, run
  `bundle lock --add-platform x86_64-linux` before committing the updated lock.
- **25 MiB asset limit:** Cloudflare rejects any single static file larger than 25 MiB.
  Keep large PDFs out of `assets/` (host them on Dropbox/elsewhere and link out).

## Domain & DNS

`djrasmussen.co` (apex) and `www.djrasmussen.co` are bound to the Worker via the
`custom_domain` routes above; Cloudflare manages their DNS records and SSL. This
requires the zone to be on Cloudflare DNS (nameservers `*.ns.cloudflare.com`).

### Optional: www → apex redirect

Both apex and www currently serve the Worker directly. To instead redirect
`www` to the bare domain (matching the site's canonical URLs), add a **Redirect Rule**
(dashboard → the `djrasmussen.co` zone → **Rules → Redirect Rules → Create**):

- **When incoming requests match:** `Hostname` `equals` `www.djrasmussen.co`
- **Then... Type:** Dynamic
- **Expression:** `concat("https://djrasmussen.co", http.request.uri.path)`
- **Status code:** 301

## Workflow

1. Edit content/templates in this repo.
2. `git commit` and `git push origin master`.
3. Workers Builds builds and deploys automatically; check the deployment under
   Workers & Pages → `dj-research` in the Cloudflare dashboard.
