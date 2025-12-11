# Generating a Self-Signed Root Certificate
## Generate the private key

```bash
openssl genrsa -out ca.key 8192
```

## Generate the public certificate

Common Name (CN) can be `Orion (Local) CA` or something along those lines

```bash
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out ca.crt
```

# Specific Host Enrollment

This is to generate the private and public key for a specific host, using the self-signed root CA as the issuer.

Note: this requires that the CA key is available so we can approve the certificate signing request.

## 1. Generate the host's key

```bash
openssl genrsa -out server.key 4096
```

## 2. Create a certificate signing request (CSR)

Common Name (CN) should be the domain or IP to be used, e.g., "localhost" or "127.0.0.1" for local usage

```bash
openssl req -new -key server.key -out server.csr
```

## 3. Create a config file for the extensions

This ensures we specify that the server's certificate is an End Entity (`CA:FALSE`) and we have the correct Subject Alternative Names (SANs).

Update the `[alt_names]` entries to reflect what aws used for the `CN` in the previous step.

The below is a sample config:

```
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
IP.1 = 127.0.0.1
DNS.1 = localhost
```

## 4. Sign the server certificate using the CA

```bash
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
-out server.crt -days 365 -sha256 -extfile server.ext
```

# Security

| File         | Private | Notes                                                                                              |
|--------------|---------|----------------------------------------------------------------------------------------------------|
| `ca.key`     | Yes     | The root CA key                                                                                    |
| `ca.crt`     | No      | The public certificate for the CA                                                                  |
| `ca.srl`     | No      | Used to ensure each certificate signed by the CA get's a unique serial number, not strictly needed |
| `server.key` | Yes     | A specific host's server key approved by the CA                                                    |
| `server.crt` | No      | A specific host's public key signed by the CA                                                      |
| `server.csr` | Yes     | Can be deleted after a host's public key is created by the CA                                      |
