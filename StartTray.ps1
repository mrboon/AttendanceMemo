Add-Type -AssemblyName PresentationFramework, System.Windows.Forms

# 定数定義
# サービスを使用しないためインターバルを使用して常時実行させる
# 3600秒(1時間)毎に内部的に実行させる(定期実行する処理の場合はそこにコード書く)
$TIMER_INTERVAL = 10 * 360000
$MUTEX_NAME = "Global\mutex" # 多重起動チェック用
function main($frm){
    $mutex = New-Object System.Threading.Mutex($false, $MUTEX_NAME)
    # 多重起動チェック
    if ($mutex.WaitOne(0, $false)){
      # タスクバー非表示
      $windowcode = '[DllImport("user32.dll")] public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);'
      $asyncwindow = Add-Type -MemberDefinition $windowcode -name Win32ShowWindowAsync -namespace Win32Functions -PassThru
      $null = $asyncwindow::ShowWindowAsync((Get-Process -PID $pid).MainWindowHandle, 0)
  
      $application_context = New-Object System.Windows.Forms.ApplicationContext
      $timer = New-Object Windows.Forms.Timer
      $path = Get-Process -id $pid | Select-Object -ExpandProperty Path # icon用
  
      # タスクトレイアイコン
      $notify_icon = New-Object System.Windows.Forms.NotifyIcon
      $icon = "$PSScriptRoot\icon48.ico"

      # アイコン無い時は下で代用
      #$icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
      $notify_icon.Icon = $icon
      $notify_icon.Visible = $true
  
      # アイコンクリック時のイベント
      $notify_icon.add_Click({
        if ($_.Button -eq [Windows.Forms.MouseButtons]::Left) {
            powershell -ExecutionPolicy Bypass -command "$PSScriptRoot\kintaimemo.ps1"
          # タイマーで実装されているイベントを即時実行する場合
          #$timer.Stop()
          #$timer.Interval = 1
          #$timer.Start()
        }
      })
  
      # メニュー
      $menu_item_easymenu = New-Object System.Windows.Forms.MenuItem
      $menu_item_easymenu.Text = "簡易登録画面起動"
      $menu_item_menu = New-Object System.Windows.Forms.MenuItem
      $menu_item_menu.Text = "勤怠メモ起動"
      $menu_item_exit = New-Object System.Windows.Forms.MenuItem
      $menu_item_exit.Text = "勤怠メモの終了"
      $notify_icon.ContextMenu = New-Object System.Windows.Forms.ContextMenu
      $notify_icon.contextMenu.MenuItems.AddRange($menu_item_easymenu)
      $notify_icon.contextMenu.MenuItems.AddRange($menu_item_menu)
      $notify_icon.contextMenu.MenuItems.AddRange($menu_item_exit)
  
      # メニュークリック時のイベント
      $menu_item_easymenu.add_Click({
        powershell -ExecutionPolicy Bypass -command "$PSScriptRoot\kintaimemo_fast.ps1"
      })
      $menu_item_menu.add_Click({
        powershell -ExecutionPolicy Bypass -command "$PSScriptRoot\kintaimemo.ps1"
      })
      $menu_item_exit.add_Click({
        $application_context.ExitThread()
      })
      
      # タイマーイベント.
      $timer.Enabled = $true
      $timer.Add_Tick({
        $timer.Stop()
  
        # 定期実行処理を入れたい場合ここに記載する
  
      # インターバルを再設定してタイマー再開
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