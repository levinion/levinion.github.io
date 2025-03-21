set shell:=["fish","-c"]

serve:
  watchexec --ignore-nothing -o restart -w content gorush serve

build:
  gorush build

push:
  fastpush "update"
