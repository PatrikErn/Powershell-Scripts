# Converts .docx to .dotm format ,
# Conversion takes all docx in a folder and outputs them to another location inside the working folder called "Converted"
# Change location in line 12 "$($_.DirectoryName)\Changethisfolder\$($_.BaseName).dotm"

$path = "c:\Temp\Docm\" 
$word_app = New-Object -ComObject Word.Application

$Format = [Microsoft.Office.Interop.Word.WdSaveFormat]::wdFormatXMLTemplateMacroEnabled

Get-ChildItem -Path $path -Filter *.docx | ForEach-Object {
    $document = $word_app.Documents.Open($_.FullName)
    $dotx_filename = "$($_.DirectoryName)\Converted\$($_.BaseName).dotm"
    $document.SaveAs([ref] $dotx_filename, [ref]$Format)
    $document.Close()
}
$word_app.Quit()