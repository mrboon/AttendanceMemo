[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')  				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('presentationframework') 				| out-null
[System.Reflection.Assembly]::LoadWithPartialName('PresentationCore')      				| out-null
[Reflection.Assembly]::LoadFrom("$PSScriptRoot\assembly\MahApps.Metro.dll")      | out-null
[Reflection.Assembly]::LoadFrom("$PSScriptRoot\assembly\System.Windows.Interactivity.dll")      | out-null
[System.Windows.Forms.Application]::EnableVisualStyles()

Set-PSDebug -Strict
Add-Type -AssemblyName PresentationFramework, System.Windows.Forms

# �萔��`
# �T�[�r�X���g�p���Ȃ����߃C���^�[�o�����g�p���ď펞���s������
# 3600�b(1����)���ɓ����I�Ɏ��s������(������s���鏈���̏ꍇ�͂����ɃR�[�h����)
$TIMER_INTERVAL = 10 * 360000
$MUTEX_NAME = "Global\mutex" # ���d�N���`�F�b�N�p

function LoadXml ($global:filename)
{
    $XamlLoader=(New-Object System.Xml.XmlDocument)
    $XamlLoader.Load($filename)
    return $XamlLoader
}

$XamlMainWindow=LoadXml("$PSScriptRoot\Mainmenu_fast.xaml")
$Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
$frm=[Windows.Markup.XamlReader]::Load($Reader)

$textKaishi = $frm.FindName("textKaishi")
$textOwari = $frm.FindName("textOwari")
$textGenba = $frm.FindName("textGenba")
$textRiyu = $frm.FindName("textRiyu")

# �둀��h�~�̃{�^�����b�N�p�X�C�b�`
# �����l
$frm.DataContext = [PSCustomObject]@{
    Switch = "False"
}
Function item_add_Click($item) {
    $XamlMainWindow=LoadXml("$PSScriptRoot\Mainmenu_fast.xaml")
    $Reader=(New-Object System.Xml.XmlNodeReader $XamlMainWindow)
    $frm=[Windows.Markup.XamlReader]::Load($Reader)
    $item.add_Click({
        if (-not $this.isChecked) {
            $frm.DataContext = [PSCustomObject]@{
                Switch = "False"
            }
        }
        if ($this.isChecked) {
            $frm.DataContext = [PSCustomObject]@{
                Switch = "True"
            }
        }
    })
}
$rock = $frm.FindName("rock")
item_add_Click $rock

# DB�t�@�C���쐬
# �N�P�ʂŕ�����
$NowYear = (Get-Date -Format "yyyy")
$DBPath = "$PSScriptRoot\DB_$NowYear.csv"
If(Test-Path $DBPath){}else{
    "ID" + "," + "Date" + "," + "Youbi" + "," + "jikan" + "," + "Basho" + "," + "Riyu" + "," + "Output" | Add-Content $DBPath -Encoding Default
}

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
$buttonRegist.Add_Click({regist})

# ���݂̉�ʃT�C�X�擾
# �Q�l�Fhttps://www.it-swarm-ja.com/ja/windows/%E3%82%B3%E3%83%9E%E3%83%B3%E3%83%89%E3%83%A9%E3%82%A4%E3%83%B3%E3%81%8B%E3%82%89windows%E3%81%AE%E7%8F%BE%E5%9C%A8%E3%81%AE%E7%94%BB%E9%9D%A2%E8%A7%A3%E5%83%8F%E5%BA%A6%E3%82%92%E5%8F%96%E5%BE%97%E3%81%99%E3%82%8B%E3%81%AB%E3%81%AF%E3%81%A9%E3%81%86%E3%81%99%E3%82%8C%E3%81%B0%E3%82%88%E3%81%84%E3%81%A7%E3%81%99%E3%81%8B%EF%BC%9F/944630273/
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class PInvoke {
    [DllImport("user32.dll")] public static extern IntPtr GetDC(IntPtr hwnd);
    [DllImport("gdi32.dll")] public static extern int GetDeviceCaps(IntPtr hdc, int nIndex);
}
"@
$hdc = [PInvoke]::GetDC([IntPtr]::Zero)
$width = [PInvoke]::GetDeviceCaps($hdc, 118) # width
$height = [PInvoke]::GetDeviceCaps($hdc, 117) # height

# ��ʂ̉E���ɕ\������(�^���|�b�v�A�b�v�I�ɂ���)
$frm.Left = $width - $frm.Width - 10
$frm.top = $height - $frm.height - 50
$frm.ShowDialog()