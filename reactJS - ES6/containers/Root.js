if (process.env.REDUX_ENV === 'development') {
    module.exports = require('./Root.dev');
} else {
    module.exports = require('./Root.prod');
}
