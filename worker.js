// Redirect www.djrasmussen.co -> djrasmussen.co (301), otherwise serve the
// static site built into _site. The bare domain is the site's canonical host.
export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.hostname === "www.djrasmussen.co") {
      url.hostname = "djrasmussen.co";
      return Response.redirect(url.toString(), 301);
    }
    return env.ASSETS.fetch(request);
  },
};
