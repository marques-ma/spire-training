package main

import (
	"context"
	"fmt"
	"log"
	"net/http"

	"github.com/spiffe/go-spiffe/v2/spiffetls/tlsconfig"
	"github.com/spiffe/go-spiffe/v2/spiffeid"
	"github.com/spiffe/go-spiffe/v2/workloadapi"
	"github.com/spiffe/go-spiffe/v2/svid/x509svid"
)

const (
	// Workload API socket path
	socketPath  = "unix:///run/spire/sockets/agent.sock"
	trustDomain = "neutrino.org"
)

func main() {

	log.Println("Starting SPIRE mTLS server...")
	
	// Create a context for the server
	ctx := context.Background()

	// Create a workloadapi.X509Source to connect to the Workload API
	source, err := workloadapi.NewX509Source(ctx, workloadapi.WithClientOptions(workloadapi.WithAddr(socketPath)))
	if err != nil {
		log.Fatalf("Unable to create X509Source: %v", err)
	}
	defer source.Close()

	// Define allowed SPIFFE IDs from the trust domain
	domain := spiffeid.RequireTrustDomainFromString(trustDomain)

	// Create mTLS server config with SPIFFE-based authorization
	tlsConfig := tlsconfig.MTLSServerConfig(source, source, tlsconfig.AuthorizeMemberOf(domain))

	server := &http.Server{
		Addr:      ":8443",
		TLSConfig: tlsConfig,
	}

	// Handle incoming requests
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		certs := r.TLS.PeerCertificates
		if len(certs) > 0 {
			clientID, err := x509svid.IDFromCert(certs[0])
			if err != nil {
				log.Printf("Error retrieving client SPIFFE ID: %v", err)
			} else {
				log.Printf("Request received from client SPIFFE ID: %s", clientID.String())
			}
		} else {
			log.Println("No client certificate found")
		}

		fmt.Fprintln(w, "Hello from SPIRE-secured server!")
	})

	log.Println("Server listening on :8443")
	if err := server.ListenAndServeTLS("", ""); err != nil {
		log.Fatalf("Error on serve: %v", err)
	}
}