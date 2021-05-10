'カレントディレクトリ取得
dim fso
set fso = createObject("Scripting.FileSystemObject")

'画面非表示でps1ファイルをキックさせる
Set objWShell = CreateObject("Wscript.Shell")
objWShell.run "powershell -ExecutionPolicy Bypass -command .\bypass.ps1", vbHide