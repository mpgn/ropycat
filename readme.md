## Ropycat

Sample scripts to copy/paste a file into a Citrix XenApp or Citrix XenDesktop when copy/paste option is not allowed !

![demo](https://user-images.githubusercontent.com/5891788/69732073-452c0480-112b-11ea-9ad5-d3b80aeca2a8.gif)

1. **TRDucky**

To-Rubber-Ducky USB's script encode the file of your choice in base64 and generate payload ready to be compiled with the Rubber Ducky Encoder.The file "payload" will be compiled as inject.bin. Copy past this file into your Rubber Ducky USB. Save the result on the target machine as .html an open it with Internet Explorer. Save the file with the extension of the original file. You have transfered your file !

2. **KeyBS**

If you don't have USB port available; use KeyBS (powershell or C#).
Use the KeyBS C# script preferably since `SendInput` in C# is more reliable than `SendKeys` in powershell.

- Powershell: ~30 b/secondes
- C#: ~100 b/secondes

#### Issues:

- char `%` `^` can be replaced by `5` `6` if mulitple keyboards are defined
- Powershell version is very slow, use it as last resort 
- Don't forget to add WindowsInput library via Nuget for the C# project

![capture d'écran](https://user-images.githubusercontent.com/5891788/69730527-88d13f00-1128-11ea-8385-a8de1600d12c.png)

### License 

MIT License
