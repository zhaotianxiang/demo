
'use strict';

/**
 * Module dependencies.
 */

const bottleneck = require('mof-bottleneck');
const cheerio = require('mof-cheerio');
const charset = require('mof-charsetparser');
const co = require('co');
const genestamp = require('mof-genestamp');
const json = require('mof-json');
const iconv = require('mof-iconv');
const request = require('mof-request');
const statusCode = require('mof-statuscode');
const Worker = require('floodesh/worker');

/* 
 *  Attach `Spider` instance to `Worker` instance
 *  
 */

const worker = new Worker();

worker.use(co.wrap(bottleneck(worker.config.bottleneck)))
	.use(co.wrap(request(worker.config.downloader)))
	.use(co.wrap(statusCode))
	.use(charset())
	.use(iconv())
	.use(cheerio())
	.use(json())
	.use(co.wrap(worker.parse()))
	.use(genestamp());
