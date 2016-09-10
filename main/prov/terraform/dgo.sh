TOKEN=
# n1_ip=`docker-machine ip f1`
n1_ip=
pushd prov/terraform
terraform plan -var do_token=$TOKEN -var n1_ip=$n1_ip
terraform apply -var do_token=$TOKEN -var n1_ip=$n1_ip
popd