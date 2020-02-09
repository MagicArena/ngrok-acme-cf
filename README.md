# ngrok-acme-cf

Ngrok image with letsencrypt certificate signed by acme.sh through cloudflare based on alpine.


# Build the image

	docker build ngrok-acme-cf \
	--build-arg NGROK_DOMAIN=<domain> \
	--build-arg CF_Account_ID=<cloudflare-account-id> \
	--build-arg CF_Token=<cloudflare-account-token> \
	-t magicarena/ngrok-acme-cf

- domain: domain name running for the service
- cloudflare-account-id: cloudflare account id
- cloudflare-account-token: cloudflare account access token with zone-full-access and dns-full-access

# Export the binary files of server and clients

 You can export client from the container after running this image with the command below：


	docker cp <container-name>:/ngrok/bin $HOME/ngrok-bin