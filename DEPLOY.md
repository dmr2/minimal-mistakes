# Deploying djrasmussen.co

This repo is the **source** for https://djrasmussen.co. The live site is built and
hosted by **Cloudflare Pages**, which builds automatically on every push to `master`.

> **Edit content here, never the built HTML.** Cloudflare regenerates the site from
> this source on each push. (The old `dmr2.github.io` repo and `update_webpage.sh`
> script are obsolete — they predate the Cloudflare setup.)

## Local development

```bash
bundle install
bundle exec jekyll serve            # preview at http://localhost:4000
JEKYLL_ENV=production bundle exec jekyll build   # production build into _site/
```

`JEKYLL_ENV=production` is what enables the Google Analytics tag — a plain build omits it.

## Cloudflare Pages build settings

Project is connected to `dmr2/minimal-mistakes`, branch `master`.

| Setting | Value |
| --- | --- |
| Build command | `bundle exec jekyll build` |
| Build output directory | `_site` |
| Environment variable | `JEKYLL_ENV` = `production` |

Ruby is pinned by `.ruby-version`. If a build fails because that version isn't
available on Cloudflare's build image, change `.ruby-version` to the nearest
version the log offers (any 3.2/3.3 works — the gems are compatible) and push.

`Gemfile.lock` is committed and includes the `x86_64-linux` platform so the Linux
build runners can resolve gems. If you change gems, run
`bundle lock --add-platform x86_64-linux` before committing the updated lock.

## Domain & DNS

`djrasmussen.co` is an apex domain served by Cloudflare Pages via a **Custom domain**
on the Pages project (Cloudflare's CNAME flattening handles the apex). This requires
the zone to be on Cloudflare DNS.

### www → apex redirect

To send `www.djrasmussen.co` to the bare domain, add a **Redirect Rule**
(dashboard → the `djrasmussen.co` zone → **Rules → Redirect Rules → Create**):

- **When incoming requests match:** `Hostname` `equals` `www.djrasmussen.co`
- **Then... Type:** Dynamic
- **Expression:** `concat("https://djrasmussen.co", http.request.uri.path)`
- **Status code:** 301

(This matches the site's canonical URLs, which all use the bare `djrasmussen.co`.)

## Workflow

1. Edit content/templates in this repo.
2. `git commit` and `git push origin master`.
3. Cloudflare Pages builds and deploys automatically; check the deployment in the
   Cloudflare dashboard.
