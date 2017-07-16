
# KeyBS : Keybord Simulator
# Martial Puygrenier
# Bypass Citrix XenDesktop or XenApp Clipboard limitation
# July 2016 @mpgn_x64

Write-Host " "
Write-Host " 
  _  __          ____   _____ 
 | |/ /         |  _ \ / ____|
 | ' / ___ _   _| |_) | (___  
 |  < / _ \ | | |  _ < \___ \ 
 | . \  __/ |_| | |_) |____) |
 |_|\_\___|\__, |____/|_____/ 
            __/ |             
           |___/              
                                                                                                                    
"
Write-Host "Keyboard Simulator allow you to import files content from your physical PC to a remote PC.
Use this program if the copy/past is disallowed by the policy system but you need to import data.
There is no limitation on the file you want to export."
Write-Host -NoNewLine 'Press any key to continue...';
$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
Write-Host ""
Write-Host ""

# get the file and check the path
Do {
    $file = Read-Host 'Select absolute path of the file you want to copy:'
    if (-Not $file) {
        $file = "THISfileisnotfind"
    }
} while( -Not (Test-Path $file))

$size = (Get-Item $file).length

# is binary ?
$message  = 'If the file is a binary I cannot directly send him through the keyboard.
I will encode it in base64 for you inside a html file. Once the file is copied on the remote machine, 
save it and open it with IE who ask you to save the file (decoded in b64). Then save it with the extension you want.'
$question = 'The file is a binary ?'

$choices = New-Object Collections.ObjectModel.Collection[Management.Automation.Host.ChoiceDescription]
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&Yes'))
$choices.Add((New-Object Management.Automation.Host.ChoiceDescription -ArgumentList '&No'))

$decision = $Host.UI.PromptForChoice($message, $question, $choices, 1)
if ($decision -eq 0) {
  Write-Host 'confirmed'

  $ContentB = Get-Content -Path $file -Encoding Byte
  $Base64 = [System.Convert]::ToBase64String($ContentB)
 
  $data64 = "";
  $rows = @()
  foreach ($row in ($Base64 -split "(\w{500})")) {
    if ( $row ) {
        $data64 = $data64 + "`n"
        $data64 = $data64 + "inject.push('"
        $data64 = $data64 + $row
        $data64 = $data64 + "');"
    }
  }

  $content = @"
<!DOCTYPE html>
<html>
<head>
  <title>Download Binary file with IE</title>
</head>
<body>
<script type="text/javascript">
function b64toBlob(r,e,n){e=e||"",n=n||512;for(var t=atob(r),a=[],o=0;o<t.length;o+=n){for(var l=t.slice(o,o+n),h=new Array(l.length),b=0;b<l.length;b++)h[b]=l.charCodeAt(b);var v=new Uint8Array(h);a.push(v)}var c=new Blob(a,{type:e});return c}

  var inject = [];
  var contentType = 'application/octet-stream';
  $($data64)

  var blob = b64toBlob(inject.join(''), contentType);
  navigator.msSaveBlob(blob, "file");
</script>
</body>
</html>
"@

} else {
    $content = (Get-Content $file) -join "`n"
}

# get the process
Get-Process |where {$_.mainWindowTItle} |format-table id,name,mainwindowtitle –AutoSize
$name = Read-Host 'Select the app MainWindowTitle or press ENTER to reload:'
while( -Not $name ) {
    Get-Process |where {$_.mainWindowTItle} |format-table id,name,mainwindowtitle –AutoSize
    $name = Read-Host 'Select the app MainWindowTitle :'
}
Write-Host " "
Write-Host "DO NOT TOUCH THE KEYBOARD OR THE MOUSE !!!" -foregroundcolor red
Write-Host " "
$wshell = New-Object -ComObject wscript.shell;
$app = $wshell.AppActivate($name)

$cleanContent = $content -replace '([+^%~(){}])', '{$1}'
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.SendKeys]::SendWait($cleanContent);