#!/bin/sh
## CD 轉檔小程式
## 2021/04/03

## 這裡放你的MP3檔
input_dir='/run/user/1000/gvfs/cdda:host=sr0/'
## 暫存資料夾(先確實把音軌摳到暫存資料夾再轉檔，可以避免CD毀損造成的片段靜音情況)
temp_dir='/tmp/CD_In/'
## 轉檔前格式詢問(Linux 大部分預設似乎是wav)
read -p 'Input Format(.xxx, we need "xxx") [wav] >> ' input_fmt
## 輸出資料夾詢問(預設放在tmp)
read -p 'Output Directory [/tmp/CD_Out] >> ' output_dir

## 設定預設值的部分
if [[ -z ${input_fmt} ]]; then
	input_fmt='wav'
fi

if [[ -z ${output_dir} ]]; then
	output_dir='/tmp/CD_Out'
fi

## 輸出資料夾存在，檔案直接寫進去，否則建一個
if [[ -d ${output_dir} ]]; then
 	echo "Directory exists"
else
 	mkdir ${output_dir}
fi

## 暫存資料夾存在就重建一個(清空)
if [[ -d ${temp_dir} ]]; then
 	echo "Directory exists, delete first."
 	rm -r ${temp_dir}
fi

mkdir ${temp_dir}

## 把CD音軌複製過去
echo "Copying CD..."
cp ${input_dir}* ${temp_dir}

## 利用ffmpeg將檔案轉成320K的MP3
## 要修改可以參考ffmpeg的相關引數(-b:a 320k那段)
for filename in ${temp_dir}*.${input_fmt}; do
	echo "Converting $(basename "$filename")"
    ffmpeg -i "$filename" -codec:a libmp3lame -b:a 320k "${output_dir}/$(basename "$filename" .${input_fmt}).mp3"
done