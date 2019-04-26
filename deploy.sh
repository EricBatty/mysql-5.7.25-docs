#!/bin/bash
build() {
	echo "Begin build"
	gitbook build
}

commit() {
	echo "添加本次提交注释"
	git add .
	comm=$1
	git commit -m  '${comm}'
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
