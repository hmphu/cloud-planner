# Cloud-Planner

Find the most cost efficient cloud provider among AWS, Azure and Google.

* Cost calculation

* Cost comparison

* ...


## Raw data
You need raw data loaded in database before the cost calculations.
You can do that manually with the data scope and values according to your environment.

### AWS data
For the conveience, you may use AWS-COST (https://github.com/ikspres/aws-cost)
AWS-COST proivdes APIs to get raw data of AWS.
With AWS-COST has been setup correctly, you can load the raw data as the following

```
rails console
irb> Provider.load_providers  
irb> Region.load_aws_regions
irb> MachineType.load_aws_machinetypes
```

