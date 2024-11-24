#!/bin/sh

wget https://ccadb.my.salesforce-sites.com/mozilla/IncludedRootsPEMTxt?TrustBitsInclude=Websites -O ca_cert.pem-`date +%y%m%d`
