package main

import (
    "context"
    "fmt"
    "log"
    "net/http"

    "github.com/spiffe/go-spiffe/v2/spiffetls/tlsconfig"
    "github.com/spiffe/go-spiffe/v2/spiffeid"
    "github.com/spiffe/go-spiffe/v2/workloadapi"
)

const (
	// Workload API socket path
	socketPath	= "unix:///run/spire/sockets/agent.sock"
    trustDomain = "neutrino.org"
    clientID = "spiffe://neutrino.org/client"
	
)

func main() {
    ctx := context.Background()

	// Create a `workloadapi.X509Source`, it will connect to Workload API using provided socket path
	source, err := workloadapi.NewX509Source(ctx, workloadapi.WithClientOptions(workloadapi.WithAddr(socketPath)))
	if err != nil {
		log.Fatalf("Unable to create X509Source %v\n", err)
	}
	defer source.Close()

    // Allowed SPIFFE ID - Client must be from this trust domain
	clientID := spiffeid.RequireTrustDomainFromString(trustDomain)
    
	// Create a `tls.Config` to allow mTLS connections, and verify that presented certificate match the allowed SPIFFE-ID
	tlsConfig := tlsconfig.MTLSServerConfig(source, source, tlsconfig.AuthorizeMemberOf(clientID))
	server := &http.Server{
		Addr:      ":8443",
		TLSConfig: tlsConfig,
	}

    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        fmt.Fprintln(w, "Hello from SPIRE-secured server!")
    })

    log.Println("Server listening on :8443")
	if err := server.ListenAndServeTLS("", ""); err != nil {
		log.Fatalf("Error on serve: %v", err)
	}
}
