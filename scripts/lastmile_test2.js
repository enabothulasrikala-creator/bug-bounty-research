#!/usr/bin/env node
const forge = require('node-forge');
const https = require('https');
const crypto = require('crypto');

function encrypt(msg) {
    const keyHex = crypto.randomBytes(8).toString('hex');
    const ivHex = crypto.randomBytes(8).toString('hex');
    const cipher = forge.cipher.createCipher('AES-GCM', keyHex);
    cipher.start({ iv: ivHex, additionalData: 'LM', tagLength: 128 });
    cipher.update(forge.util.createBuffer(msg, 'utf8'));
    cipher.finish();
    const encodedB64 = forge.util.encode64(cipher.output.data);
    const tagB64 = forge.util.encode64(cipher.mode.tag.data);
    return keyHex + ivHex + tagB64 + encodedB64;
}

function encryptPswd(plainText) {
    return encodeURIComponent(encrypt(plainText) + '1354141795');
}

function request(path, method, data, cookieStr, referer) {
    return new Promise((resolve, reject) => {
        const body = data ? new URLSearchParams(data).toString() : null;
        const options = {
            hostname: 'lastmilewebuat.hdfcuat.bank.in',
            path: '/IndiaLinkWeb/onlinetransfer/secure' + path,
            method: method || 'GET',
            headers: {
                'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) bugbase',
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
                'Accept-Language': 'en-US,en;q=0.5',
            },
            rejectUnauthorized: false
        };
        if (body) {
            options.headers['Content-Type'] = 'application/x-www-form-urlencoded';
            options.headers['Content-Length'] = Buffer.byteLength(body);
        }
        if (cookieStr) options.headers['Cookie'] = cookieStr;
        if (referer) options.headers['Referer'] = referer;
        
        const req = https.request(options, (res) => {
            let data = '';
            res.on('data', chunk => data += chunk);
            res.on('end', () => resolve({
                status: res.statusCode,
                location: res.headers['location'],
                cookies: res.headers['set-cookie'] || [],
                body: data
            }));
        });
        req.on('error', reject);
        if (body) req.write(body);
        req.end();
    });
}

async function main() {
    const page = await request('/login.jsp', 'GET');
    console.log('=== Login page loaded ===');
    const cookies = page.cookies.map(c => c.split(';')[0]).join('; ');
    const formid = (page.body.match(/name="formid"[^>]*value="([^"]*)"/) || [, ''])[1];
    console.log(`formid: ${formid}`);
    
    const encPwd = encryptPswd('REDACTED_KNOWN_SECRET');
    console.log(`Encrypted pwd length: ${encPwd.length}`);
    
    const result = await request('/LoginAction.jsp', 'POST', {
        entityId: 'REDACTED_KNOWN_SECRET',
        userId: 'REDACTED_KNOWN_SECRET',
        password: 'xxxxxxxx',
        passwordENC: encPwd,
        formid: formid,
        groupId: 'RGEX',
        captchaVisibility: 'N',
        IsVirtualKeyboard: 'false',
        IsTermsCondition: 'true',
        captchaEntered: '',
    }, cookies, 'https://lastmilewebuat.hdfcuat.bank.in/IndiaLinkWeb/onlinetransfer/secure/login.jsp');
    
    console.log(`Login: ${result.status} -> ${result.location || 'none'}`);
    
    if (result.location) {
        const newCookies = (cookies + '; ' + result.cookies.map(c => c.split(';')[0]).join('; ')).replace(/^;?\s*/, '');
        const page2 = await request('/login.jsp', 'GET', null, newCookies);
        
        // Check for error messages
        console.log(`Login page after attempt: ${page2.status}`);
        console.log(`APPLICATIONID set: ${page2.cookies.some(c => c.includes('APPLICATIONID'))}`);
        
        // Print errordivs
        const errDivs = [...page2.body.matchAll(/<div[^>]*class="errordiv"[^>]*>([\s\S]*?)<\/div>/gi)];
        errDivs.forEach(d => {
            const content = d[1].replace(/<[^>]*>/g, '').trim();
            if (content) console.log(`Error div: ${content}`);
        });
        
        // Look for error-related content
        const errorMatches = page2.body.match(/[^<>]{0,100}(Invalid|invalid|Error|error|Wrong|wrong|Fail|fail)[^<>]{0,100}/g);
        if (errorMatches) {
            errorMatches.slice(0, 5).forEach(m => {
                const cleaned = m.replace(/<[^>]*>/g, '').trim();
                if (cleaned) console.log(`Error text: ${cleaned}`);
            });
        }
        
        // Show first 500 chars of body
        console.log(`\nBody excerpt: ${page2.body.substring(0, 500)}`);
    }
}

main().catch(e => console.error('Error:', e.message));
