# ─── Values to override defaults ─────────────────────────────────────────────
# Copy this file and commit it. Never commit secrets here.

prefix      = "jsync"
environment = "prod"
location    = "koreacentral"
# eastasia → uaenorth → malaysiawest

db_name          = "jsync"
mysql_sku_name   = "B_Standard_B1ms"
mysql_storage_gb = 20

server_cpu    = 0.5
server_memory = "1Gi"
client_cpu    = 0.5
client_memory = "1Gi"

vnet_address_space  = "10.0.0.0/16"
aca_subnet_prefix   = "10.0.0.0/23"
mysql_subnet_prefix = "10.0.2.0/24"
