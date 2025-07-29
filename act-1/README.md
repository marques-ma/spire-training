# SPIRE: Local Setup and CLI Interaction

This guide walks you through building and running [SPIRE](https://github.com/spiffe/spire) in a local environment. You will configure a custom trust domain, launch the server and agent, register your local user as a workload, and fetch an X.509 SVID using the SPIRE CLI.

---

## 🎯 Objectives

- Clone and build SPIRE locally  
- Adjust configurations for the `spiffe://neutrino.org` trust domain  
- Start the SPIRE Server and Agent  
- Create a registration entry for your Linux user  
- Fetch an SVID using the CLI  

---

## ⚙️ Prerequisites

- A Linux environment  
- [Go](https://golang.org/doc/install) and `gcc` installed  
- At least 2 vCPUs and 4 GB RAM  
- Access to the [SPIRE GitHub repository](https://github.com/spiffe/spire)

---

## 🧱 Task 1: Build SPIRE and Configure Trust Domain

### 🔧 Steps

```bash
# Clone the SPIRE repository
git clone https://github.com/spiffe/spire.git
cd spire

# Build the SPIRE binaries
make build

# Add the binaries to your PATH (adjust path accordingly)
export PATH="$(pwd)/bin:$PATH"

## 🚀 Task 2: Run SPIRE and Fetch SVID

### 🔧 Steps

```bash
# Start the SPIRE Server
spire-server run -config conf/server/server.conf
```
Make sure the trust_domain in server.conf is set to neutrino.org.  

# Generate a Join Token for the Agent
```bash
spire-server token generate -spiffeID spiffe://neutrino.org/agent
```

Copy the token output — you'll need it for the agent.

# Start the SPIRE Agent using the token
```bash
spire-agent run -config conf/agent/agent.conf -joinToken <TOKEN_FROM_PREVIOUS_STEP>
```
Ensure the agent’s trust_domain in agent.conf matches neutrino.org.

# Create a registration entry for your current user
```bash
spire-server entry create \
    -parentID spiffe://neutrino.org/agent \
    -spiffeID spiffe://neutrino.org/workload \
    -selector unix:user:$(whoami)
```

# Fetch the X.509 SVID
```bash
spire-agent api fetch x509
```
