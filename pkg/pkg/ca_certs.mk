CA_CERTS_VER:=$(shell date +%y%m%d)
CA_CERTS:=ca_certs-$(CA_CERTS_VER)

PKG_LIST+=ca_certs

ca_certs: $(BLD)/$(CA_CERTS)-$(T).kp

src/cert.pem-$(CA_CERTS_VER):
	mkdir -p src
	wget https://ccadb.my.salesforce-sites.com/mozilla/IncludedRootsPEMTxt?TrustBitsInclude=Websites -O $@

$(BLD)/$(CA_CERTS): src/cert.pem-$(CA_CERTS_VER)
	mkdir -p $@/_kp_tmp/FILES/etc/ssl
	cp $< $@/_kp_tmp/FILES/etc/ssl/cert.pem
	echo "$(CA_CERTS) : This is the collection of CA Certificates used by the Mozilla CA Certificate Program" > $@/_kp_tmp/DESC
