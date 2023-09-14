const crypto = require('crypto');
const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

// console.log(`---------- cjh, argc:${process.argv.length}, argv:${process.argv}`);
// console.log(`is array? ` + Array.isArray(process.argv));


const args = process.argv.slice(3);

const libPath = process.argv[2]

console.log(`=-==-=> .a=` + libPath);


function getObjectMD5(fileName) {
	const binaryData = fs.readFileSync(fileName);
	const uint8Array = new Uint8Array(binaryData);

	const md5Hash = crypto.createHash('md5');
	md5Hash.update(uint8Array);
	const md5Digest = md5Hash.digest('hex');
	return md5Digest;
}


const fileNameCount = {};


let i = 0;
for (const fileName of args) {
	let e = fileNameCount[fileName];
	if (e) {
    	e.count++;
    	e.index.push(i);
  	} else {
    	fileNameCount[fileName] = { count: 1, index: [i] };
  	}
  	++i;
}

async function extractOneObject(index, name) {
	return new Promise((resolve, reject)=>{
		const child = spawn('emar', [`-x`, libPath, name]);

		// child.stdout.on('data', (data) => {
		//   console.log(`子进程输出: ${data}`);
		// });

		child.stderr.on('data', (data) => {
		  	console.error(`extractOneObject: ${data}`);
		  	process.exit(1);
		});

		child.on('close', (code) => {
			if (code === 0) {
				const md5 = getObjectMD5(name);
				console.log(`name:${name}, index:${index}, md5: ${md5}`);
				short_md5 = md5.slice(0, 8);
				const newFileName = path.basename(name, path.extname(name)) + '-' + short_md5 + '.o';
				fs.renameSync(name, newFileName);

				resolve();
			} else {
				reject();
			}
		});
	});

}

async function deleteObject(name) {
	return new Promise((resolve, reject)=>{
		const child = spawn('emar', [`d`, libPath, name]);

		child.stderr.on('data', (data) => {
		  	console.error(`deleteObject: ${data}`);
		  	process.exit(1);
		});

		child.on('close', (code) => {
			if (code === 0) {
				resolve();
			} else {
				reject();
			}
		});
		
	});
}


async function main() {
	for (const k in fileNameCount) {
		const v = fileNameCount[k];
		if (v.count > 1) {
			for (let i = 0; i < v.index.length; ++i) {
				console.log(`same filename: ${k}: index: ${v.index[i]}, count: ${v.count}`);
				await extractOneObject(v.index[i], k);
				await deleteObject(k);
			}
		}
	}
}

main();
