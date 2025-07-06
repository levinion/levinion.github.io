下载m4a音频：

```shell
yt-dlp \
  -f "bestaudio[ext=m4a]" \
  --extract-audio \
  --audio-format m4a \
  --embed-metadata \
  --embed-thumbnail \
  --cookies-from-browser firefox \
  --download-archive archive.txt \
  <url>
```