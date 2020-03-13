const moment = require("moment");

'use strict';

module.exports = (ctx, next) => {
	ctx.opt.uri="https://www.baidu.com/"+moment();
	ctx.tasks.push({opt:ctx.opt,next:"home"});
	ctx.app.logger.info("doing");
	return next();
};
