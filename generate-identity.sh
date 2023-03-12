if [ -z "$1" ]; then
  echo "Specify identity"
  exit 1
fi
export ID=$1

didkit generate-ed25519-key > issuer_key.jwk
did=$(didkit key-to-did key -k issuer_key.jwk)
printf 'DID: %s\n\n' "$did"
didkit did-resolve `didkit key-to-did key -k issuer_key.jwk` > issuer_key_did_doc.json

TMP=$(jq . issuer_key_did_doc.json)
TMP=`echo $TMP | \
  jq '.id = "did:web:" + env.ID' | \
  jq '.verificationMethod[0].id = "did:web:" + env.ID + "#owner"' | \
  jq '.verificationMethod[0].controller = "did:web:" + env.ID' | \
  jq '.authentication = "did:web:" + env.ID + "#owner"' | \
  jq '.assertionMethod = "did:web:" + env.ID + "#owner"'` 

echo $TMP > did.json