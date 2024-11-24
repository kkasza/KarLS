CA_CERTS_VER:=241124
CA_CERTS:=ca_certs-$(CA_CERTS_VER)

PKG_LIST+=ca_certs

ca_certs: $(BLD)/$(CA_CERTS)-$(T).kp

$(BLD)/$(CA_CERTS):
	mkdir -p $@/_kp_tmp/FILES/etc/ssl
	cp pkg/ca_certs/$(CA_CERTS_VER)/ca_cert.pem-$(CA_CERTS_VER) $@/_kp_tmp/FILES/etc/ssl/cert.pem
	echo "$(CA_CERTS) : This is the collection of CA Certificates used by the Mozilla CA Certificate Program" > $@/_kp_tmp/DESC
