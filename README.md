# OS_like_program
自作エミュレータで学ぶx86アーキテクチャの本を読んで、BISOの機能だけでOSっぽいものを作ってみた  
結局、シミュレータを書くところはほぼ読んでないです...  
また、実装編のプログラムを改造しただけで、ろくにアセンブリの使い方がわかっていないです  
同じように、本の実装編のプログラムをいじって遊びたいけど、例がないかねという人に向けておいておきます。

以下メモ

## コマンドで外部ディスクの名前を確認  
diskutil list

## usbメモリへの書き込み  
ddコマンドを使う

## 書き込み
*書き込み時の注意*
usbメモリがマウント状態だとResource busyというエラーが出るので、マウント状態を外す必要がある  
ステップ?:diskutil　listで外部ストレージの確認  
ステップ1: ls /Volumes で外部ストレージの名前を確認  
ステップ2: diskutil umount (外部ストレージへのパス)　でアンマウント (名前はdisukutil　listで確認したものを使用する)  
ステップ3:  dd コマンドでアセンブルでできた機械語を書き込む  
	dd if=pbr.bin of=¥¥?¥Device¥Harddisk4¥Partition0 bs=512 count=1 (permition deniedと出るので　sudoをつける必要がある)  

make pbr.bin  
以下で機械語作成?　これでできたpbr.binをUSBメモリに書き込んだ
nasm -f bin -o pbr.bin pbr.asm

アセンブル  
nasmを使用

BIOSのフルなドキュメント  
<https://www.embeddedarm.com/documentation/third-party/x86-ebios-43.pdf>  
でシャットダウンする方法を調べた。
レジスタの値をセットしてint 80するとシャットダウンするようにしたかったが、
なぜか、ハードディスクに入ったOSを起動させてしまう。
