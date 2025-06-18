serve:
  watchexec --ignore-nothing -o restart -w content gorush serve || true

build:
  gorush build

push:
  git add .
  git commit -m "update"
  git push origin main
