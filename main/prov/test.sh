cat << EOS | curl -X PUT http://sakura:8500/v1/acl/create?token=master_token_test -d @-
{
  "Name": "test_token",
  "Type": "client",
  "Rules": "
    key \"testread/\" {
      policy = \"read\"
    }
    key \"testwrite/\" {
      policy = \"write\"
    }
  "
}
EOS



# curl http://sakura:8500/v1/acl/list
# curl http://sakura:8500/v1/acl/list?token=master_token_test | jq .
# curl http://sakura:8500/v1/acl/list?token=lodGXy8qYan9rCRITiAQDw==
# curl -i http://sakura:8500/v1/kv/testread/value?token=master_token_test
# curl -i http://sakura:8500/v1/kv/testread/value
# curl -i -X PUT http://sakura:8500/v1/kv/testwrite/value?token=master_token_test -d 200
# curl -i -X PUT http://sakura:8500/v1/kv/testwrite/value?token=master_token_test -d 200
# curl -i -X PUT http://f1:8500/v1/kv/sample/value?token=master_token_test -d 200
# curl -i http://sakura:8500/v1/kv/sample/value
# curl -i -X PUT http://f1:8500/v1/kv/golang?token=master_token_test -d 200asdfasf
# curl -i http://sakura:8500/v1/kv/golang?token=master_token_test
