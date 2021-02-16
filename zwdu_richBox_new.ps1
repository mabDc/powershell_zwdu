using namespace System.Windows.Forms
using namespace System.Drawing
using namespace system.Text

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = [Form] @{
    StartPosition = [FormStartPosition]::CenterScreen
    Size          = [Size]::new(1040, 620)
    Text          = '阅读器 八一中文网 https://www.zwdu.com/'
}

$label = [Label] @{
    Location = [Point]::new(10, 10)
    Size     = [Size]::new(150, 20)
    Text     = '地址'
}

$urlPath = [TextBox] @{
    Location = [Point]::new(10, 30)
    Size     = [Size]::new(360, 20)
    Text     = 'https://www.zwdu.com/book/32934/'
}

$chs = [RichTextBox] @{
    Location = [Point]::new(10, 60)
    Size     = [Size]::new(450, 500)
}

$btnRun = [Button] @{
    Location = [Point]::new(380, 20)
    Size     = [Size]::new(80, 30)
    Text     = '获取目录'
}

$txtArea = [RichTextBox] @{
    Location = [Point]::new(500, 10)
    Size     = [Size]::new(500, 560)
    Text     = '正文'
}

$form.Controls.AddRange(@($label, $urlPath, $chs, $btnRun, $txtArea))

$btnRun.Add_Click(
    {
        $chs.Text = "开始获取网页内容, 请稍后..."
        $resp = Invoke-WebRequest $urlPath.Text -UseBasicParsing
        $html = [Encoding]::GetEncoding("gbk").GetString($resp.RawContentStream.ToArray())
        $txtArea.Text = $html
        $block = [regex]::Match($html, 'id="list"[\s\S]*?div')
        $chs.Text = ([regex]::Matches($block.Value, 'href="(.*?)">(.*?)<') | ForEach-Object {
                return "https://www.zwdu.com" + $_.Groups[1].Value + " " + $_.Groups[2].Value
            }) -Join "`n"
    })

$chs.add_LinkClicked(
    {
        $txtArea.Text = "开始获取网页内容, 请稍后... "
        $resp = Invoke-WebRequest $_.LinkText -UseBasicParsing
        $html = [Encoding]::GetEncoding("gbk").GetString($resp.RawContentStream.ToArray())
        $txtArea.Text = [regex]::Match($html, 'id="content">([\s\S]*?)<div').Groups[1].Value.Replace('&nbsp;', ' ').Replace('<br />', "`n")
    })

$form.ShowDialog()

$chs.Dispose()
$form.Dispose()
