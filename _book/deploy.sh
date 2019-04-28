#!/bin/bash
build() {
	echo "Begin build"
	gitbook build
}

commit() {
	read -p  "添加本次提交注释:" comm
	git add .
	git commit -m  ''$comm''
}

push() {
	echo "上传代码"
	git push 
}
main() {
	build
	commit
	push
}
main
