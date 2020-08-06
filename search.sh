#!/bin/bash
# hacker-scripts by ZL, https://objczl.com
# Copyright (C) 2020 Liang Zeng.
###
### search.sh — search plain text file with multi-keywords
###
### Usage:
###     search.sh [word1|word2|word2] [path]
###
### Options:
###     <wordx>   Input keywords to search.
###     <path>    Searching path.
###     -h        Show this message.

help() {
	awk -F'### ' '/^###/ { print $2 }' "$0"
}

if [[ $# == 0 || "$1" == "-h" ]]; then
	help
	exit 1
fi

dir=$(pwd)
array=("$@")
if [[ -d ${!#} ]]; then
	dir=${!#}
	array=("${@:1:$#-1}")
fi

pattern=${array[0]}
for (( i = 1; i < ${#array[@]}; i++ )); do
	pattern+='|'
	pattern+=${array[i]}
done

tmp_file=/tmp/rg.tmp.files.$
res_file=/tmp/rg.files.$

function add_quotes()
{
	:> $tmp_file
	while IFS= read -r file
	do
		echo \""$file\"" >> "$tmp_file"
	done<$res_file

	cat $tmp_file > $res_file
}

function search()
{
	rg -i -l "$pattern" "$dir" > $res_file
	add_quotes

	list=("$@")
	:> $tmp_file
	for word in "${list[@]}"
	do
		<$res_file xargs rg -i -l "$word" > $tmp_file
		cat $tmp_file > $res_file
		add_quotes
	done
}

search "${array[@]}"

< $res_file \
    xargs rg -i --color always --heading --line-number "$pattern" --sort path \
    | less -R

:> $tmp_file
:> $res_file
