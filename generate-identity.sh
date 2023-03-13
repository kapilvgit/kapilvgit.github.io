#!/bin/bash

# See https://mhrsntrk.com/blog/create-and-publish-your-own-did-web

if [ -z "$1" ]; then
  echo "Specify identity"
  exit 1
fi
export ID=$1

didkit generate-ed25519-key > $ID/did.jwk
did=$(didkit key-to-did key -k $ID/did.jwk)
printf 'DID: %s\n\n' "$did"
didkit did-resolve `didkit key-to-did key -k $ID/did.jwk` > $ID/did_doc.json

TMP=$(jq . $ID/did_doc.json)
TMP=`echo $TMP | \
  jq '.id = "did:web:" + env.ID' | \
  jq '.verificationMethod[0].id = "did:web:" + env.ID + "#owner"' | \
  jq '.verificationMethod[0].controller = "did:web:" + env.ID' | \
  jq '.authentication = "did:web:" + env.ID + "#owner"' | \
  jq '.assertionMethod = "did:web:" + env.ID + "#owner"'` 

rm $ID/did_doc.json
echo $TMP | jq '.' > $ID/.well-known/did.json