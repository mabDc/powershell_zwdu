Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object Windows.Forms.Form -Property @{
    StartPosition = [Windows.Forms.FormStartPosition]::CenterScreen
    Size          = New-Object System.Drawing.Size 1040, 620
    Text          = '阅读器 八一中文网 https://www.zwdu.com/'
}
function Add-Controller ([string] $t, [Int] $x, [Int] $y, [Int] $w, [Int] $h, [string] $text) {
    $c = New-Object $t -Property @{
        Location = New-Object System.Drawing.Point $x, $y
        Size     = New-Object System.Drawing.Size $w, $h
        Text     = $text
    }
    $form.Controls.Add($c)
    return $c
}

Add-Controller            Windows.Forms.Label               -x 10   -y 10   -w 150  -h 20   -text '地址'
$urlPath = Add-Controller Windows.Forms.TextBox             -x 10   -y 30   -w 360  -h 20   -text 'https://www.zwdu.com/book/32934/'
$chs = Add-Controller System.Windows.Forms.FlowLayoutPanel  -x 10   -y 60   -w 450  -h 500
$btnRun = Add-Controller  Windows.Forms.Button              -x 380  -y 20   -w 80   -h 30   -text '获取目录'
$txtArea = Add-Controller Windows.Forms.RichTextBox         -x 500  -y 10   -w 500  -h 560  -text '正文'

$chs.AutoScroll = $true;
$chs.FlowDirection = [System.Windows.Forms.FlowDirection]::LeftToRight
# $chs.WrapContents = $false; // Vertical rather than horizontal scrolling

$btnRun.Add_Click(
    {
        $resp = Invoke-WebRequest $urlPath.Text -UseBasicParsing
        $html = [system.Text.Encoding]::GetEncoding("gbk").GetString($resp.RawContentStream.ToArray())
        $txtArea.Text = $html
        $block = [regex]::Match($html, 'id="list"[\s\S]*?div')
        $chs.Controls.Clear()
        $chs.Controls.AddRange(
            ([regex]::Matches($block.Value, 'href="(.*?)">(.*?)<') | ForEach-Object {
                    $b = New-Object System.Windows.Forms.Button -Property @{
                        TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
                        Text      = $_.Groups[2].Value
                        Width     = 200
                        Height    = 30
                    }
                    $url = "https://www.zwdu.com" + $_.Groups[1].Value
                    $txt = $txtArea
                    $b.Add_Click(
                        {
                            $resp = Invoke-WebRequest $url -UseBasicParsing
                            $html = [system.Text.Encoding]::GetEncoding("gbk").GetString($resp.RawContentStream.ToArray())
                            $txt.Text = [regex]::Match($html, 'id="content">([\s\S]*?)<div').Groups[1].Value.Replace('&nbsp;', ' ').Replace('<br />', "`n")
                        }.GetNewClosure())
                    return $b
                }))
    })

$form.ShowDialog()

$chs.Dispose()
$form.Dispose()
