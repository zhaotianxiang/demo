
'use strict';

module.exports={
	jobs:1,
	srvQueueSize:1000,
	mongodb:'mongodb://bdaserver:27017/gearman',
	worker:{
		servers:[{'host':'bdaserver'}]
	},
	client:{
		servers:[{'host':'bdaserver'}],
		loadBalancing: 'RoundRobin'
	},
	retry:2
};
