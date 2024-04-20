CA_CERTS_VER:=ca_certs-1.0

PKG_LIST+=ca_certs

ca_certs: $(BLD)/$(CA_CERTS_VER).kp

$(BLD)/$(CA_CERTS_VER):
	mkdir -p $@/_kp_tmp/FILES/etc/ssl
	wget https://ccadb.my.salesforce-sites.com/mozilla/IncludedRootsPEMTxt?TrustBitsInclude=Websites -O $@/_kp_tmp/FILES/etc/ssl/cert.pem
	echo "$(CA_CERTS_VER) : This is the collection of CA Certificates used by the Mozilla CA Certificate Program" > $@/_kp_tmp/DESC
