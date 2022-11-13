/*
  real time subtitle translate for PotPlayer using Tencent Machine Translation API
  https://github.com/BlackGlory/subtitle-translate-tmt
  https://cloud.tencent.com/product/tmt
*/

// string GetTitle()                             -> get title for UI
// string GetVersion                            -> get version for manage
// string GetDesc()                              -> get detail information
// string GetLoginTitle()                          -> get title for login dialog
// string GetLoginDesc()                          -> get desc for login dialog
// string GetUserText()                            -> get user text for login dialog
// string GetPasswordText()                          -> get password text for login dialog
// string ServerLogin(string User, string Pass)                -> login
// string ServerLogout()                          -> logout
// array<string> GetSrcLangs()                         -> get source language
// array<string> GetDstLangs()                         -> get target language
// string Translate(string Text, string &in SrcLang, string &in DstLang)   -> do translate !!

bool debug = false;

string secretId = '';
string secretKey = ''; // secretKey是一个长度为32的字符串, 包含数字、大写字母、小写字母

uint secondsOfMinute = 60;
uint secondsOfHour = 3600;
uint secondsOfDay = 86400;

// https://cloud.tencent.com/document/api/551/15619
dictionary DstLangTable = {
  {'zh', 'zh'} // 中文
, {'zh-CN', 'zh'} // 简体中文
, {'zh-TW', 'zh'} // 繁体中文
, {'en', 'en'} // 英文
, {'ja', 'jp'} // 日语
, {'ko', 'kr'} // 韩语
, {'de', 'de'} // 德语
, {'fr', 'fr'} // 法语
, {'es', 'es'} // 西班牙文
, {'it', 'it'} // 意大利文
, {'tr', 'tr'} // 土耳其文
, {'ru', 'ru'} // 俄文
, {'pt', 'pt'} // 葡萄牙文
, {'vi', 'vi'} // 越南文
, {'id', 'id'} // 印度尼西亚文
, {'ms', 'ms'} // 马来西亚文
, {'th', 'th' } // 泰文
};

dictionary SrcLangTable = {
  {'', 'auto'} // 自动检测
, {'zh', 'zh'} // 中文
, {'zh-CN', 'zh'} // 简体中文
, {'zh-TW', 'zh'} // 繁体中文
, {'en', 'en'} // 英文
, {'ja', 'jp'} // 日语
, {'ko', 'kr'} // 韩语
, {'de', 'de'} // 德语
, {'fr', 'fr'} // 法语
, {'es', 'es'} // 西班牙文
, {'it', 'it'} // 意大利文
, {'tr', 'tr'} // 土耳其文
, {'ru', 'ru'} // 俄文
, {'pt', 'pt'} // 葡萄牙文
, {'vi', 'vi'} // 越南文
, {'id', 'id'} // 印度尼西亚文
, {'ms', 'ms'} // 马来西亚文
, {'th', 'th' } // 泰文
};

uint getTimestamp() {
  // `datetime(1970, 1, 1)` may be an invalid value, which is why `datetime(1970, 1, 2)`
  datetime fakeUnix = datetime(1970, 1, 2, 0, 0, 0);
  datetime now = datetime();
  uint timestamp = now - fakeUnix;
  timestamp += secondsOfDay; // patch `fakeUnix`
  return timestamp;
}

string byteToUTF8Char(uint byte) {
  // AngelScript中的string类型可以视作一个字节数组
  string result = '';
  result.resize(1);
  result[0] = byte;
  return result;
}

string repeat(string str, uint times) {
  string result = '';
  for (uint i = 0; i < times; i++) {
    result += str;
  }
  return result;
}

string replace(string str, string substr, string newSubstr) {
  array<string> arr = str.split(substr);
  string result = join(arr, newSubstr);
  return result;
}

string createQuerystring(dictionary query) {
  array<string> keys = query.getKeys();
  keys.sortAsc();
  uint length = keys.length();
  array<string> pairs(length);
  for (uint i = 0; i < length; i++) {
    string key = keys[i];
    string value = string(query[key]);
    pairs[i] = key + '=' + value;
  }
  string querystring = join(pairs, '&');
  return querystring;
}

// for debugging
void printAsHex(string str) {
  string hex = '';
  for (uint i = 0; i < str.length(); i++) {
    // AngelScript中的string类型可以视作一个字节数组
    hex += formatInt(str[i], 'H') + ' ';
  }
  HostPrintUTF8(hex);
}

// 将十六进制表示转换为UTF8字符串
// 幸运的是UTF8同时也是AngelScript的字符串编码方式
string hexToUTF8(string hex) {
  // 两位十六进制为一个字节
  uint resultLength = hex.length() / 2;

  // AngelScript中的string类型可以视作一个字节数组
  string result = '';
  result.resize(resultLength);
  for (uint i = 0; i < resultLength; i++) {
    result[i] = parseInt(hex.substr(i * 2, 2), 16);
  }
  return result;
}

