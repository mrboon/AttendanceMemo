[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')  				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('PresentationCore')      				| out-null
[Reflection.Assembly]::LoadFrom("$PSScriptRoot\assembly\MahApps.Metro.dll")      | out-null
[Reflection.Assembly]::LoadFrom("$PSScriptRoot\assembly\System.Windows.Interactivity.dll")      | out-null
[System.Windows.Forms.Application]::EnableVisualStyles()

Set-PSDebug -Strict
Add-Type -AssemblyName PresentationFramework, System.Windows.Forms

function LoadXml ($global:filename)
{
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}

$XamlMainWindow=LoadXml("$PSScriptRoot\Mainmenu.xaml")
$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$frm=[Windows.Markup.XamlReader]::Load($Reader)

$textKaishi = $frm.FindName("textKaishi")
$textOwari = $frm.FindName("textOwari")
$textGenba = $frm.FindName("textGenba")
$textRiyu = $frm.FindName("textRiyu")

$texteditdate = $frm.FindName("texteditDate")
$texteditYoubi = $frm.FindName("texteditYoubi")
$texteditJikan = $frm.FindName("texteditJikan")
$texteditGenba = $frm.FindName("texteditGenba")
$texteditRiyu = $frm.FindName("texteditRiyu")

$textselectID = $frm.FindName("selectID")
$textsansyo = $frm.FindName("textsansyo")
$listView = $frm.FindName("listview")
$about = $frm.FindName("aboutdialog")
$NowDBName = $frm.FindName("NowDBName")

$ToMail = $frm.FindName("ToMail")
$Subject = $frm.FindName("Subject")
$FromMail = $frm.FindName("FromMail")
$MailMain = $frm.FindName("MailMain")

# about:https://github.com/dev4sys/PsCustomDialog
$XamlsampleWindow=LoadXml("$PSScriptRoot\Sample.xaml")
$read=(New-Object System.Xml.XmlNodeReader $XamlsampleWindow)
$SampleForm=[Windows.Markup.XamlReader]::Load($read)
        $SampleDialog = [MahApps.Metro.Controls.Dialogs.CustomDialog]::new($frm)
        $settings             = [MahApps.Metro.Controls.Dialogs.MetroDialogSettings]::new()
        $settings.ColorScheme = [MahApps.Metro.Controls.Dialogs.MetroDialogColorScheme]::Theme
        $SampleDialog.AddChild($SampleForm)
$closeMe = $SampleForm.FindName("closeMe")
$closeMe.add_Click({
    $SampleDialog.RequestCloseAsync()
})
$about.add_Click({
[MahApps.Metro.Controls.Dialogs.DialogManager]::ShowMetroDialogAsync($frm, $SampleDialog, $settings)
})

# DB�ǂݍ��݃t���O
# �N�����͎����������ꂽ�̂�ǂݍ���
$global:DBFlag = 0

function OldDB{
    $DBPath = $textsansyo.text
    # �O���[�o���ϐ��Ƀt���O�ݒ�
    $global:DBFlag = 1
    $NowDBName.text = $DBPath
    If("" -eq $textsansyo.text){return}
    $View = Import-Csv $DBPath -Encoding Default
    $listitems = @()
    for ($i = 1; $i -lt 2; $i += 1) {
        $item = {} | Select ID,Date,Youbi,Jikan,Basho,Riyu
        $item = $View
        $listitems += $item
    }
    $listView.ItemsSource = @($listitems)
    $wsobj = new-object -comobject wscript.shell
    $wsobj.popup("DB��ǂݍ��݂܂���`r`n����DB��ǂݍ��܂��ɂ̓A�v�����ċN�����Ă�������", 0,"DB�Ǎ�")
}

function sendmail{
    If(-not(Test-Path "$PSScriptRoot\setting.json")){return}
    $tempjsonfilepath = Get-Content "$PSScriptRoot\setting.json" -raw | ConvertFrom-Json
    $mPass = convertto-securestring $tempjsonfilepath.Password -asplaintext -force;
    $mCred = New-Object -typename System.Management.Automation.PSCredential -argumentlist $tempjsonfilepath.FromMail, $mPass;
    Send-MailMessage `
     -from       $tempjsonfilepath.FromMail `
     -to         $tempjsonfilepath.ToMail `
     -subject    $Subject.text `
     -body       $MailMain.text `
     -smtpServer $tempjsonfilepath.SmtpServer `
     -Port       $tempjsonfilepath.Port `
     -Credential $mCred `
     -Encoding ([System.Text.Encoding]::UTF8) `
     -UseSSL
    $wsobj = new-object -comobject wscript.shell
    $wsobj.popup("���[���𑗐M���܂���", 0,"���t����")
}

function mailsetting{
    # �����ݒ�ǂݍ���
    $XamlMainWindow=LoadXml("$PSScriptRoot\MailSetting.xaml")
    $Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
    $MailSettingfrm=[Windows.Markup.XamlReader]::Load($Reader)
    $textToMail = $MailSettingfrm.FindName("ToMail"); $textSubject = $MailSettingfrm.FindName("Subject"); $textFromMail = $MailSettingfrm.FindName("FromMail"); $textPassword = $MailSettingfrm.FindName("Password")
    $textSmtpServer = $MailSettingfrm.FindName("SmtpServer"); $textPort = $MailSettingfrm.FindName("Port");$buttonmailsetting = $MailSettingfrm.FindName("buttonMailSet")
    $textMainmes1 = $MailSettingfrm.FindName("Mainmes1"); $textMainmes2 = $MailSettingfrm.FindName("Mainmes2")
    $ToMail = $textToMail.text; $Subject = $textSubject.text; $FromMail = $textFromMail.text; $SmtpServer = $textSmtpServer.text; $Port = $textPort.text; $Password = $textPassword.password
    $Mainmes1 = $textMainmes1.text; $Mainmes2 = $textMainmes2.text

    # json����������쐬(���ڂ̂ݍ쐬)
    If(-not(Test-Path "$PSScriptRoot\setting.json")){
        $tempjsonfilepath = Get-Content "$PSScriptRoot\setting.json" -raw | ConvertFrom-Json
        $json = @{ToMail=""}
        ConvertTo-Json $json | Out-File "$PSScriptRoot\setting.json" -Encoding utf8 -Append
        $tempjsonfilepath = Get-Content "$PSScriptRoot\setting.json" -raw | ConvertFrom-Json
        $tempjsonfilepath | Add-Member -MemberType NoteProperty -Name 'ToMail' -Value "" -Force
        $tempjsonfilepath | Add-Member -MemberType NoteProperty -Name 'Subject' -Value "" -Force
        $tempjsonfilepath | Add-Member -MemberType NoteProperty -Name 'FromMail' -Value "" -Force
        $tempjsonfilepath | Add-Member -MemberType NoteProperty -Name 'Password' -Value "" -Force
        # �������͂ō��ڂ�����̂ō��Ȃ������������ۂ�
        #$tempjsonfilepath | Add-Member -MemberType NoteProperty -Name 'SmtpServer' -Value "" -Force
        #$tempjsonfilepath | Add-Member -MemberType NoteProperty -Name 'Port' -Value "" -Force
        $tempjsonfilepath | Add-Member -MemberType NoteProperty -Name 'Mainmes1' -Value "" -Force
        $tempjsonfilepath | Add-Member -MemberType NoteProperty -Name 'Mainmes2' -Value "" -Force
        ConvertTo-Json $tempjsonfilepath | set-content "$PSScriptRoot\setting.json"
    }

    # �e�L�X�g�u���b�N�ɏ�񂠂���������
    $tempjsonfilepath = Get-Content "$PSScriptRoot\setting.json" -raw | ConvertFrom-Json
    If($Null -ne $tempjsonfilepath.ToMail){$textToMail.text = $tempjsonfilepath.ToMail}
    If($Null -ne $tempjsonfilepath.Subject){$textSubject.text = $tempjsonfilepath.Subject}
    If($Null -ne $tempjsonfilepath.FromMail){$textFromMail.text = $tempjsonfilepath.FromMail}
    If($Null -ne $tempjsonfilepath.Password){$textPassword.password = $tempjsonfilepath.Password}
    If($Null -ne $tempjsonfilepath.SmtpServer){$textSmtpServer.text = $tempjsonfilepath.SmtpServer}
    If($Null -ne $tempjsonfilepath.Port){$textPort.text = $tempjsonfilepath.Port}
    If($Null -ne $tempjsonfilepath.Mainmes1){$textMainmes1.text = $tempjsonfilepath.Mainmes1}
    If($Null -ne $tempjsonfilepath.Mainmes2){$textMainmes2.text = $tempjsonfilepath.Mainmes2}

    $buttonmailsetting.Add_Click({
    # json�ɒǋL
    $tempjsonfilepath = Get-Content "$PSScriptRoot\setting.json" -raw | ConvertFrom-Json
    If($Null -eq $tempjsonfilepath.ToMail){$tempjsonfilepath | Add-Member -MemberType NoteProperty -Name 'ToMail' -Value $ToMail -Force}else{$tempjsonfilepath.ToMail = $textToMail.text}
    If($Null -eq $tempjsonfilepath.Subject){$tempjsonfilepath | Add-Member -MemberType NoteProperty -Name 'Subject' -Value $Subject -Force}else{$tempjsonfilepath.Subject = $textSubject.text}
    If($Null -eq $tempjsonfilepath.FromMail){$tempjsonfilepath | Add-Member -MemberType NoteProperty -Name 'FromMail' -Value $FromMail -Force}else{$tempjsonfilepath.FromMail = $textFromMail.text}
    If($Null -eq $tempjsonfilepath.Password){$tempjsonfilepath | Add-Member -MemberType NoteProperty -Name 'Password' -Value $textPassword.Password -Force}else{$tempjsonfilepath.Password = $textPassword.Password}
    If($Null -eq $tempjsonfilepath.SmtpServer){$tempjsonfilepath | Add-Member -MemberType NoteProperty -Name 'SmtpServer' -Value $SmtpServer -Force}else{$tempjsonfilepath.SmtpServer = $textSmtpServer.text}
    If($Null -eq $tempjsonfilepath.Port){$tempjsonfilepath | Add-Member -MemberType NoteProperty -Name 'Port' -Value $Port -Force}else{$tempjsonfilepath.Port = $textPort.text}
    If($Null -eq $tempjsonfilepath.Mainmes1){$tempjsonfilepath | Add-Member -MemberType NoteProperty -Name 'Mainmes1' -Value $Mainmes1 -Force}else{$tempjsonfilepath.Mainmes1 = $textMainmes1.text}
    If($Null -eq $tempjsonfilepath.Mainmes2){$tempjsonfilepath | Add-Member -MemberType NoteProperty -Name 'Mainmes2' -Value $Mainmes2 -Force}else{$tempjsonfilepath.Mainmes2 = $textMainmes2.text}
    ConvertTo-Json $tempjsonfilepath | set-content "$PSScriptRoot\setting.json"
    })
    $MailSettingfrm.ShowDialog()
}

<#
function sendmail{
    powershell -ExecutionPolicy Bypass -command "$PSScriptRoot\SendMail.ps1"
}
#>

# DB�t�@�C���쐬
# �N�P�ʂŕ�����
$NowYear = (Get-Date -Format "yyyy")
$DBPath = "$PSScriptRoot\DB_$NowYear.csv"
If(Test-Path $DBPath){}else{
    "ID" + "," + "Date" + "," + "Youbi" + "," + "jikan" + "," + "Basho" + "," + "Riyu" + "," + "Output" | Add-Content $DBPath -Encoding Default
}
# ListView��ɕ\�����閼�O�̏����ݒ�
$DBPathView = $DBPath.Substring($DBPath.Length -8, 4)
$NowDBName.text = $DBPathView + "�N�Αӏ��"

#ID�����ݒ�
$textselectID.text = "(�Ǘ��pID)"

# �G�N�X�|�[�g�t�@�C���ݒ�
# ����]�p�o���Ȃ���Δp�~�\��
If(Test-Path "$PSScriptRoot\setting.json"){
    $filepath = Get-Content "$PSScriptRoot\setting.json" -raw | ConvertFrom-Json
    If($Null -ne $filepath.ExportFilePath){
        $textsansyo.text = $filepath.ExportFilePath
    }
}

function delID {
        #$wsobj = new-object -comobject wscript.shell
        #$result = $wsobj.popup("�f�o�b�O�p")
        # �t���O��1�Ȃ�ʓr�ǂݍ���DB�ɂ���
        If($global:DBFlag -eq 1){
            $DBPath = $textsansyo.text
        }
        If($textselectID.text -eq ""){return}
        If($Null -eq $textselectID.text){return}
        $data = Get-Content $DBPath
        $DelID = $textselectID.text
        If(-not($null -eq $DelID)){
            $countdata = Import-CSV $DBPath -Encoding Default
            $delcount = Select-String $DelID $DBPath | ForEach-Object { $($_ -split":")[2]}
            $delcount = $delcount - 1
            $data[$delcount] = $null
            $data | Out-File $DBPath

            # ���X�g�X�V
            $View = Import-Csv $DBPath -Encoding Default
            $listitems = @()
            for ($i = 1; $i -lt 2; $i += 1) {
                $item = {} | Select ID,Date,Youbi,Jikan,Basho,Riyu
                $item = $View
                $listitems += $item
            }
            $listView.ItemsSource = @($listitems)
        }
}

function editmode {
    # ID������Ύ��s���Ȃ�
    If("" -eq $textselectID.text){return}
    If($Null -eq $textselectID.text){return}
    # �t���O��1�Ȃ�ʓr�ǂݍ���DB�ɂ���
    If($global:DBFlag -eq 1){
        $DBPath = $textsansyo.text
    }
    # CSV�ǂݍ���
    $editdata = Import-csv $DBPath -Encoding Default
    $editdata | Where-Object { $_.ID -eq $textselectID.text } | Where-Object { $_.Date = $texteditDate.text }
    $editdata | Where-Object { $_.ID -eq $textselectID.text } | Where-Object { $_.Youbi = $texteditYoubi.text }
    $editdata | Where-Object { $_.ID -eq $textselectID.text } | Where-Object { $_.jikan = $texteditJikan.text }
    $editdata | Where-Object { $_.ID -eq $textselectID.text } | Where-Object { $_.Basho = $texteditGenba.text }
    $editdata | Where-Object { $_.ID -eq $textselectID.text } | Where-Object { $_.Riyu = $texteditRiyu.text }
    $editdata | Where-Object { $_.ID -eq $textselectID.text } | Where-Object { 
        $_.Output = $texteditDate.text + "(" + $texteditYoubi.text + ") " + $texteditJikan.text + " " + $texteditGenba.text + " " + $texteditRiyu.text
     }
    $editdata | Export-csv $DBPath -Encoding Default
    # ���X�g�r���[�ǂݍ���
    $listView = $frm.FindName("listview")
    $View = Import-Csv $DBPath -Encoding Default
    $listitems = @()
    for ($i = 1; $i -lt 2; $i += 1) {
        $item = {} | Select ID,Date,Youbi,Jikan,Basho,Riyu
        $item = $View
        $listitems += $item
    }
    $listView.ItemsSource = @($listitems)
}

# �]�p�ł��Ȃ���Δp�~�\��
# �ߋ�DB�t�@�C���ǂݍ��݂ɓ]�p
function sansyo {
    #$wsobj = new-object -comobject wscript.shell
    #$result = $wsobj.popup("�f�o�b�O�p")
    [void][System.Reflection.Assembly]::Load("System.Windows.Forms, Version=2.0.0.0, Culture=Neutral, PublicKeyToken=b77a5c561934e089")
    $dialog = New-Object System.Windows.Forms.OpenFileDialog
    $dialog.Title = "�t�@�C���I��"
    $dialog.Filter = "DB�t�@�C�� (*.csv)|*.csv"
    if($dialog.ShowDialog() -eq $true){
        $textsansyo.text = $dialog.FileName
    }
    # json�ǂݍ���&��������
    If(-not(Test-Path "$PSScriptRoot\setting.json")){
        $json = @{ExportFilePath=$textsansyo.text}
        ConvertTo-Json $json | Out-File "$PSScriptRoot\setting.json" -Encoding utf8 -Append
    }else{
        $tempjsonfilepath = Get-Content "$PSScriptRoot\setting.json" -raw | ConvertFrom-Json
        If($Null -eq $tempjsonfilepath.ExportFilePath){
            $tempjsonfilepath | Add-Member -MemberType NoteProperty -Name 'ExportFilePath' -Value $textsansyo.text
        }else{
            $tempjsonfilepath.ExportFilePath = $textsansyo.text
        }
        ConvertTo-Json $tempjsonfilepath | set-content "$PSScriptRoot\setting.json"
    }
}

# ���X�g�I��������
# �P��I�����̋����B�s�C�����Ɏg�p
function SelectID($selection1) {
    $selection1.add_SelectionChanged({
        $textselectID.text = ($listView.SelectedItem).ID
        $texteditDate.text = ($listView.SelectedItem).Date
        $texteditYoubi.text = ($listView.SelectedItem).Youbi
        $texteditJikan.text = ($listView.SelectedItem).jikan
        $texteditGenba.text = ($listView.SelectedItem).Basho
        $texteditRiyu.text = ($listView.SelectedItem).Riyu
    })
}

# �����I�����̓���
function MultiSelect($selection1) {
    $selection1.add_SelectionChanged({
        $tempjsonfilepath = Get-Content "$PSScriptRoot\setting.json" -raw | ConvertFrom-Json
        $ToMail.text = $tempjsonfilepath.ToMail
        $Subject.text = $tempjsonfilepath.Subject
        $FromMail.text = $tempjsonfilepath.FromMail

        # ��U�N���b�v�{�[�h�ɏ������݃N���A
        Set-Clipboard -Value $Null
        # 1�s�Âǂݍ���ŕϐ��ɓ����
        for($i = 0; $i -lt $listView.SelectedItems.Count; $i++){
            $DateClip_Date = ($listView.SelectedItems[$i]).Date
            $DateClip_Youbi = ($listView.SelectedItems[$i]).Youbi
            $DateClip_jikan = ($listView.SelectedItems[$i]).jikan
            $DateClip_Basho = ($listView.SelectedItems[$i]).Basho
            $DateClip_Riyu = ($listView.SelectedItems[$i]).Riyu
            $OutputDateClip = $DateClip_Date + "(" + $DateClip_Youbi + ") " + $DateClip_Jikan + " " + $DateClip_Basho + " " + $DateClip_Riyu
            # �܂Ƃ߂����̂���������
            Set-Clipboard -Append ("$OutputDateClip")
        }
        # ���[���{���ɂ��I���Ɠ����Ɏ������͂���
        $SelectDate = (Get-Clipboard -Format text)
        $str = $SelectDate -join "`r`n"
        $tempreport = ("`r`n`r`n" + $str + "`r`n`r`n")
        $MailMain.text = ($tempjsonfilepath.Mainmes1 + $tempreport + $tempjsonfilepath.Mainmes2)
    })
}

SelectID $listView
MultiSelect $listView

# �N��1���ڂ̃��X�g�ǂݍ���
$View = Import-Csv $DBPath -Encoding Default
$listitems = @()
for ($i = 1; $i -lt 2; $i += 1) {
    $item = {} | Select ID,Date,Youbi,Jikan,Basho,Riyu
    $item = $View
    $listitems += $item
}
$listView.ItemsSource = @($listitems)

function regist {
    # �t���O��1�Ȃ�ʓr�ǂݍ���DB�ɂ���
    If($global:DBFlag -eq 1){
        $DBPath = $textsansyo.text
    }
    $StartCal = $frm.FindName("Cal")
    $Cal = $StartCal.SelectedDate

    if($null -eq $Cal)
        {$Cal = Get-Date}
    $Calender = $Cal.ToString()
    $Calyoubi = $Cal.ToString()
    $Calender = $Calender.Substring(5, 6)
    $Calyoubi = $Calender.Substring(0, 6)
    $youbi = (Get-Date $Calyoubi).DayOfWeek
    switch ($youbi) {
        Sunday {$youbi = "��"}
        Monday {$youbi = "��"}
        Tuesday {$youbi = "��"}
        Wednesday {$youbi = "��"}
        Thursday {$youbi = "��"}
        Friday {$youbi = "��"}
        Saturday {$youbi = "�y"}
        default {"Not matched."}
    }

    $Kaishi = $textKaishi.Text
    $Owari = $textOwari.Text
    $Genba = $textGenba.Text
    $Riyu = $textRiyu.Text

    If(-not(Test-Path "$PSScriptRoot\setting_ID.json")){
        [String]$DBIDCount = (Get-Content $DBPath | Measure-Object -Line).Lines
        $DBLast = [int]$DBIDCount
        $DBLasttemp = $DBLast
        $DBLasttemp = "{0:D5}" -f $DBLasttemp
        "ID_" + $DBLastTemp + "," + $Calender + "," + $youbi + "," + $Kaishi + "�`" + $Owari  + "," + $Genba + "," + $Riyu + "," + `
        $Calender + "(" + $youbi + ")" + " " + $Kaishi + "�`" + $Owari  + " " + $Genba + " " + $Riyu `
        | Add-Content $DBPath -Encoding Default

        $Null = $listView.ItemsSource
        # ���X�g�r���[�X�V
        $listView = $frm.FindName("listview")
        $View = Import-Csv $DBPath -Encoding Default
        $listitems = @()
        for ($i = 1; $i -lt 2; $i += 1) {
            $item = {} | Select ID,Date,Youbi,Jikan,Basho,Riyu
            $item = $View
            $listitems += $item
        }
        $listView.ItemsSource = @($listitems)

        $DBLast = $DBLast + 1
        $json = @{ID=$DBLast}
        ConvertTo-Json $json | Out-File "$PSScriptRoot\setting_ID.json" -Encoding utf8 -Append
    }else{
        $tempjson = Get-Content "$PSScriptRoot\setting_ID.json" -raw | ConvertFrom-Json
        $IDtemp = $tempjson.ID
        $IDintemp = "{0:D5}" -f $IDtemp
        [String]$IDin = $IDintemp

        "ID_" + $IDin + "," + $Calender + "," + $youbi + "," + $Kaishi + "�`" + $Owari  + "," + $Genba + "," + $Riyu + "," + `
        $Calender + "(" + $youbi + ")" + " " + $Kaishi + "�`" + $Owari  + " " + $Genba + " " + $Riyu `
        | Add-Content $DBPath -Encoding Default

        $Null = $listView.ItemsSource
        # ���X�g�r���[�X�V
        $listView = $frm.FindName("listview")
        $View = Import-Csv $DBPath -Encoding Default
        $listitems = @()
        for ($i = 1; $i -lt 2; $i += 1) {
            $item = {} | Select ID,Date,Youbi,Jikan,Basho,Riyu
            $item = $View
            $listitems += $item
        }
        $listView.ItemsSource = @($listitems)

        $tempjson.ID = $tempjson.ID + 1
        ConvertTo-Json $tempjson | set-content "$PSScriptRoot\setting_ID.json"
    }
}

$buttonRegist =  $frm.FindName("buttonRegist")
$buttondel =  $frm.FindName("buttondel")
$buttonedit =  $frm.FindName("buttonedit")
$buttonsansyo =  $frm.FindName("buttonsansyo")
$buttonexp =  $frm.FindName("buttonexp")
$buttonmailsetting = $frm.FindName("mailsetting")
$buttonsendmail = $frm.FindName("sendmail")
$buttonRegist.Add_Click({regist})
$buttondel.Add_Click({delID})
$buttonedit.Add_Click({editmode})
$buttonsansyo.Add_Click({sansyo})
$buttonexp.Add_Click({OldDB})
$buttonmailsetting.Add_Click({mailsetting})
$buttonsendmail.Add_Click({sendmail})

$frm.ShowDialog()