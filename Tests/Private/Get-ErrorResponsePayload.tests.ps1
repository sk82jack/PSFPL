Import-Module $ENV:BHPSModuleManifest -Force
InModuleScope 'PSFPL' {
    Describe 'Get-ErrorResponsePayload' {
        BeforeAll {
            $ScriptBlock = {
                $HttpListener = New-Object System.Net.HttpListener
                $HttpListener.Prefixes.Add("http://localhost:8080/")
                $HttpListener.Start()
                $HttpContext = $HttpListener.GetContext()
                $HttpResponse = $HttpContext.Response
                $HttpResponse.StatusCode = 400
                $Output = '{"details":{"non_field_errors":["TXFER_ET_BAD_COUNT::You need to select between 1 and 1 Goalkeepers. 2 were selected."],"errors":[{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}]}}'
                $ResponseBuffer = [System.Text.Encoding]::UTF8.GetBytes($Output)
                $HttpResponse.ContentLength64 = $ResponseBuffer.Length
                $HttpResponse.OutputStream.Write($ResponseBuffer, 0, $ResponseBuffer.Length)
                $HttpResponse.Close()
                $HttpListener.Stop()
            }
            $Job = Start-Job -ScriptBlock $ScriptBlock
            try {
                Invoke-WebRequest -Uri 'http://localhost:8080/' -UseBasicParsing -ErrorAction 'Stop'
            }
            catch {
                $ErrorObject = $_
            }
            Wait-Job -Job $Job | Remove-Job
        }
        It 'gets the error stream from the error record' {
            $Output = '{"details":{"non_field_errors":["TXFER_ET_BAD_COUNT::You need to select between 1 and 1 Goalkeepers. 2 were selected."],"errors":[{},{},{},{},{},{},{},{},{},{},{},{},{},{},{}]}}'
            Get-ErrorResponsePayload -ErrorObject $ErrorObject | Should -Be $Output
        }
    }
}
