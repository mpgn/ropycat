using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;
using WindowsInput;

namespace KeyBS
{
    class Program
    {
        public static void intro()
        {

            Console.Write(@"
  _  __          ____   _____ 
 | |/ /         |  _ \ / ____|
 | ' / ___ _   _| |_) | (___  
 |  < / _ \ | | |  _ < \___ \ 
 | . \  __/ |_| | |_) |____) |
 |_|\_\___|\__, |____/|_____/ 
            __/ |             
           |___/              
By @mpgn_x64               
");
            Console.WriteLine("KeyB Simulator - @mpgn_x64 - July 2016\n");
            Console.WriteLine(@"Keyboard Simulator allow you to import files content from your physical PC to a remote PC.
Use this program if the copy / past is disallowed by the policy system but you need to import data.
There is no limitation on the file you want to export.");
            Console.Write("Press any key to continue...\n");
            Console.ReadLine();
        }

        public static void sendSample(string data, int sleep)
        {
            for (var j = 0; j < data.Length; j++)
            {
                System.Threading.Thread.Sleep(5);
                InputSimulator s = new InputSimulator();
                s.Keyboard.TextEntry(data[j].ToString());

            }
            File.AppendAllText("valid.txt", data);
            System.Threading.Thread.Sleep(sleep);
        }

        public static string Base64Encode(string plainText)
        {
            var plainTextBytes = System.Text.Encoding.UTF8.GetBytes(plainText);
            return System.Convert.ToBase64String(plainTextBytes);
        }
        public static string[] SplitByLength(string inputString, int segmentSize)
        {
            List<string> segments = new List<string>();

            int wholeSegmentCount = inputString.Length / segmentSize;

            int i;
            for (i = 0; i < wholeSegmentCount; i++)
            {
                segments.Add(inputString.Substring(i * segmentSize, segmentSize));
            }

            if (inputString.Length % segmentSize != 0)
            {
                segments.Add(inputString.Substring(i * segmentSize, inputString.Length - i * segmentSize));
            }

            return segments.ToArray();
        }

