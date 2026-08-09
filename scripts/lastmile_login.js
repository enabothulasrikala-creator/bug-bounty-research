#!/usr/bin/env node
const forge = require('node-forge');
const https = require('https');
const crypto = require('crypto');

function encrypt(msg) {
    const keyHex = crypto.randomBytes(8).toString('hex');
    const ivHex = crypto.randomBytes(8).toString('hex');
    console.log(`  keyHex: ${keyHex}`);
    console.log(`  ivHex:  ${ivHex}`);
    
    const cipher = forge.cipher.createCipher('AES-GCM', keyHex);
    cipher.start({ iv: ivHex, additionalData: 'LM', tagLength: 128 });
    cipher.update(forge.util.createBuffer(msg, 'utf8'));
    cipher.finish();
    
    const encodedB64 = forge.util.encode64(cipher.output.data);
    const tagB64 = forge.util.encode64(cipher.mode.tag.data);
    const transmitMsg = keyHex + ivHex + tagB64 + encodedB64;
    return transmitMsg;
}

function encryptPswd(plainText) {
    const formId = '1354141795';
    return encodeURIComponent(encrypt(plainText) + formId);
}

function getPage(path, method, data, cookieStr) {
    return new Promise((resolve, reject) => {
        const body = data ? new URLSearchParams(data).toString() : null;
        const options = {
            hostname: 'lastmilewebuat.hdfcuat.bank.in',
            path: '/IndiaLinkWeb/onlinetransfer/secure' + path,
            method: method || 'GET',
            headers: {
                'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 bugbase',
            },
            rejectUnauthorized: false
        };
        if (body) {
            options.headers['Content-Type'] = 'application/x-www-form-urlencoded';
            options.headers['Content-Length'] = Buffer.byteLength(body);
        }
        if (cookieStr) options.headers['Cookie'] = cookieStr;
        
        const req = https.request(options, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => resolve({
                status: res.statusCode,
                location: res.headers['location'],
                cookies: res.headers['set-cookie'] || [],
                body: data,
                headers: res.headers
            }));
        });
        req.on('error', reject);
        if (body) req.write(body);
        req.end();
    });
}

async function main() {
    console.log('=== Step 1: Get login page ===');
    const page = await getPage('/login.jsp', 'GET');
    const cookieStr = page.cookies.map(c => c.split(';')[0]).join('; ');
    console.log(`Status: ${page.status}`);
    console.log(`Cookies: ${page.cookies.map(c => c.split(';')[0]).join(', ')}`);
    
    // Get formid from page
    const formidMatch = page.body.match(/name="formid"[^>]*value="([^"]*)"/);
    const formid = formidMatch ? formidMatch[1] : '1354141795';
    console.log(`FormID: ${formid}`);
    
    // GroupId from page
    const groupIdMatch = page.body.match(/name="groupId"[^>]*value="([^"]*)"/);
    const groupId = groupIdMatch ? groupIdMatch[1] : 'RGEX';
    console.log(`GroupID: ${groupId}`);
    
    console.log('\n=== Step 2: Encrypt password ===');
    const encryptedPwd = encryptPswd('REDACTED_KNOWN_SECRET');
    console.log(`Encrypted: ${encryptedPwd.substring(0, 100)}...`);
    console.log(`Full length: ${encryptedPwd.length}`);
    
    console.log('\n=== Step 3: Submit login ===');
    const loginResult = await getPage('/LoginAction.jsp', 'POST', {
        entityId: 'REDACTED_KNOWN_SECRET',
        userId: 'REDACTED_KNOWN_SECRET',
        password: 'xxxxxxxx',
        passwordENC: encryptedPwd,
        formid: formid,
        groupId: groupId,
        captchaVisibility: 'N',
        IsVirtualKeyboard: 'false',
        IsTermsCondition: 'true',
        captchaEntered: '',
    }, cookieStr);
    
    console.log(`Status: ${loginResult.status}`);
    console.log(`Location: ${loginResult.location || 'N/A'}`);
    console.log(`New cookies: ${loginResult.cookies ? loginResult.cookies.map(c => c.split(';')[0]).join(', ') : 'none'}`);
    
    // Check body
    const body = loginResult.body;
    if (body.includes('session') && (body.includes('expired') || body.includes('Session'))) {
        console.log('\n>>> RESULT: Session expired - login failed');
    } else if (body.includes('error') || body.includes('Error') || body.includes('invalid') || body.includes('Invalid')) {
        console.log('\n>>> RESULT: Error/invalid - check body');
    } else if (loginResult.status === 302 && loginResult.location) {
        console.log(`\n>>> RESULT: Redirect - possible success! Location: ${loginResult.location}`);
    } else if (body.includes('dashboard') || body.includes('Dashboard') || body.includes('Welcome') || body.includes('welcome')) {
        console.log('\n>>> RESULT: SUCCESS! Dashboard/Welcome found!');
    } else {
        console.log('\n>>> RESULT: Unknown, printing body start:');
        console.log(body.substring(0, 600));
    }
    
    // Check for any JS redirect
    const jsRedirect = body.match(/window\.location[^;]*/);
    if (jsRedirect) console.log(`JS redirect: ${jsRedirect[0]}`);
}

main().catch(e => console.error('Error:', e.message));
