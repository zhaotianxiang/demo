
'use strict';

const winston = require('winston');
const logBaseDir = require('./index.js').logBaseDir;
const rotate = require('winston-daily-rotate-file');
const path = require('path');
const pkg = require(path.join(process.cwd(),'package'));

const logFloodesh = winston.loggers.get('floodesh');
const logClient = winston.loggers.get('Client');
const logWorker = winston.loggers.get('Worker');
const logServer = winston.loggers.get('JobServer');
const logJob = winston.loggers.get('Job');
const logLB = winston.loggers.get('LBStrategy');
const logProtocol = winston.loggers.get('protocol');
const logDir = path.join(logBaseDir,pkg.name);

const mode = path.basename(process.argv[1].replace(/\.js$/,''));
const level = 'info';

function getRotated(path, label, name){
	return new rotate({datePattern:'YYYY-MM-DD', filename: path, json:false,label, name});
}

const workerTransportFilePath = path.join(logDir, `floodesh.log.%DATE%.${process.pid}`);
const clientTransportFilePath = path.join(logDir, `client.log.%DATE%.${process.pid}`);
const floodeshRotate = getRotated(workerTransportFilePath, 'floodesh', 'floodesh');
const clientRotate = getRotated(clientTransportFilePath, 'floodesh', 'client');

let gearmanRotate=null;
if(mode==='worker'){
	gearmanRotate = floodeshRotate;//getRotated(path.join(logDir,'gearman.log.'+process.pid+'.'));
}else{
	gearmanRotate = clientRotate;
}

logFloodesh.configure({
	level: level,
	transports: [
		floodeshRotate
	]
});

logClient.configure({
	level:level,
	transports: [
		clientRotate
	]
});

logWorker.configure({
	level:level,
	transports: [
		floodeshRotate
	]
});

logServer.configure({
	level:level,
	transports: [
		gearmanRotate
	]
});

logJob.configure({
	level:level,
	transports: [
		gearmanRotate
	]
});

logLB.configure({
	level:level,
	transports: [
		gearmanRotate
	]
});

logProtocol.configure({
	level:level,
	transports: [
		gearmanRotate
	]
});

module.exports={
	logDir:logDir
};
