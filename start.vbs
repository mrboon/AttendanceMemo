'�J�����g�f�B���N�g���擾
dim fso
set fso = createObject("Scripting.FileSystemObject")

'��ʔ�\����ps1�t�@�C�����L�b�N������
Set objWShell = CreateObject("Wscript.Shell")
objWShell.run "powershell -ExecutionPolicy Bypass -command .\bypass.ps1", vbHide