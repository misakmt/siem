# Setup Documentation  
[Elastic Security Setup Guide](https://www.elastic.co/guide/en/elasticsearch/reference/8.17/configuring-stack-security.html)  

Other manual steps are documented below.  

## Setup Passwords (Run within Elasticsearch Container)  
```sh
/bin/elasticsearch-setup-passwords interactive
```  

## Configure Elastic (Run within Elasticsearch Container)  
- If the enrollment token is missed on setup—most likely because we are starting the container in detached mode—then run the command below to generate a new enrollment token:  
```sh
bin/elasticsearch-create-enrollment-token --scope kibana
```  

## Get Verification Codes from Kibana (Run within Kibana's Container)  
```sh
bin/kibana-verification-code
```  

## Enable Monitoring for Kibana Container  
### In the Elasticsearch Container (`elasticsearch.yml`):  
```yaml
xpack.monitoring.collection.enabled: true
```  

### In the Kibana Container (`kibana.yml`):  
```yaml
xpack.monitoring.ui.container.elasticsearch.enabled: true
```  

### Steps to Check Logs & Metrics:  
1. Go to **Kibana UI**  
2. Navigate to **Stack Monitoring**  
3. Check logs/metrics  

## Additional Configurations  
More configurations can be found [here](https://www.elastic.co/guide/en/kibana/8.17/alert-action-settings-kb.html#general-alert-action-settings).  
- **Filebeat setup** is required for logging.  

