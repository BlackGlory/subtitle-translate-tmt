# subtitle-translate-tmt
使用[腾讯机器翻译](https://cloud.tencent.com/product/tmt) API 为 PotPlayer 翻译实时字幕.

## 必要条件
- PotPlayer 版本 >= 1.7.20977
- [开通腾讯云 机器翻译API](https://console.cloud.tencent.com/tmt)(需实名认证)
- [创建腾讯云 SecretId & SecretKey](https://console.cloud.tencent.com/cam/capi)

## 安装
1. [下载](https://github.com/BlackGlory/subtitle-translate-tmt/archive/master.zip)
2. 解压缩
3. 复制文件 `SubtitleTranslate - tmt.as` 和 `SubtitleTranslate - tmt.ico` 到 `C:\Program Files\DAUM\PotPlayer\Extention\Subtitle\Translate` 文件夹
4. 运行/重启 PotPlayer
5. 菜单->字幕->实时字幕翻译->实时字幕翻译设置->腾讯机器翻译->帐户设置, 填写你的 SecretId 和 SecretKey
6. 配置 PotPlayer 关于实时字幕翻译设置的其他选项, 播放带有字幕文本的视频, 测试效果
