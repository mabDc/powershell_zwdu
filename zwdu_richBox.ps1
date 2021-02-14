Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object Windows.Forms.Form -Property @{
    StartPosition = [Windows.Forms.FormStartPosition]::CenterScreen
    Size          = New-Object System.Drawing.Size 1040, 620
    Text          = '阅读器 八一中文网 https://www.zwdu.com/'
}
function Add-Controller ([string] $t, [Int] $x, [Int] $y, [Int] $w, [Int] $h, [string] $text) {
    $c = New-Object $t -Property @{
        Location = New-Object Drawing.Point $x, $y
        Size     = New-Object Drawing.Size $w, $h
        Text     = $text
    }
    $form.Controls.Add($c)
    return $c
}

Add-Controller            Windows.Forms.Label        -x 10   -y 10   -w 150  -h 20   -text '地址'
$urlPath = Add-Controller Windows.Forms.TextBox      -x 10   -y 30   -w 360  -h 20   -text 'https://www.zwdu.com/book/32934/'
$chs = Add-Controller     Windows.Forms.RichTextBox  -x 10   -y 60   -w 450  -h 500
$btnRun = Add-Controller  Windows.Forms.Button       -x 380  -y 20   -w 80   -h 30   -text '获取目录'
$txtArea = Add-Controller Windows.Forms.RichTextBox  -x 500  -y 10   -w 500  -h 560  -text '正文'

$btnRun.Add_Click(
    {
        $chs.Text = "开始获取网页内容, 请稍后..."
        $resp = Invoke-WebRequest $urlPath.Text -UseBasicParsing
        $html = [system.Text.Encoding]::GetEncoding("gbk").GetString($resp.RawContentStream.ToArray())
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
        $html = [system.Text.Encoding]::GetEncoding("gbk").GetString($resp.RawContentStream.ToArray())
        $txtArea.Text = [regex]::Match($html, 'id="content">([\s\S]*?)<div').Groups[1].Value.Replace('&nbsp;', ' ').Replace('<br />', "`n")
    })

$form.ShowDialog()

$chs.Dispose()
$form.Dispose()
