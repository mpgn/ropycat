### Ropycat

Sample script to copy/paste a file into a Citrix XenApp or Citrix XenDesktop when copy/paste option is not allowed.

1. TRDucky

To-Rubber-Ducky USB's script encode the file of your choice in base64 and generate payload ready to be compiled with the Rubber Ducky Encoder.The file "payload" will be compiled as inject.bin. Copy past this file into your Rubber Ducky USB. Save the result on the target machine as .html an open it with Internet Explorer. Save the file with the extension of the original file. You have transfered your file !

2. KeyBS

If you don't have USB port available; use KeyBS (powershell or C#).
Use the KeyBS C# script preferably since `SendInput` in C# is more reliable than `SendKeys` in powershell.

Performance: 100octets/secondes

### License 

MIT License
