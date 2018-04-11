#!/bin/bash
#REMOVE
az network nic ip-config address-pool remove --resource-group rg \
                                             --nic-name h-g4t3wid1-nic \
                                             --ip-config-name ipConfig1 \
                                             --lb-name h-g4t3wid0-lb \
                                             --address-pool h-g4t3wid0-pool
#ADD
az network nic ip-config address-pool add --resource-group rg \
                                          --nic-name h-g4t3wid1-nic \
                                          --ip-config-name ipConfig1 \
                                          --lb-name h-g4t3wid0-lb \
                                          --address-pool h-g4t3wid0-pool