// AngelScript中的string类型可以视作一个字节数组
string xorBytes(string leftBytes, string rightBytes) {
  string result = '';
  result.resize(leftBytes.length());
  for (uint i = 0; i < leftBytes.length(); i++) {
    result[i] = leftBytes[i] ^ rightBytes[i];
  }
  return result;
}

string hmacSHA1(string key, string message) {
  uint blockSize = 64; // bytes

  if (key.length() > blockSize) {
    // HostHashSHA1函数的返回值是长度为40的十六进制字符串, 而不是Hash值本身.
    key = HostHashSHA1(key);
  }

  // 如果字节数少于blockSize, 则在右侧填充零
  if (key.length() < blockSize) {
    key += repeat(
      byteToUTF8Char(0)
    , blockSize - key.length()
    );
  }

  string ipadKey = xorBytes(
    repeat(byteToUTF8Char(0x36), blockSize)
  , key
  );
  string opadKey = xorBytes(
    repeat(byteToUTF8Char(0x5c), blockSize)
  , key
  );

  // HostHashSHA1函数的返回值是长度为40的十六进制字符串, 而不是Hash值本身.
  return hexToUTF8(
    HostHashSHA1(
      opadKey
      // HostHashSHA1函数的返回值是长度为40的十六进制字符串, 而不是Hash值本身.
    + hexToUTF8(
        HostHashSHA1(ipadKey + message)
      )
    )
  );
}

// https://cloud.tencent.com/document/api/213/15693
string createSignature(
  string querystring
, string host
, string method = 'GET'
, string path = '/'
) {
  return HostBase64Enc(
    hmacSHA1(
      secretKey
    , method + host + path + '?' + querystring
    )
  );
}

JsonValue parseJSON(string json) {
  JsonReader reader;
  JsonValue data;
  reader.parse(json, data);
  return data;
}

string GetTitle() {
  return
    '{$CP936=腾讯机器翻译$}'
    '{$CP0=Tencent Machine Translate$}';
}

string GetVersion() {
  return '1';
}

string GetDesc() {
  return
    '<a href="https://github.com/BlackGlory/subtitle-translate-tmt">'
      'Extension Source Code'
    '</a>'
    ' '
    '<a href="https://cloud.tencent.com/product/tmt">'
      'About TMT'
    '</a>';
}

string GetLoginTitle() {
  return
    '{$CP936=填写 API 密钥$}'
    '{$CP0=Input Tencent Cloud API key$}';
}

string GetLoginDesc() {
  return 'https://console.cloud.tencent.com/cam/capi';
}

string GetUserText() {
  return 'SecretId:';
}

string GetPasswordText() {
  return 'SecretKey:';
}

string ServerLogin(string username, string password) {
  if (username.empty() || password.empty()) return 'fail';

  secretId = username;
  secretKey = password;
  return '200 ok';
}

void ServerLogout() {
  secretKey = '';
  secretId = '';
}

array<string> GetSrcLangs() {
  array<string> result = SrcLangTable.getKeys();
  return result;
}

array<string> GetDstLangs() {
  array<string> result = DstLangTable.getKeys();
  return result;
}

string Translate(string text, string &in srcLang, string &in dstLang) {
  if (debug) {
    HostOpenConsole();
  }

  dictionary query = {
    {'Action', 'TextTranslate'}
  , {'Version', '2018-03-21'}
  , {'Region', 'ap-shanghai'}
  , {'Timestamp', formatInt(getTimestamp())}
  , {'Nonce', formatInt(HostGetTickCount())}
  , {'SecretId', secretId}
  , {'SourceText', text}
  , {'Source', string(SrcLangTable[srcLang])}
  , {'Target', string(DstLangTable[dstLang])}
  , {'ProjectId', formatInt(0)}
  };

  string signature = createSignature(createQuerystring(query), 'tmt.tencentcloudapi.com');
  query['SourceText'] = HostUrlEncode(string(query['SourceText']));
  string querystring = createQuerystring(query);
  string url = 'https://tmt.tencentcloudapi.com/?'
             + querystring + '&'
             + 'Signature=' + HostUrlEncode(signature);
  string json = HostUrlGetString(url);
  if (debug) {
    HostPrintUTF8(json);
  }
  JsonValue data = parseJSON(json);

  if (data.isObject()) {
    JsonValue response = data['Response'];

    if (response.isObject()) {
      JsonValue targetText = response['TargetText'];

      if (targetText.isString()) {
        string translatedText = replace(targetText.asString(), '*', '\n');

        if (debug) {
          HostPrintUTF8(
            string(SrcLangTable[srcLang]) + '=>' + string(DstLangTable[dstLang])
          );
          HostPrintUTF8(text + '\n=>\n' + translatedText);
        }

        srcLang = 'UTF8';
        dstLang = 'UTF8';
        return translatedText;
      }
    }
  }

  return '';
}
