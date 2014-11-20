Copy the full content recursively into conf.d/ of nginx.  By default, the 
behaviour the same as of v2.3.7.

Extra configurations like caching or serving static files are made includable 
as location blocks.  Uncomment if needed in the slipstream-ssl.conf.

Proxy parameters are extracted into reusable slipstream-proxy.params.  Include 
the file in the relevant blocks as needed (e.g, as in caching example).

