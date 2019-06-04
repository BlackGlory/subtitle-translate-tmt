# subtitle-translate-tmt

使用[腾讯机器翻译](https://cloud.tencent.com/product/tmt)API为PotPlayer翻译实时字幕.

## 需要

* PotPlayer >= 1.7.18658\*
* [开通机器翻译](https://console.cloud.tencent.com/tmt)(帐号需实名认证)
* [创建腾讯云 SecretId & SecretKey](https://console.cloud.tencent.com/cam/capi)

\* 在编写此文档时, 其为Beta版本. 你可以在[此处](http://t1.daumcdn.net/potplayer/beta/PotPlayerSetup.exe)下载到Beta版.

## 安装

1. [下载](https://github.com/BlackGlory/subtitle-translate-tmt/archive/master.zip)
2. 解压缩
3. 复制 `SubtitleTranslate - tmt.as` 和 `SubtitleTranslate - tmt.ico` 到 `DAUM\PotPlayer\Extention\Subtitle\Translate` 文件夹
4. 运行/重启 PotPlayer
5. 菜单->字幕->实时字幕翻译->实时字幕翻译设置->腾讯机器翻译->帐户设置, 填写 SecretId & SecretKey
