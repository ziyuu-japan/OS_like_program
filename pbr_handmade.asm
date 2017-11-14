    org 0x7c00
    jmp short entry
    nop ;ここからentryまではもともとの記述をいれるはずだった
    db "MSDOS5.0"
    dw 512
    db 4
    dw 4
    db 2
    dw 512
    dw 0
    db 248
    dw 250
    dw 63
    dw 255
    dd 0
    dd 256000
    db 128
    db 0
    db 41
    dd 2963790959
    db "NO NAME    "
    db "FAT16   "
    times 0x3e - ($ - $$) db 0
entry:
    mov ax, 0      ; 各レジスタの初期化
    mov ss, ax
    mov sp, 0x7c00
    mov ds, ax
    mov es, ax

    mov ax, 0x0013 ; 画面モード設定
    int 0x10

    mov bl, 50 ;blレジスタで文字の色を設定できる
    mov si, msg1 ;おそらくmsg1が文字列の先頭アドレスをもっている
    call puts
    mov bl, 50
    mov si, msg2
    call puts
    mov bl, 50
    mov si, msg3
    call puts
    mov bl, 50
    mov si, msg4
    call puts
    jmp print_LF ;一度Guest....のメッセージを表示
    ;ここまでで最初のメッセージ表示終了
before_input:
    mov ah, 0x00
    int 0x16 ;ここで入力待ち...入力されるとALレジスタにそのキーのASCIIコードが入る
    cmp ah, 0x1c ;0x1cはエンターのメイク...同じならZF=1となる
    je print_LF ;ZF=1で改行(エンター押すと改行する)
    cmp ah, 0x01 ;0x01はエスケープのメイク...エスケープ
    je boot ;エスケープを押すとおそらくusbメモリ以外のブートセクタを探す
    mov ah,  0x0e ;ここと下の行で１文字表示のレジスタ状態
    mov bh, 0
    int 0x10 ;エンターとエスケープ以外は普通に表示(１文字ずつ)
    jmp before_input
    ;ここまでオリジナル
fin:
    hlt
    jmp fin

boot:
    int 0x19 ;おそらく次に優先となっている起動ディスクのブートセクタをみる

print_LF: ;改行を出力して、文字入力で待機に戻る
    mov si, LF
AT_THE_BIGINNING_OF_LF:
    mov al, [si]
    inc si
    cmp al, 0
    je DISPLAY_UNIX_LIKE_MSG ;ZF=1のときに戻る
    mov ah, 0x0e
    mov bh, 0
    int 0x10
    jmp AT_THE_BIGINNING_OF_LF

DISPLAY_UNIX_LIKE_MSG:
    mov si, FINUX_MSG_AT_THE_BEGINNING
    AT_THE_BIGINNING_OF_UNIX_LIKE:
    mov al, [si]
    inc si
    cmp al, 0
    je before_input
    mov ah, 0x0e
    mov bh, 0
    int 0x10
    jmp AT_THE_BIGINNING_OF_UNIX_LIKE

handmade_puts:
    mov al, [si]
    inc si
    cmp al, 0
    je before_input
    mov ah, 0x0e
    mov bh, 0
    int 0x10
    jmp handmade_puts

puts:
    mov al, [si] ;al(eaxレジスタの下位8ビット)に[]をつけると、その番地上の値を取得できる
    inc si ;ソースインデックス
    cmp al, 0 ;同じ値ならZF(ゼロフラグ)=1となる
    je  puts_end ;ZF(ゼロフラグ)が1のときに飛ぶ
    mov ah, 0x0e ; １文字表示する(al)
    mov bh, 0 ; video page num : 0x00
    int 0x10 ;BIOSの呼び出し
    jmp puts
puts_end:
    ret

LF: ;改行...0x0d(CR)と0x0a(LF)でwindowsとunix系の改行に対応できる
    db 0x0d, 0x0a, 0

FINUX_MSG_AT_THE_BEGINNING:
    db "GUEST@FINUX:~$ ", 0

msg1:
    db "WELCOME TO FINUX.", 0x0d, 0x0a, 0 ;文字列の最後を0にすると、文字列の最後として認識される
msg2:
    db "FINUX MEANS FAKE LINUX.", 0x0d, 0x0a, 0
msg3:
    db "FINUX DOESN'T HAVE ANY USEFUL FUNCTIONALITIES.", 0x0d, 0x0a, 0
msg4:
    db "PLEASE FLEE TO PLAY!!", 0x0d, 0x0a, 0

    times 510 - ($ - $$) db 0
    db 0x55, 0xaa
