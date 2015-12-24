const ldjson = require('ldjson-stream')
const Transform = require('stream').Transform
process.stdin
.pipe(ldjson.parse())
.pipe(new Transform({
	objectMode: true,
	transform (data, enc, done) {
		this.push(
			`INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ("${data.name}", "${data.type}", "${data.link}");\n`
		)
		done()
	}
}))
.pipe(process.stdout)