        static void Main(string[] args)
        {
            Program.intro();

            File.WriteAllText("valid.txt", "");

            Console.WriteLine("[+] Select the path of the file you want to copy: ");
            string file = Console.ReadLine();
            while (!File.Exists(file))
            {
                Console.WriteLine("[+] Wrong path... Select absolute path of the file you want to copy: ");
                file = Console.ReadLine();
            }

            string idProc = "";
            do
            {
                Process[] processlist = Process.GetProcesses();
                foreach (Process process in processlist)
                {
                    if (!String.IsNullOrEmpty(process.MainWindowTitle))
                    {
                        Console.WriteLine("\t ID: {0} Window title: {1}", process.Id, process.MainWindowTitle);
                    }
                }
                Console.Write("[+] Select the the process ID of the application you want to send your data or tape R to reload: ");
                idProc = Console.ReadLine();
            } while ((idProc.ToUpper().Equals("R") || idProc.ToLower().Equals("r")));

            Console.WriteLine(@"[+] Enter the default sleep after each sentence. If the keyboard tape to quickly, some data will be lost on the network. If the import of data failed, try to increase the default sleep");
            Console.WriteLine("Sleep time ? (enter 200 for good speed)");
            int sleepT;
            String Result = Console.ReadLine();
            while (!Int32.TryParse(Result, out sleepT))
            {
                Console.WriteLine("Not a valid number, try again.");
                Result = Console.ReadLine();
            }

            Console.WriteLine(@"[+] If the file is a binary I cannot directly send him through the keyboard.
I will encode it in base64 for you inside a html file.Once the file is copied on the remote machine,
save it as .html and open it with IE. He will ask you to save the file(decoded in b64), then save it with the extension you want. If there are some errors, the error will be displayed on the html page.");
            Console.WriteLine("The file is a binary ? y/N ");
            string overwrite = Console.ReadLine();

            try
            {
                var prc = Process.GetProcessById(int.Parse(idProc));
                SetForegroundWindow(prc.MainWindowHandle);
            }
            catch
            {
                System.Environment.Exit(1);
            }

            var watch = System.Diagnostics.Stopwatch.StartNew();

            if (overwrite.ToUpper().Equals("Y") || overwrite.ToLower().Equals("y"))
            {
                // the file is a binary
                string contents = File.ReadAllText(file);
                string content64 = Base64Encode(contents);

                sendSample("<!DOCTYPE html>\n", sleepT);
                sendSample("<html><head><title>Download Binary file with IE</title></head>\n", sleepT);
                sendSample("<body><script type='text/javascript'>\n", sleepT);
                sendSample("function b64toBlob(r,e,n){e=e||\"\",n=n||512;for(var t=atob(r),a=[],o=0;o<t.length;o+=n){for(var l=t.slice(o,o+n),h=new Array(l.length),b=0;b<l.length;b++)h[b]=l.charCodeAt(b);var v=new Uint8Array(h);a.push(v)}var c=new Blob(a,{type:e});return c}\n", sleepT);
                sendSample("var inject = []; var contentType = 'application/octet-stream';\n", sleepT);
                Console.Write("\n");
                Console.ForegroundColor = ConsoleColor.Yellow;
                System.Threading.Thread.Sleep(250);

                string[] contentSplit = SplitByLength(content64, 100);
                for (var i = 0; i < contentSplit.Length; i++)
                {
                    sendSample("inject.push('", sleepT);
                    sendSample(contentSplit[i], sleepT);
                    sendSample("');" + "\n", sleepT);
                    string progress = "=";
                    for (int v = 1; v < (i * 50) / contentSplit.Length; v++)
                    {
                        progress += "=";
                    }

                    Console.Write("\r[{0, -49}] {1}%   ", progress, ((i + 1) * 100) / contentSplit.Length);
                }
                Console.ResetColor();
                sendSample("var v = 1; for (var i = 0; i < inject.length - 1; i++) {\n", 50);
                sendSample("if (inject[i].length != 100) { v = 0;\n", 50);
                sendSample(@"document.body.innerHTML = document.body.innerHTML + '<p>Error at line : ' + (i + 1 + 5) + ' ' + inject[i] + ' string length : ' + inject[i].length + '/100 <br>' +
        (100 - inject[i].length) + ' char missing, check with the file valid.txt from the physical PC, change the line and reload the page' + '</p>' } }", 50);
                sendSample("\n", 5);
                sendSample("if (v) navigator.msSaveBlob(b64toBlob(inject.join(''), contentType), 'file');", sleepT);
                sendSample("</script></body></html>\n", sleepT);
            }
            else
            {
/*                // the file is not a binary
                Console.ForegroundColor = ConsoleColor.Yellow;
                var lines = File.ReadAllLines(file);
                for (var i = 0; i < lines.Length; i++)
                {
                    sendSample(lines[i] + "\n", sleepT);
                    string progress = "=";
                    for (int v = 1; v < (i * 50) / lines.Length; v++)
                    {
                        progress += "=";
                    }
                    Console.Write("\r[{0, -49}] {1}%   ", progress, ((i + 1) * 100) / lines.Length);
                }
                Console.ResetColor();
            }
            Console.WriteLine("\n");
            watch.Stop();
            var elapsedMs = watch.ElapsedMilliseconds;
            Console.WriteLine("[+] KeyBS stop : " + elapsedMs / 1000 + "s, " + (new FileInfo("valid.txt").Length / (elapsedMs / 1000)) + "o/s");
            Console.Write("\n");*/

            if (overwrite.ToUpper().Equals("Y") || overwrite.ToLower().Equals("y"))
            {
                do
                {
                    Console.WriteLine("If there is some errors printed in the html file, enter the line error I will rewrite it into your remote app (or CTRL-C to finish) ");
                    string id = Console.ReadLine();
                    string line = File.ReadLines("valid.txt").Skip(int.Parse(id)).Take(1).First();
                    try
                    {
                        var prc = Process.GetProcessById(int.Parse(idProc));
                        SetForegroundWindow(prc.MainWindowHandle);
                    }
                    catch
                    {
                        Environment.Exit(1);
                    }
                    sendSample(line, sleepT);
                    Console.WriteLine(line);
                } while (true);
            }
            Environment.Exit(1);
        }

        [DllImport("user32.dll")]
        private static extern bool SetForegroundWindow(IntPtr hWnd);
    }
}
