## Deploy
```sh
chmod +x deploy.sh
./deploy.sh
```

## Comments and questions:
- Creates as many deployments as needed but if two of them are on the same instance, they share the same proxy-url.
  - Should one deployment be per instance (what's the point of using GKE)
  - [KO] Can we use different port even if the same URL? aaa could be 8080, bbb could be 8081, etc...
  - How do we create on proxy url not using the BACKENDID but something else (SERVICEID?)
- 
