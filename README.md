#Hiera Config
```
---
version: 5
hierarchy:
    - name: "Per node data"
      path: "nodes/%{trusted.certname}.yaml"

    - name: "Common data"
      path: "common.yaml"

          
defaults:
    datadir: /etc/puppetlabs/code/environments/production/hieradata
    data_hash: yaml_data
```
