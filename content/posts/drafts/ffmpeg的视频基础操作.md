## 格式转换

FFmpeg 的最简单操作，读取一个输入流，并输出到一个输出流

```shell
ffmpeg -i input.mp4 output.mp4
```

所以，我们可以使用这种方式简单地进行格式转换：

```shell
ffmpeg -i input.mkv output.mp4
```

## 裁剪

我们可以使用 `-ss` 和 `-to` 显式指定片段以进行裁切：

```shell
ffmpeg -ss 00:01:00 -to 00:02:00 -i input.mkv output.mp4
```

以上命令选取了 1 分到 2 分的视频片段，并输出到输出流。需要注意的是，这两个 flag 需要放在输入流之前，否则 FFmpeg 会尝试读取全部输入流，对于一些较大的视频文件，这会导致严重的性能问题。

或是使用 `-t` 指定片段时间：

```shell
ffmpeg -ss 00:01:00 -t 1m -i input.mkv output.mp4
```


## 提取音频

```shell
ffmpeg -i input.mp4 -map 0:a output.mp3
```

## 合并音视频

使用 `-map`:

```shell
ffmpeg -i video.mkv -i audio.mp3 -map 0:v -map 1:a output.mp4
```

虽然有时候不使用 `-map` 也能工作得很好，但一般还是会进行指定。`0:v` 表示第一个输入文件的视频流，它也可以写作 `0:0`，因为一般输入文件的第一个流即为视频流。

一般合并音视频并不需要重新编解码，所以实际使用时常使用下面这种格式：

```shell
ffmpeg -i video.mkv -i audio.mp3 -map 0:v -map 1:a -c:v copy -c:a copy output.mp4
```

对于音视频不等长的情况，输出文件时长等于最长的输入文件时长。对于一段很长的音频，我们的视频只需要它的一部分作为 bgm，使用 `-shortest`：

```shell
ffmpeg -i video.mkv -i audio.mp3 -map 0:v -map 1:a -c:v copy -c:a copy -shortest output.mp4
```
