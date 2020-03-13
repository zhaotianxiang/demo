
'use strict';

const fs = require('fs');
const moment = require('moment');
const Client = require('floodesh/client');

class demo extends Client{
	constructor(){
		super();
		this.name = 'demo';
		this.cnt = 0;
		//this.seed = ['https://www.google.com/'];
		this.once('init', (done) => this.onInit(done))
			.on('data', (data, done) => this.onData(data, done))
			.once('exit', () => this.onEnd());
	}

	onInit(done){
		this.output = fs.createWriteStream('/data/demo/demo_'+moment().format('YYYY-MM-DD')+'.csv');
		this.output.write('\ufeff');
		done();
	}
	
	initRequests(){// will not be invoked if seed is not empty.
		return [{opt:'https://www.baidu.com/', next:'home'}];
	}
	
	onData(data,done){
		this.output.write(data.get('data'));
		done();
	}
	
	onComplete(tasks){
		return tasks.length;
	}
	
	onEnd(){
		this.output.end();
	}
}

module.exports = demo;
