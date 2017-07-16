# ToRubberDucky
# Convert a files to Rubber Ducky USB
# Martial Puygrenier - @mpgn_x64 - July 2016

Write-Host @"
  _____ ____  ____             _          
 |_   _|  _ \|  _ \ _   _  ___| | ___   _ 
   | | | |_) | | | | | | |/ __| |/ / | | |
   | | |  _ <| |_| | |_| | (__|   <| |_| |
   |_| |_| \_\____/ \__,_|\___|_|\_\\__, |
                                    |___/  
                                                                            
"@ -foregroundcolor "yellow"
Write-Host "   @mpgn_x64 - July 2016"
Write-Host @"

To-Rubber-Ducky USB's script encode the file of your choice in base64 and generate payload ready to be 
compiled with the Rubber Ducky Encoder.The file "payload" will be compiled as inject.bin. Copy past this 
file into your Rubber Ducky USB. Save the result on the target machine as .html an open it with Internet Explorer. 
Save the file with the extension of the original file. You have transfered your file !

"@


# get the file and check the path
Do {
    $file = Read-Host '[+] Select the path of the file you want to send to the Rubber Ducky:'
    if (-Not $file) {
        $file = "THISfileisnotfind"
    }
} while( -Not (Test-Path $file))

$size = (Get-Item $file).length

Write-Host "[+] Encoding the file..."
$ContentB = Get-Content -Path $file -Encoding Byte
Write-Host "[+] Converting the file in base64..."
$Base64 = [System.Convert]::ToBase64String($ContentB)
  
$LengthB64 = $Base64.Length
$modb64 = $LengthB64 % 100

Write-Host "[+] Generating the payload file..."
 
$data64 = "";
$rows = @()
for ($i=0; $i -lt [Math]::Floor([decimal]($LengthB64/100)); $i++ ) {
    $data64 = $data64 + "`n"
    $data64 = $data64 + "ENTER"
    $data64 = $data64 + "`n"
    $data64 = $data64 + "STRING inject.push('"
    $data64 = $data64 + $Base64.Substring($i*100,100)
    $data64 = $data64 + "');"
    
    $progress = "#" * $((($i * 100) / $LengthB64) * 100)
    Write-Host -NoNewline "[" $progress "]`r" -foregroundcolor "yellow"
}
if($modb64 -ne 0) {
    $data64 = $data64 + "`n"
    $data64 = $data64 + "ENTER"
    $data64 = $data64 + "`n"
    $data64 = $data64 + "STRING inject.push('"
    $data64 = $data64 + $Base64.Substring($LengthB64-$modb64,$modb64)
    $data64 = $data64 + "');" 
}

Write-Host "`n"

$content = @"
DELAY 2000
ENTER
STRING <!DOCTYPE html>
ENTER
STRING <html><head><title>Download Binary file with IE</title></head>
ENTER
STRING <body><script type="text/javascript">
ENTER
STRING function b64toBlob(r,e,n){e=e||"",n=n||512;for(var t=atob(r),a=[],o=0;o<t.length;o+=n){for(var l=t.slice(o,o+n),h=new Array(l.length),b=0;b<l.length;b++)h[b]=l.charCodeAt(b);var v=new Uint8Array(h);a.push(v)}var c=new Blob(a,{type:e});return c}
ENTER
STRING  var inject = []; var contentType = 'application/octet-stream'; $($data64)
ENTER 
STRING var v = 1; for (var i = 0; i < inject.length - 1; i++) {
ENTER
STRING if (inject[i].length != 100) { v = 0;
ENTER
STRING document.body.innerHTML = document.body.innerHTML + '<p>Error at line : ' + (i + 1 + 5) + ' ' + inject[i] + ' string length : ' + inject[i].length + '/100 <br>' + (100 - inject[i].length) + ' char missing, check with the file valid.txt from the physical PC, change the line and reload the page' + '</p>' } }
ENTER
STRING if (v) navigator.msSaveBlob(b64toBlob(inject.join(''), contentType), 'file');</script></body></html>
ENTER
STRING </script></body></html>
"@

$path = Get-Location
[System.IO.File]::WriteAllLines("$($path)\payload", $content)

Write-Host "The payload file is save into the same folder"
Do {
    $lang = Read-Host '[+] Select the language of the keyboard target us/uk/fr/pt (if the target is on a remote PC, select the same language as the remote pc) :'
} while( $lang.length -eq 0 )

java -jar .\encoder.jar -l $lang  -i .\payload -o inject.bin

Write-Host "[+] Check if the compilation is OK"
Write-Host "[+] Copy the file inject.bin to the Rubber Ducky USB !!!"
