> [!IMPORTANT]
> 该项目依赖的[接口将于2027年10月1日关闭](https://cloud.tencent.com/announce/detail/2448).

# subtitle-translate-tmt
使用[腾讯机器翻译]API为PotPlayer翻译字幕.

[腾讯机器翻译]: https://cloud.tencent.com/product/tmt

## 必要条件
- PotPlayer 版本 >= 1.7.20977
- [开通腾讯云机器翻译API](https://console.cloud.tencent.com/tmt)(需实名认证).
- [创建腾讯云SecretId和SecretKey](https://console.cloud.tencent.com/cam/capi).

## 安装
1. [下载](https://github.com/BlackGlory/subtitle-translate-tmt/archive/master.zip).
2. 解压缩.
3. 复制文件`SubtitleTranslate - tmt.as`和`SubtitleTranslate - tmt.ico`到`C:\Program Files\DAUM\PotPlayer\Extension\Subtitle\Translate`文件夹.
4. 运行/重启PotPlayer.
5. 菜单->字幕->实时字幕翻译->实时字幕翻译设置->腾讯机器翻译->帐户设置, 填写你的SecretId和SecretKey.
6. 配置PotPlayer关于实时字幕翻译设置的其他选项, 播放带有字幕文本的视频, 测试效果.
