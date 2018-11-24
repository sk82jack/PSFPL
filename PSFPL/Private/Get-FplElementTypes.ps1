function Get-FplElementTypes {
    $Response = Invoke-RestMethod -Uri 'https://fantasy.premierleague.com/drf/element-types' -UseBasicParsing
    $ElementHash = @{}
    foreach ($Element in $Response) {
        $ElementHash[$Element.id] = $Element.singular_name
    }
    $ElementHash
}
