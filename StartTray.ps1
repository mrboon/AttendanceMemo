Add-Type -AssemblyName PresentationFramework, System.Windows.Forms

# �萔��`
# �T�[�r�X���g�p���Ȃ����߃C���^�[�o�����g�p���ď펞���s������
# 3600�b(1����)���ɓ����I�Ɏ��s������(������s���鏈���̏ꍇ�͂����ɃR�[�h����)
$TIMER_INTERVAL = 10 * 360000
$MUTEX_NAME = "Global\mutex" # ���d�N���`�F�b�N�p
function main($frm){
    $mutex = New-Object System.Threading.Mutex($false, $MUTEX_NAME)
    # ���d�N���`�F�b�N
    if ($mutex.WaitOne(0, $false)){
      # �^�X�N�o�[��\��
      $windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
      $asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru
      $null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)
  
      $application_context = New-Object System.Windows.Forms.ApplicationContext
      $timer = New-Object Windows.Forms.Timer
      $path = Get-Process -id $pid | Select-Object -ExpandProperty Path # icon�p
  
      # �^�X�N�g���C�A�C�R��
      $notify_icon = New-Object System.Windows.Forms.NotifyIcon
      $icon = "$PSScriptRoot\icon48.ico"

      # �A�C�R���������͉��ő�p
      #$icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
      $notify_icon.Icon = $icon
      $notify_icon.Visible = $true
  
      # �A�C�R���N���b�N���̃C�x���g
      $notify_icon.add_Click({
        if ($_.Button -eq [Windows.Forms.MouseButtons]::Left) {
            powershell -ExecutionPolicy Bypass -command "$PSScriptRoot\kintaimemo.ps1"
          # �^�C�}�[�Ŏ�������Ă���C�x���g�𑦎����s����ꍇ
          #$timer.Stop()
          #$timer.Interval = 1
          #$timer.Start()
        }
      })
  
      # ���j���[
      $menu_item_easymenu = New-Object System.Windows.Forms.MenuItem
      $menu_item_easymenu.Text = "�ȈՓo�^��ʋN��"
      $menu_item_menu = New-Object System.Windows.Forms.MenuItem
      $menu_item_menu.Text = "�ΑӃ����N��"
      $menu_item_exit = New-Object System.Windows.Forms.MenuItem
      $menu_item_exit.Text = "�ΑӃ����̏I��"
      $notify_icon.ContextMenu = New-Object System.Windows.Forms.ContextMenu
      $notify_icon.contextMenu.MenuItems.AddRange($menu_item_easymenu)
      $notify_icon.contextMenu.MenuItems.AddRange($menu_item_menu)
      $notify_icon.contextMenu.MenuItems.AddRange($menu_item_exit)
  
      # ���j���[�N���b�N���̃C�x���g
      $menu_item_easymenu.add_Click({
        powershell -ExecutionPolicy Bypass -command "$PSScriptRoot\kintaimemo_fast.ps1"
      })
      $menu_item_menu.add_Click({
        powershell -ExecutionPolicy Bypass -command "$PSScriptRoot\kintaimemo.ps1"
      })
      $menu_item_exit.add_Click({
        $application_context.ExitThread()
      })
      
      # �^�C�}�[�C�x���g.
      $timer.Enabled = $true
      $timer.Add_Tick({
        $timer.Stop()
  
        # ������s��������ꂽ���ꍇ�����ɋL�ڂ���
  
      # �C���^�[�o�����Đݒ肵�ă^�C�}�[�ĊJ
        $timer.Interval = $TIMER_INTERVAL
        $timer.Start()
      })
  
      $timer.Interval = 1
      $timer.Start()
  
      [void][System.Windows.Forms.Application]::Run($application_context)
  
      $timer.Stop()
      $notify_icon.Visible = $false
      $mutex.ReleaseMutex()
    }
    $mutex.Close()
  }
  
main $frm