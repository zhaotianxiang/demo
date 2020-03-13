
'use strict';

module.exports={
	jobs:1,
	srvQueueSize:1000,
	mongodb:'mongodb://gearman:123456@dds-2zeeaa1721eec0041.mongodb.rds.aliyuncs.com:3717,dds-2zeeaa1721eec0042.mongodb.rds.aliyuncs.com:3717/gearman?replicaSet=mgset-3291931',
	worker:{
		servers:[{'host':'application'}]
	},
	client:{
		servers:[{'host':'application'}],
		loadBalancing: 'RoundRobin'
	},
	retry:2
};
