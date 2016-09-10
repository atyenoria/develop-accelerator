#export DO_TOKEN=
#curl --request GET "https://api.digitalocean.com/v2/account/keys"  --header "Authorization: Bearer $DO_TOKEN"| jq '.'
#terraform plan -var do_token= -var d1_ip=`dkmc inspect d1| jq .Driver.IPAddress | sed -e 's/"//g'`

#terraform apply -var do_token= -var d1_ip=`dkmc inspect d1| jq .Driver.IPAddress | sed -e 's/"//g'` -var d2_ip=`dkmc inspect d2| jq .Driver.IPAddress | sed -e 's/"//g'` -var d3_ip=`dkmc inspect d3| jq .Driver.IPAddress | sed -e 's/"//g'`

variable "do_token" {}
variable "n1_ip" {}

provider "digitalocean" {
  token = "${var.do_token}"

}

resource "digitalocean_domain" "unko" {
   name = "unko"
   ip_address = "${var.n1_ip}"
}











