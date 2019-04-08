function Get-ErrorResponsePayload {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        $ErrorObject
    )
    if ($PSVersionTable.PSVersion.Major -lt 6) {
        if ($ErrorObject.Exception.Response) {
            $Reader = [System.IO.StreamReader]::new($ErrorObject.Exception.Response.GetResponseStream())
            $Reader.BaseStream.Position = 0
            $Reader.DiscardBufferedData()
            $ResponseBody = $Reader.ReadToEnd()
            $ResponseBody
        }
    }
    else {
        $ErrorObject.ErrorDetails.Message
    }
}
