# Gateway API: User-Agent Based Routing

The mobile team wants traffic routed based on the `User-Agent` header.

An existing Gateway `main-gateway` is deployed in namespace `project-mobile`. Two backend services exist:

- `mobile-backend` - serves mobile clients
- `desktop-backend` - serves desktop clients

Your tasks:

1. Create an HTTPRoute named `ua-router` in namespace `project-mobile`
2. Attach it to the existing Gateway `main-gateway`
3. Configure routing for path `/app`:
   - If `User-Agent` header **exactly matches** `mobile-app`, route to `mobile-backend` on port 80
   - Otherwise (default), route to `desktop-backend` on port 80

## Test Commands

Once configured, these should work:

```bash
# Should hit mobile-backend
curl -H "User-Agent: mobile-app" http://<gateway-ip>:30080/app

# Should hit desktop-backend  
curl http://<gateway-ip>:30080/app
curl -H "User-Agent: Chrome" http://<gateway-ip>:30080/app
```

**Hint**: Use `matches` with `headers` in HTTPRoute rules. The first matching rule wins.
