'use strict'

const fs = require('fs')
const path = require('path')
const jsdom = require('jsdom')

const DOCS_PATH = path.join(__dirname, 'opengles.docset/Contents/Resources/Documents')

jsdom.env(
	fs.readFileSync(path.join(DOCS_PATH, 'index.html'), 'utf8'),
	(err, window) => {
		if (err) throw err
		const $ = window.document.querySelector.bind(window.document)
		const $$ = window.document.querySelectorAll.bind(window.document)
		Array.from($$('.sample a'))
    .map(a => ({
      name: a.textContent,
      link: a.getAttribute('href'),
      type: 'Function'
    }))
		.forEach(d => {
      console.log(JSON.stringify(d))
    })
	}
)
