# LDAPS stunnel

```
          ┌─────────────────┐             
          │ OpenShift oAuth │             
          └───────┬─────────┘             
                  │                       
                  ▼                       
                (LDAP)                    
                  │                       
                  ▼                       
            ┌─────────────┐               
            │  Stunnel    │               
            └─────┬───────┘               
                  │                       
                  ▼                       
                (LDAPS)                   
                  │                       
                  ▼                       
┌────────────────────────────────────────┐
│AD/LDAP(s) with weird SSL configuration │
└────────────────────────────────────────┘
```

## Deployment

Deploy in your project/namespace of choise

### Create configmap

```bash
oc create configmap ldaps-stunnel2 \
    --from-literal=LDAP_SERVER=inf1 \
    --from-literal=LDAP_PORT=636
```

OR

```yaml
oc create -f - <<EOF
kind: ConfigMap
apiVersion: v1
metadata:
  name: ldaps-stunnel
data:
  LDAP_PORT: '636'
  LDAP_SERVER: inf1
EOF
```

### Deploy stunnel and cli

```bash
oc apply -f https://raw.githubusercontent.com/openshift-examples/ldaps-stunnel/refs/heads/main/deploy-cli.yaml
oc apply -f https://raw.githubusercontent.com/openshift-examples/ldaps-stunnel/refs/heads/main/deploy-stunnel.yaml
```


### Try it out

```bash
oc rsh deployment/ldaps-cli
sh-5.1$ ldapsearch -x -h ldaps-stunnel '(uid=rbohne)' uid
# extended LDIF
#
# LDAPv3
# base <> (default) with scope subtree
# filter: (uid=rbohne)
# requesting: uid
#

# rbohne, users, compat, ....
dn: uid=rbohne,cn=users,cn=compat,....
uid: rbohne

# rbohne, users, accounts, ....
dn: uid=rbohne,cn=users,cn=accounts,...
uid: rbohne

# search result
search: 2
result: 0 Success

# numResponses: 3
# numEntries: 2
sh-5.1$ ldapsearch -x -h ldaps-stunnel.${NAMESPACE}.svc.cluster.local. '(uid=rbohne)' uid
...
```

## Build

```bash
export VERSION=$(date +"%Y%m%dT%H%M%S")
export IMAGE=quay.io/openshift-examples/ldaps-stunnel:$VERSION
podman manifest rm ${IMAGE}
podman build --platform linux/amd64,linux/arm64  --manifest ${IMAGE}  .
podman manifest push ${IMAGE}
```

## Some ldap commands

```bash
# Get certificates
% echo -n | openssl s_client -connect inf1:636

# Show  / change crypto
% update-crypto-policies --show
FUTURE
% update-crypto-policies --set DEFAULT


% ldapsearch -x -ZZ -H 'ldaps://inf1:636/'
ldap_start_tls: Can't contact LDAP server (-1)
        additional info: error:0A000086:SSL routines::certificate verify failed (self-signed certificate in certificate chain)
% export LDAPTLS_REQCERT=never

% ldapsearch -x -ZZ -H 'ldaps://inf1:636/'
ldap_start_tls: Operations error (1)
        additional info: SSL connection already established.
% ldapsearch -x -ZZ -H 'ldaps://inf1:636/'
ldap_start_tls: Operations error (1)
        additional info: SSL connection already established.
% sh-5.1$ ldapsearch -x -ZZ -H ldaps://inf1 '(uid=rbohne)' uid
ldap_start_tls: Operations error (1)
        additional info: SSL connection already established.
```
