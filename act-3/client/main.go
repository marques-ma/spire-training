package main

import (
    "context"
    "io"
    "log"
    "net/http"

    "github.com/spiffe/go-spiffe/v2/spiffetls/tlsconfig"
    "github.com/spiffe/go-spiffe/v2/workloadapi"
    "github.com/spiffe/go-spiffe/v2/spiffeid"

)

const (
	// Workload API socket path
	socketPath	= "unix:///run/spire/sockets/agent.sock"
    serverID   = "spiffe://neutrino.org/ns/default/sa/server-mtls"
)

func main() {

    log.Println("Starting SPIRE mTLS client...")

    // Create a context for the client
    ctx := context.Background()

    // Create a `workloadapi.X509Source`, it will connect to Workload API using provided socket path
	source, err := workloadapi.NewX509Source(ctx, workloadapi.WithClientOptions(workloadapi.WithAddr(socketPath)))
	if err != nil {
		log.Fatalf("Unable to create X509Source %v\n", err)
	}
	defer source.Close()

    // Parse string to spiffeid.ID
	serverSPIFFEID, err := spiffeid.FromString(serverID)
	if err != nil {
		log.Fatalf("Invalid SPIFFE ID: %v", err)
	}

	// Create a `tls.Config` to allow mTLS connections, and verify that presented certificate match allowed SPIFFE ID rule
	tlsConfig := tlsconfig.MTLSClientConfig(source, source, tlsconfig.AuthorizeID(serverSPIFFEID))


    // Endereço correto do serviço server-app
	client := &http.Client{
		Transport: &http.Transport{
			TLSClientConfig: tlsConfig,
		},
	}
    resp, err := client.Get("https://server-app.default.svc.cluster.local:8443")
    if err != nil {
        log.Fatalf("request failed: %v", err)
    }
    defer resp.Body.Close()

    data, _ := io.ReadAll(resp.Body)
    log.Printf("server says: %s", data)
}
