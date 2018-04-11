#!/bin/bash
DNS=cmd
NET_RG=
HOST_RG=
AS=
SKU=Standard
LD=SourceIPProtocol
NET=
SUB=
IP1=
IP2=
HOST1=
HOST2=
IMG=OpenLogic:CentOS:7.4:latest
SIZE=Standard_D2_v2
STOR=Standard_LRS
ADMIN=
KEY=$(cat /root/.ssh/id_rsa.pub)

az network public-ip create --resource-group "$NET_RG" \
                            --name "$AS"-ip \
                            --dns-name "$DNS" \
                            --sku "$SKU"

az network lb create --resource-group "$NET_RG" \
                     --name "$AS"-lb \
                     --public-ip-address "$AS"-ip \
                     --frontend-ip-name "$AS"-front \
                     --backend-pool-name "$AS"-pool \
                     --sku "$SKU"

az network lb probe create --resource-group "$NET_RG" \
                           --lb-name "$AS"-lb \
                           --name "$AS"-probe443 \
                           --protocol tcp \
                           --port 443

az network lb rule create --resource-group "$NET_RG" \
                          --lb-name "$AS"-lb \
                          --name "$AS"-rule80 \
                          --protocol tcp \
                          --frontend-port 80 \
                          --backend-port 80 \
                          --frontend-ip-name "$AS"-front \
                          --load-distribution "$LD" \
                          --backend-pool-name "$AS"-pool \
                          --probe-name "$AS"-probe443

az network lb rule create --resource-group "$NET_RG" \
                          --lb-name "$AS"-lb \
                          --name "$AS"-rule443 \
                          --protocol tcp \
                          --frontend-port 443 \
                          --load-distribution "$LD" \
                          --backend-port 443 \
                          --frontend-ip-name "$AS"-front \
                          --backend-pool-name "$AS"-pool \
                          --probe-name "$AS"-probe443

az network nic create --name "$HOST1"-nic \
                      --resource-group "$NET_RG" \
                      --vnet-name "$NET" \
                      --private-ip-address "$IP1" \
                      --lb-name "$AS"-lb \
                      --lb-address-pools "$AS"-pool  \
                      --subnet "$SUB"

az network nic create --name "$HOST2"-nic \
                      --resource-group "$NET_RG" \
                      --vnet-name "$NET" \
                      --private-ip-address "$IP2" \
                      --lb-name "$AS"-lb \
                      --lb-address-pools "$AS"-pool  \
                      --subnet "$SUB"

az vm availability-set create --name "$AS"-as \
                              --resource-group "$HOST_RG" \
                              --platform-fault-domain-count 2 \
                              --platform-update-domain-count 2

#not possible to use nic name from other resource group, so get id of it
NIC1_ID=$(az network nic show --resource-group "$NET_RG" --name "$HOST1"-nic --query [id] --output tsv)

az vm create --resource-group "$HOST_RG" \
             --name "$HOST1" \
             --image "$IMG" \
             --size "$SIZE" \
             --admin-username "$ADMIN" \
             --ssh-key-value "$KEY" \
             --storage-sku "$STOR" \
             --availability-set "$AS"-as \
             --nics "$NIC1_ID"

#not possible to use nic name from other resource group, so get id of it
NIC2_ID=$(az network nic show --resource-group "$NET_RG" --name "$HOST2"-nic --query [id] --output tsv)

az vm create --resource-group "$HOST_RG" \
             --name "$HOST2" \
             --image "$IMG" \
             --size "$SIZE" \
             --admin-username "$ADMIN" \
             --ssh-key-value "$KEY" \
             --storage-sku "$STOR" \
             --availability-set "$AS"-as \
             --nics "$NIC2_ID"
